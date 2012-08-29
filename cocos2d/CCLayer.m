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


#import <stdarg.h>

#import "Platforms/CCGL.h"

#import "CCLayer.h"
#import "CCDirector.h"
#import "ccMacros.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "ccGLStateCache.h"
#import "Support/TransformUtils.h"
#import "Support/CGPointExtension.h"

#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCTouchDispatcher.h"
#import "Platforms/iOS/CCDirectorIOS.h"
#elif defined(__CC_PLATFORM_MAC)
#import "Platforms/Mac/CCEventDispatcher.h"
#import "Platforms/Mac/CCDirectorMac.h"
#endif

// extern


#pragma mark -
#pragma mark Layer


@interface CCLayer (Private)

- (void)updateColor;

@end


@implementation CCLayer

static NSMutableArray *__CCLayerAnimationStack = nil;

#pragma mark Layer - Init

+ (void)load
{
    __CCLayerAnimationStack = [[NSMutableArray alloc] initWithCapacity: 10];
}

+ (id)layer
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
	if( (self=[super init]) )
    {        
		_ignoreAnchorPointForPosition = YES;
        
		_isUserInteractionEnabled = YES;
        
		_blendFunc = (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };
        
        _anchorPoint = ccp(0.5f, 0.5f);

        color_ = ccc4(0, 0, 0, 0);

		[self updateColor];
        
		CGSize s = [[CCDirector sharedDirector] winSize];
		[self setContentSize: s];
        
        [self setShaderProgram: CCShaderCacheGetProgramByName(CCShaderPositionColorProgram)];
        
	}
    
	return self;
}

#pragma mark Layer - Touch and Accelerometer related

-(void) registerWithTouchDispatcher
{
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addStandardDelegate: self
                                           priority: 0];
}


@synthesize userInteractionEnabled = _isUserInteractionEnabled;

- (void)setUserInteractionEnabled: (BOOL)userInteractionEnabled
{
	if( _isUserInteractionEnabled != userInteractionEnabled )
    {
		_isUserInteractionEnabled = userInteractionEnabled;
		if( _isRunning )
        {
			if( _isUserInteractionEnabled )
            {
				[self registerWithTouchDispatcher];
			}else
            {
				CCDirector *director = [CCDirector sharedDirector];
				[[director touchDispatcher] removeDelegate:self];
			}
		}
	}
}


#pragma mark Layer - Callbacks

-(void) onEnter
{
	// register 'parent' nodes first
	// since events are propagated in reverse order
	if (_isUserInteractionEnabled)
    {
		[self registerWithTouchDispatcher];
    }
	// then iterate over all the children
	[super onEnter];
}

-(void) onExit
{
	CCDirector *director = [CCDirector sharedDirector];
    
	if( _isUserInteractionEnabled )
    {
		[[director touchDispatcher] removeDelegate:self];
    }
    
	[super onExit];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(NO, @"Layer#ccTouchBegan override me");
	return YES;
}

// Opacity and RGB color protocol
@synthesize color = color_;

@synthesize blendFunc = _blendFunc;

// override contentSize
-(void) setContentSize: (CGSize) size
{
	squareVertices_[1].x = size.width;
	squareVertices_[2].y = size.height;
	squareVertices_[3].x = size.width;
	squareVertices_[3].y = size.height;
    
	[super setContentSize: size];
}

- (void) updateColor
{
	for( NSUInteger i = 0; i < 4; i++ )
	{
		squareColors_[i].r = color_.r / 255.0f;
		squareColors_[i].g = color_.g / 255.0f;
		squareColors_[i].b = color_.b / 255.0f;
		squareColors_[i].a = color_.a / 255.0f;
	}
}

- (void) draw
{
	CC_NODE_DRAW_SETUP();
    
	VEGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );
    
	//
	// Attributes
	//
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, squareVertices_);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, 0, squareColors_);
    
	CCGLBlendFunc( _blendFunc.src, _blendFunc.dst );
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	CC_INCREMENT_GL_DRAWS(1);
}

#pragma mark Protocols
// Color Protocol

-(void) setColor:(ccColor4B)color
{
	color_ = color;
	[self updateColor];
}

-(void) setOpacity: (GLubyte) o
{
    if (color_.a != o)
    {
        color_.a = o;
        [self updateColor];
    }
}

- (GLubyte)opacity
{
    return color_.a;
}

+ (void)animateWithDuration: (NSTimeInterval)duration
                      delay: (NSTimeInterval)delay
                    options: (UIViewAnimationOptions)options
                 animations: (void (^)(void))animations
                 completion: (void (^)(BOOL finished))completion
{
    
}

+ (void)animateWithDuration: (NSTimeInterval)duration
                 animations: (void (^)(void))animations
                 completion: (void (^)(BOOL finished))completion // delay = 0.0, options = 0
{
    [self animateWithDuration: duration
                        delay: 0
                      options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut
                   animations: animations
                   completion: completion];
}

+ (void)animateWithDuration: (NSTimeInterval)duration
                 animations: (void (^)(void))animations // delay = 0.0, options = 0, completion = NULL
{
    [self animateWithDuration: duration
                        delay: 0
                      options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut
                   animations: animations
                   completion: nil];
}

+ (void)transitionWithLayer: (CCLayer *)layer
                   duration: (NSTimeInterval)duration
                    options: (UIViewAnimationOptions)options
                 animations: (void (^)(void))animations
                 completion: (void (^)(BOOL finished))completion
{
    
}

+ (void)transitionFromLayer: (CCLayer *)fromView
                    toLayer: (CCLayer *)toView
                   duration: (NSTimeInterval)duration
                    options: (UIViewAnimationOptions)options
                 completion: (void (^)(BOOL finished))completion // toView added to fromView.superview, fromView removed from its superview
{
    
}

@end


#pragma mark -
#pragma mark LayerGradient

@implementation CCGradientLayer

@synthesize startOpacity = startOpacity_;
@synthesize endColor = endColor_, endOpacity = endOpacity_;
@synthesize vector = vector_;

- (id) initWithColor: (ccColor4B) start fadingTo: (ccColor4B) end
{
    return [self initWithColor:start fadingTo:end alongVector:ccp(0, -1)];
}

- (id) initWithColor: (ccColor4B) start
            fadingTo: (ccColor4B) end
         alongVector: (CGPoint) v
{
    if ((self = [super init]))
    {
        
        endColor_.r = end.r;
        endColor_.g = end.g;
        endColor_.b = end.b;
        
        endOpacity_		= end.a;
        startOpacity_	= start.a;
        vector_ = v;
        
        start.a	= 255;
        compressedInterpolation_ = YES;
        [self setColor: start];
    }
	return self;
}

- (void) updateColor
{
    [super updateColor];
    
	float h = ccpLength(vector_);
    if (h == 0)
		return;
    
	float c = sqrtf(2);
    CGPoint u = ccp(vector_.x / h, vector_.y / h);
    
	// Compressed Interpolation mode
	if( compressedInterpolation_ ) {
		float h2 = 1 / ( fabsf(u.x) + fabsf(u.y) );
		u = ccpMult(u, h2 * (float)c);
	}
    
	float opacityf = color_.a/255.0f;
    
    ccColor4F S = {
		color_.r / 255.0f,
		color_.g / 255.0f,
		color_.b / 255.0f,
		startOpacity_*opacityf / 255.0f,
	};
    
    ccColor4F E = {
		endColor_.r / 255.0f,
		endColor_.g / 255.0f,
		endColor_.b / 255.0f,
		endOpacity_*opacityf / 255.0f,
	};
    
    
    // (-1, -1)
	squareColors_[0].r = E.r + (S.r - E.r) * ((c + u.x + u.y) / (2.0f * c));
	squareColors_[0].g = E.g + (S.g - E.g) * ((c + u.x + u.y) / (2.0f * c));
	squareColors_[0].b = E.b + (S.b - E.b) * ((c + u.x + u.y) / (2.0f * c));
	squareColors_[0].a = E.a + (S.a - E.a) * ((c + u.x + u.y) / (2.0f * c));
    // (1, -1)
	squareColors_[1].r = E.r + (S.r - E.r) * ((c - u.x + u.y) / (2.0f * c));
	squareColors_[1].g = E.g + (S.g - E.g) * ((c - u.x + u.y) / (2.0f * c));
	squareColors_[1].b = E.b + (S.b - E.b) * ((c - u.x + u.y) / (2.0f * c));
	squareColors_[1].a = E.a + (S.a - E.a) * ((c - u.x + u.y) / (2.0f * c));
	// (-1, 1)
	squareColors_[2].r = E.r + (S.r - E.r) * ((c + u.x - u.y) / (2.0f * c));
	squareColors_[2].g = E.g + (S.g - E.g) * ((c + u.x - u.y) / (2.0f * c));
	squareColors_[2].b = E.b + (S.b - E.b) * ((c + u.x - u.y) / (2.0f * c));
	squareColors_[2].a = E.a + (S.a - E.a) * ((c + u.x - u.y) / (2.0f * c));
	// (1, 1)
	squareColors_[3].r = E.r + (S.r - E.r) * ((c - u.x - u.y) / (2.0f * c));
	squareColors_[3].g = E.g + (S.g - E.g) * ((c - u.x - u.y) / (2.0f * c));
	squareColors_[3].b = E.b + (S.b - E.b) * ((c - u.x - u.y) / (2.0f * c));
	squareColors_[3].a = E.a + (S.a - E.a) * ((c - u.x - u.y) / (2.0f * c));
}

- (ccColor4B)startColor
{
	return color_;
}

-(void) setStartColor:(ccColor4B)colors
{
	[self setColor: colors];
}

-(void) setEndColor:(ccColor4B)colors
{
    endColor_ = colors;
    [self updateColor];
}

-(void) setStartOpacity: (GLubyte) o
{
	startOpacity_ = o;
    [self updateColor];
}

-(void) setEndOpacity: (GLubyte) o
{
    endOpacity_ = o;
    [self updateColor];
}

-(void) setVector: (CGPoint) v
{
    vector_ = v;
    [self updateColor];
}

-(BOOL) compressedInterpolation
{
	return compressedInterpolation_;
}

-(void) setCompressedInterpolation:(BOOL)compress
{
	compressedInterpolation_ = compress;
	[self updateColor];
}
@end

#pragma mark -
#pragma mark MultiplexLayer

@implementation CCMultiplexLayer

-(id) initWithLayers: (NSArray*) layers;
{
	if( (self=[super init]) ) {
        
		layers_ = [[NSMutableArray alloc] initWithArray: layers];
        
		enabledLayer_ = 0;
		[self addChild: [layers_ objectAtIndex: enabledLayer_]];
	}
    
	return self;
}

-(void) dealloc
{
	[layers_ release];
	[super dealloc];
}

-(void) switchTo: (unsigned int) n
{
	NSAssert( n < [layers_ count], @"Invalid index in MultiplexLayer switchTo message" );
    
	[self removeChild: [layers_ objectAtIndex:enabledLayer_] cleanup:YES];
    
	enabledLayer_ = n;
    
	[self addChild: [layers_ objectAtIndex:n]];
}

-(void) switchToAndReleaseMe: (unsigned int) n
{
	NSAssert( n < [layers_ count], @"Invalid index in MultiplexLayer switchTo message" );
    
	[self removeChild: [layers_ objectAtIndex:enabledLayer_] cleanup:YES];
    
	[layers_ replaceObjectAtIndex:enabledLayer_ withObject:[NSNull null]];
    
	enabledLayer_ = n;
    
	[self addChild: [layers_ objectAtIndex:n]];
}
@end
