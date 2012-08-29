/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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


#import "CCDirector.h"
#import "ccMacros.h"
#import "CCAction.h"
#import "CCNode.h"

#import "Support/CGPointExtension.h"

//
// Action Base Class
//
#pragma mark - Action

@implementation CCAction

@synthesize tag = _tag;

@synthesize target = _target;

@synthesize originalTarget = _originalTarget;

@synthesize completionBlock = _completionBlock;

+(id) action
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	if( (self=[super init]) )
    {
		_originalTarget = _target = nil;
		_tag = 0;
	}
	return self;
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	[super dealloc];
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Tag = %ld>", [self class], self, (long)_tag];
}

- (id)copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] init];
	copy.tag = _tag;
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	_originalTarget = _target = aTarget;
}

-(void) stop
{
	_target = nil;
}

-(BOOL) isDone
{
	return YES;
}

-(void) step: (NSTimeInterval) dt
{
	CCLOG(@"[Action step]. override me");
}

-(void) update: (NSTimeInterval) time
{
	CCLOG(@"[Action update]. override me");
}

@synthesize duration = duration_;

- (CCAction*) reverse
{
	CCLOG(@"cocos2d: FiniteTimeAction#reverse: Implement me");
	return nil;
}

@end


//
// Speed
//
#pragma mark -  Speed

@implementation CCSpeed

@synthesize speed=speed_;

@synthesize innerAction=innerAction_;

-(id) initWithAction: (CCActionInterval*) action speed:(float)value
{
	if( (self=[super init]) ) {
		self.innerAction = action;
		speed_ = value;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithAction:[[innerAction_ copy] autorelease] speed:speed_];
    return copy;
}

-(void) dealloc
{
	[innerAction_ release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[innerAction_ startWithTarget:_target];
}

-(void) stop
{
	[innerAction_ stop];
	[super stop];
}

-(void) step:(NSTimeInterval) dt
{
	[innerAction_ step: dt * speed_];
}

-(BOOL) isDone
{
	return [innerAction_ isDone];
}

- (CCAction *) reverse
{
	return (id)[[[CCSpeed alloc] initWithAction: [innerAction_ reverse] speed:speed_] autorelease];
}

@end

//
// Follow
//
#pragma mark -
#pragma mark Follow
@implementation CCFollow

@synthesize boundarySet;

-(id) initWithTarget: (CCNode *)fNode
{
	if( (self=[super init]) ) {

		followedNode_ = [fNode retain];
		boundarySet = FALSE;
		boundaryFullyCovered = FALSE;

		CGSize s = [[CCDirector sharedDirector] winSize];
		fullScreenSize = CGPointMake(s.width, s.height);
		halfScreenSize = ccpMult(fullScreenSize, .5f);
	}

	return self;
}

- (id) initWithTarget:(CCNode *)fNode worldBoundary:(CGRect)rect
{
	if( (self=[super init]) ) {

		followedNode_ = [fNode retain];
		boundarySet = TRUE;
		boundaryFullyCovered = FALSE;

		CGSize winSize = [[CCDirector sharedDirector] winSize];
		fullScreenSize = CGPointMake(winSize.width, winSize.height);
		halfScreenSize = ccpMult(fullScreenSize, .5f);

		leftBoundary = -((rect.origin.x+rect.size.width) - fullScreenSize.x);
		rightBoundary = -rect.origin.x ;
		topBoundary = -rect.origin.y;
		bottomBoundary = -((rect.origin.y+rect.size.height) - fullScreenSize.y);

		if(rightBoundary < leftBoundary)
		{
			// screen width is larger than world's boundary width
			//set both in the middle of the world
			rightBoundary = leftBoundary = (leftBoundary + rightBoundary) / 2;
		}
		if(topBoundary < bottomBoundary)
		{
			// screen width is larger than world's boundary width
			//set both in the middle of the world
			topBoundary = bottomBoundary = (topBoundary + bottomBoundary) / 2;
		}

		if( (topBoundary == bottomBoundary) && (leftBoundary == rightBoundary) )
			boundaryFullyCovered = TRUE;
	}

	return self;
}

- (id)copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] init];
	copy.tag = _tag;
	return copy;
}

-(void) step:(NSTimeInterval) dt
{
	if(boundarySet)
	{
		// whole map fits inside a single screen, no need to modify the position - unless map boundaries are increased
		if(boundaryFullyCovered)
			return;

		CGPoint tempPos = ccpSub( halfScreenSize, followedNode_.position);
		[(CCNode *)_target setPosition:ccp(clampf(tempPos.x,leftBoundary,rightBoundary), clampf(tempPos.y,bottomBoundary,topBoundary))];
        
	}else
    {
		[(CCNode *)_target setPosition:ccpSub( halfScreenSize, followedNode_.position )];
    }
}


-(BOOL) isDone
{
	return !followedNode_.isRunning;
}

-(void) stop
{
	_target = nil;
	[super stop];
}

-(void) dealloc
{
	[followedNode_ release];
	[super dealloc];
}

@end


