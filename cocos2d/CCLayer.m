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
#import "CCScheduler.h"
#import "CCDirector.h"
#import "ccMacros.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "ccGLStateCache.h"
#import "VEAnimation.h"

#import "Support/TransformUtils.h"
#import "Support/CGPointExtension.h"

#import "Platforms/iOS/CCTouchDispatcher.h"
#import "Platforms/iOS/CCDirectorIOS.h"

#import "VGColor.h"

#pragma mark - Layer

@interface CCLayer ()
{
@private
    CCLayer *_presentationLayer;
}
@end

@interface CCLayer (Private)

- (void)updateColor;

@end


@implementation CCLayer

static NSMutableArray *__CCLayerAnimationStack = nil;
static __VEAnimationConfiguration *__currentBlockAnimationConfiguration = nil;

static inline void __CCLayerPushConfiguration(__VEAnimationConfiguration *config)
{
    [__CCLayerAnimationStack addObject: config];
    __currentBlockAnimationConfiguration = config;
}

static inline void __CCLayerPopConfiguration(void)
{
    [__CCLayerAnimationStack removeLastObject];
    __currentBlockAnimationConfiguration = nil;
}

#pragma mark Layer - Init

+ (void)load
{
    __CCLayerAnimationStack = [[NSMutableArray alloc] initWithCapacity: 10];
}

+ (id)layer
{
    return [[[self alloc] init] autorelease];
}

- (id)presentationLayer
{
    if (!_presentationLayer)
    {
        //_presentationLayer = [self copy];
    }
    
    return _presentationLayer;
}

- (id)modelLayer
{
    return self;
}


- (id)init
{
	if( (self=[super init]) )
    {
		_ignoreAnchorPointForPosition = YES;
        
		_isUserInteractionEnabled = YES;
        
		_blendFunc = (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };
        
        _anchorPoint = ccp(0.5f, 0.5f);
        
        [self setBackgroundColor: ccc4(0, 0, 0, 0)];
        
        CCDirector *director = [CCDirector sharedDirector];
		CGSize s = [director winSize];
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
@synthesize backgroundColor = _backgroundColor;

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
		squareColors_[i].r = _backgroundColor.r / 255.0f;
		squareColors_[i].g = _backgroundColor.g / 255.0f;
		squareColors_[i].b = _backgroundColor.b / 255.0f;
		squareColors_[i].a = _backgroundColor.a / 255.0f;
	}
}

- (void)draw
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

//- (void)renderInContext: (VEContext *)context
//{
//    [self draw];
//}

#pragma mark - Animation


/** Animation methods. **/

/* Attach an animation object to the layer. Typically this is implicitly
 * invoked through an action that is an VEAnimation object.
 *
 * 'key' may be any string such that only one animation per unique key
 * is added per layer. The special key 'transition' is automatically
 * used for transition animations. The nil pointer is also a valid key.
 *
 * If the `duration' property of the animation is zero or negative it
 * is given the default duration, either the value of the
 * `animationDuration' transaction property or .25 seconds otherwise.
 *
 * The animation is copied before being added to the layer, so any
 * subsequent modifications to `anim' will have no affect unless it is
 * added to another layer. */

//for animation
//
- (void)update: (NSTimeInterval)dt
{
    for (NSString *key in _animationKeys)
    {
        VEBasicAnimation *animation = [_animations objectForKey: key];
        [animation applyForTime: dt
             presentationObject: [self presentationLayer]
                    modelObject: [self modelLayer]];
    }
}

- (void)addAnimation: (VEAnimation *)anim
              forKey: (NSString *)key
{
    if (!_animationKeys)
    {
        _animationKeys = [[NSMutableArray alloc] init];
    }
    
    if (!_animations)
    {
        _animations = [[NSMutableDictionary alloc] init];
    }
    
    VEAnimation *copy = [anim copy];
    
    [_animationKeys addObject: key];
    [_animations setObject: copy
                    forKey: key];
    
    [copy release];
    
    CCDirector *director = [CCDirector sharedDirector];
    
    [[director scheduler] scheduleUpdateForTarget: self
                                         priority: CCSchedulerPriorityZero
                                           paused: NO];
    
}

/* Remove all animations attached to the layer. */

- (void)removeAllAnimations
{
    [_animationKeys removeAllObjects];
    [_animations removeAllObjects];
}

/* Remove any animation attached to the layer for 'key'. */

- (void)removeAnimationForKey: (NSString *)key
{
    [_animationKeys removeObject: key];
    [_animations removeObjectForKey: key];
}

/* Returns an array containing the keys of all animations currently
 * attached to the receiver. The order of the array matches the order
 * in which animations will be applied. */

- (NSArray *)animationKeys
{
    return [NSArray arrayWithArray: _animationKeys];
}

/* Returns the animation added to the layer with identifier 'key', or nil
 * if no such animation exists. Attempting to modify any properties of
 * the returned object will result in undefined behavior. */

- (VEAnimation *)animationForKey:(NSString *)key
{
    return [_animations objectForKey: key];
}

#pragma mark - animatable properties

- (void)setBackgroundColor: (ccColor4B)backgroundColor
{
    if (!CCColor4BEqualToColor(_backgroundColor, backgroundColor))
    {
        NSString * keyPath = @"backgroundColor";
        [self willChangeValueForKey: keyPath];
        
        if (__currentBlockAnimationConfiguration)
        {
            //in block animation
            VEBasicAnimation *animation = [VEBasicAnimation animationWithKeyPath: keyPath];
            [animation setDuration: [__currentBlockAnimationConfiguration duration]];
            [animation setFromValue: [VGColor colorWithRed: _backgroundColor.r / 255.0
                                                     green: _backgroundColor.g / 255.0
                                                      blue: _backgroundColor.b / 255.0
                                                     alpha: _backgroundColor.a / 255.0]];
            
            _backgroundColor = backgroundColor;
            
            [animation setToValue: [VGColor colorWithRed: _backgroundColor.r / 255.0
                                                   green: _backgroundColor.g / 255.0
                                                    blue: _backgroundColor.b / 255.0
                                                   alpha: _backgroundColor.a / 255.0]];
            
            [self addAnimation: animation
                        forKey: keyPath];
            
            __CCLayerPopConfiguration();
            
        }else
        {
            _backgroundColor = backgroundColor;
        }
        
        [self didChangeValueForKey: keyPath];
        
        [self updateColor];
    }
}

- (ccColor4B)backgroundColor
{
    return _backgroundColor;
}

-(void) setOpacity: (GLubyte) o
{
    if (_backgroundColor.a != o)
    {
        _backgroundColor.a = o;
        [self updateColor];
    }
}

- (GLubyte)opacity
{
    return _backgroundColor.a;
}

#pragma mark - animation


+ (void)_setupAnimationWithDuration: (NSTimeInterval)duration
                              delay: (NSTimeInterval)delay
                               view: (CCLayer *)layer
                            options: (UIViewAnimationOptions)options
                         animations: (dispatch_block_t)animations
                              start: (dispatch_block_t)start
                         completion: (void (^)(BOOL finished))completion
{
    if (start)
    {
        start();
    }
    
    if (animations)
    {
        __VEAnimationConfiguration *configuration = [[__VEAnimationConfiguration alloc] init];
        [configuration setDuration: duration];
        [configuration setDelay: delay];
        //[configuration setOptions: options];
        [configuration setAnimations: animations];
        [configuration setStart: start];
        [configuration setCompletion: completion];
        
        __CCLayerPushConfiguration(configuration);
        
        [configuration release];
        
        animations();
        
    }
}

+ (void)animateWithDuration: (NSTimeInterval)duration
                      delay: (NSTimeInterval)delay
                    options: (UIViewAnimationOptions)options
                 animations: (void (^)(void))animations
                 completion: (void (^)(BOOL finished))completion
{
    [self _setupAnimationWithDuration: duration
                                delay: delay
                                 view: nil
                              options: options
                           animations: animations
                                start: nil
                           completion: completion];
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
        [self setBackgroundColor: start];
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
    
	float opacityf = _backgroundColor.a / 255.0f;
    
    GLKVector4 S = GLKVector4Make(
                                  _backgroundColor.r / 255.0f,
                                  _backgroundColor.g / 255.0f,
                                  _backgroundColor.b / 255.0f,
                                  startOpacity_ * opacityf / 255.0f
                                  );
    
    GLKVector4 E = GLKVector4Make(
                                  endColor_.r / 255.0f,
                                  endColor_.g / 255.0f,
                                  endColor_.b / 255.0f,
                                  endOpacity_*opacityf / 255.0f
                                  );
    
    
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
	return _backgroundColor;
}

-(void) setStartColor:(ccColor4B)colors
{
	[self setBackgroundColor: colors];
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
