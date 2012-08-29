/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Copyright (c) 2011 John Wordsworth
 *
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CCAnimationCacheService.h"
#import "ccMacros.h"
#import "CCSpriteFrameCache.h"
#import "CCAnimation.h"
#import "CCSprite.h"
#import "Support/CCFileUtils.h"

@implementation CCAnimationCacheService

#pragma mark CCAnimationCacheService - Alloc, Init & Dealloc

-(id) init
{
	if( (self=[super init]) )
    {
		animations_ = [[NSMutableDictionary alloc] initWithCapacity: 20];
	}
    
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | num of animations =  %lu>", [self class], self, (unsigned long)[animations_ count]];
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
    
	[animations_ release];
	[super dealloc];
}

#pragma mark CCAnimationCacheService - load/get/del

-(void) removeAnimationByName:(NSString*)name
{
	if( ! name )
		return;
    
	[animations_ removeObjectForKey:name];
}

-(CCAnimation*) animationByName:(NSString*)name
{
	return [animations_ objectForKey:name];
}

#pragma mark CCAnimationCacheService - from file

-(void) parseVersion1:(NSDictionary*)animations
{
	NSArray* animationNames = [animations allKeys];
	CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
	for( NSString *name in animationNames ) {
		NSDictionary* animationDict = [animations objectForKey:name];
		NSArray *frameNames = [animationDict objectForKey:@"frames"];
		NSNumber *delay = [animationDict objectForKey:@"delay"];
		CCAnimation* animation = nil;
		
		if ( frameNames == nil ) {
			CCLOG(@"cocos2d: CCAnimationCacheService: Animation '%@' found in dictionary without any frames - cannot add to animation cache.", name);
			continue;
		}
		
		NSMutableArray *frames = [NSMutableArray arrayWithCapacity:[frameNames count]];
		
		for( NSString *frameName in frameNames ) {
			CCSpriteFrame *spriteFrame = [frameCache spriteFrameByName:frameName];
			
			if ( ! spriteFrame ) {
				CCLOG(@"cocos2d: CCAnimationCacheService: Animation '%@' refers to frame '%@' which is not currently in the CCSpriteFrameCache. This frame will not be added to the animation.", name, frameName);
				
				continue;
			}
			
			CCAnimationFrame *animFrame = [[CCAnimationFrame alloc] initWithSpriteFrame:spriteFrame delayUnits:1 userInfo:nil];
			[frames addObject:animFrame];
			[animFrame release];
		}
		
		if ( [frames count] == 0 ) {
			CCLOG(@"cocos2d: CCAnimationCacheService: None of the frames for animation '%@' were found in the CCSpriteFrameCache. Animation is not being added to the Animation Cache.", name);
			continue;
		} else if ( [frames count] != [frameNames count] ) {
			CCLOG(@"cocos2d: CCAnimationCacheService: An animation in your dictionary refers to a frame which is not in the CCSpriteFrameCache. Some or all of the frames for the animation '%@' may be missing.", name);
		}
		
		animation = [[CCAnimation alloc] initWithAnimationFrames:frames delayPerUnit:[delay floatValue] loops:1 ];
		
		[animations_ setObject: animation
                        forKey: name];
        
        [animation release];
	}
}

-(void) parseVersion2:(NSDictionary*)animations
{
	NSArray* animationNames = [animations allKeys];
	CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
	
	for( NSString *name in animationNames )
	{
		NSDictionary* animationDict = [animations objectForKey:name];
        
		NSNumber *loops = [animationDict objectForKey:@"loops"];
		BOOL restoreOriginalFrame = [[animationDict objectForKey:@"restoreOriginalFrame"] boolValue];
		NSArray *frameArray = [animationDict objectForKey:@"frames"];
		
		
		if ( frameArray == nil ) {
			CCLOG(@"cocos2d: CCAnimationCacheService: Animation '%@' found in dictionary without any frames - cannot add to animation cache.", name);
			continue;
		}
        
		// Array of AnimationFrames
		NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[frameArray count]];
        
		for( NSDictionary *entry in frameArray ) {
			NSString *spriteFrameName = [entry objectForKey:@"spriteframe"];
			CCSpriteFrame *spriteFrame = [frameCache spriteFrameByName:spriteFrameName];
			
			if( ! spriteFrame ) {
				CCLOG(@"cocos2d: CCAnimationCacheService: Animation '%@' refers to frame '%@' which is not currently in the CCSpriteFrameCache. This frame will not be added to the animation.", name, spriteFrameName);
				
				continue;
			}
            
			float delayUnits = [[entry objectForKey:@"delayUnits"] floatValue];
			NSDictionary *userInfo = [entry objectForKey:@"notification"];
			
			CCAnimationFrame *animFrame = [[CCAnimationFrame alloc] initWithSpriteFrame:spriteFrame delayUnits:delayUnits userInfo:userInfo];
			
			[array addObject:animFrame];
			[animFrame release];
		}
		
		float delayPerUnit = [[animationDict objectForKey:@"delayPerUnit"] floatValue];
		CCAnimation *animation = [[CCAnimation alloc] initWithAnimationFrames:array delayPerUnit:delayPerUnit loops:(loops?[loops intValue]:1)];
		[array release];
		
		[animation setRestoreOriginalFrame:restoreOriginalFrame];
        
		[animations_ setObject: animation
                        forKey: name];
        
		[animation release];
	}
}

-(void)addAnimationsWithDictionary:(NSDictionary *)dictionary
{
	NSDictionary *animations = [dictionary objectForKey:@"animations"];
    
	if ( animations == nil ) {
		CCLOG(@"cocos2d: CCAnimationCacheService: No animations were found in provided dictionary.");
		return;
	}
	
	NSUInteger version = 1;
	NSDictionary *properties = [dictionary objectForKey:@"properties"];
	if( properties )
		version = [[properties objectForKey:@"format"] intValue];
	
	NSArray *spritesheets = [properties objectForKey:@"spritesheets"];
	for( NSString *name in spritesheets )
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:name];
    
	switch (version)
    {
		case 1:
			[self parseVersion1:animations];
			break;
		case 2:
			[self parseVersion2:animations];
			break;
		default:
			NSAssert(NO, @"Invalid animation format");
	}
}


/** Read an NSDictionary from a plist file and parse it automatically for animations */
-(void)addAnimationsWithFile:(NSString *)plist
{
	NSAssert( plist, @"Invalid texture file name");
    
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:plist];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
	NSAssert1( dict, @"CCAnimationCacheService: File could not be found: %@", plist);
    
    
	[self addAnimationsWithDictionary:dict];
}

- (void)initializeBlocks
{
    __block NSMutableDictionary *animations = animations_;
    
    [self registerBlock: (^(NSString *action, NSArray *arguments, VECallbackBlock callback)
                          {
                              [animations removeAllObjects];
                              
                              if (callback)
                              {
                                  callback(action, arguments);
                              }
                          })
              forAction: CCAnimationCacheServiceClearup];
    
    [self registerBlock: (^(NSString *action, NSArray *arguments, VECallbackBlock callback)
                          {
                              [animations setObject: [arguments objectAtIndex: 0]
                                             forKey: [arguments objectAtIndex: 1]];
                          })
              forAction: CCAnimationCacheServiceRegisterAnimationWithName];
    
    [self registerBlock: (^(NSString *action, NSArray *arguments, VECallbackBlock callback)
                          {
                              if (callback)
                              {
                                  id animation = [animations objectForKey: [arguments objectAtIndex: 0]];
                                  callback(action, animation);
                              }
                          })
              forAction: CCAnimationCacheServiceAnimationByName];
}

+ (NSString *)identity
{
    return CCAnimationCacheServiceID;
}

+ (void)load
{
    [VEDataSource registerServiceByClass: self];
}

@end

NSString * const CCAnimationCacheServiceID = @"com.veritas.cocos2d.service.animation";

NSString * const CCAnimationCacheServiceClearup = @"service.animation.clearup";

NSString * const CCAnimationCacheServiceRegisterAnimationWithName = @"service.animation.regiserAnimationWithName";

NSString * const CCAnimationCacheServiceAnimationByName = @"service.animation.animationByName";
