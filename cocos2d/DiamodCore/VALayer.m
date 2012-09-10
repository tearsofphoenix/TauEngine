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

#import "VALayer.h"
#import "VAAnimation.h"
#import "VEDataSource.h"
#import "CGPointExtension.h"
#import "VEShaderCache.h"
#import "VEGLProgram.h"
#import "CCScheduler.h"
#import "CCDirectorIOS.h"
#import "VGContext.h"
#import "VGColor.h"
#import "ccGLStateCache.h"

@interface VALayer ()
{
@private
    VALayer *_presentationLayer;
    //cached model
    VEGLProgram *_shaderProgram;
}
@end

@interface VALayer (Private)

- (void)updateColor;

@end


@implementation VALayer

static NSMutableArray *__CCLayerAnimationStack = nil;
static VAAnimationTransaction *__currentBlockAnimationTransaction = nil;
static VEViewAnimationBlockDelegate *__animationBlockDelegate = nil;

static inline void __CCLayerPushConfiguration(VAAnimationTransaction *config)
{
    if (__currentBlockAnimationTransaction)
    {
        [__CCLayerAnimationStack addObject: __currentBlockAnimationTransaction];
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, (^
                               {
                                   __animationBlockDelegate = [[VEViewAnimationBlockDelegate alloc] init];
                               }));
    
    [__animationBlockDelegate addTransaction: config];
    
    [__CCLayerAnimationStack addObject: config];
    __currentBlockAnimationTransaction = config;
}

static inline void __CCLayerPopConfiguration(void)
{
    [__CCLayerAnimationStack removeLastObject];
    __currentBlockAnimationTransaction = [__CCLayerAnimationStack lastObject];
    if (!__currentBlockAnimationTransaction)
    {
        //should flush all animation transactions
        //
        [__animationBlockDelegate flushTransactions];
    }
}

#pragma mark - NSCoding
- (id)initWithCoder: (NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        
    }
    return self;
}

- (void)encodeWithCoder: (NSCoder *)aCoder
{
    
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
        _presentationLayer = [[[self class] alloc] init];
        [_presentationLayer setParent: [(VALayer *)[self parent] presentationLayer]];
        
        NSMutableArray *presentationSublayers = [[NSMutableArray alloc] init];
        for (VALayer *layer in (NSArray *)_children)
        {
            [presentationSublayers addObject: [layer presentationLayer]];
        }
        _presentationLayer->_children = (CFMutableArrayRef)presentationSublayers;
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
                
        [self setBackgroundColor: ccBLACK];
        
        CCDirector *director = [CCDirector sharedDirector];
		CGSize s = [director winSize];
		[self setContentSize: s];
        
        _shaderProgram = VEShaderCacheGetProgramByName(CCShaderPositionColorProgram);
        
        
	}
    
	return self;
}

#pragma mark Layer - Touch and Accelerometer related


@synthesize userInteractionEnabled = _isUserInteractionEnabled;

- (BOOL)pointInside: (CGPoint)point
          withEvent: (UIEvent *)event
{
    return CGRectContainsPoint([self bounds], point);
}

static BOOL _VALayerIgnoresTouchEvents(VALayer *layer)
{
    if (!layer->_isUserInteractionEnabled
        || !layer->_visible)
    {
        return YES;
    }
    return NO;
}

- (VALayer *)hitTest: (CGPoint)point
          withEvent: (UIEvent *)event
{
    if(_VALayerIgnoresTouchEvents(self))
    {
        return nil;
    }
    
    for (VALayer *nodeLooper in (NSArray *)_children)
    {
        if ([nodeLooper pointInside: point
                          withEvent: event])
        {
            return [nodeLooper hitTest: point
                             withEvent: event];
        }
    }
    
    return self;
}

#pragma mark Layer - Callbacks

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

@synthesize blendFunc = _blendFunc;

- (void)setContentSize: (CGSize) size
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
		squareColors_[i] = _backgroundColor ;
	}
}

- (void)drawInContext: (VGContext *)context
{
	VEGLProgramUse(_shaderProgram);
	VEGLProgramUniformForMVPMatrix(_shaderProgram, VGContextGetMVPMatrix(context));
    
	VEGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );
    
	// Attributes
	//
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, squareVertices_);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_TRUE, 0, squareColors_);
    
	CCGLBlendFunc( _blendFunc.src, _blendFunc.dst );
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	CC_INCREMENT_GL_DRAWS(1);
}


#pragma mark - Animation


/** Animation methods. **/

/* Attach an animation object to the layer. Typically this is implicitly
 * invoked through an action that is an VAAnimation object.
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

- (void)addAnimation: (VAAnimation *)anim
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
    
    VAAnimation *copy = [anim copy];
    
    [_animationKeys addObject: key];
    [_animations setObject: copy
                    forKey: key];
    
    [copy release];
        
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
    [_scheduler pauseTarget: self];
    
    [_animationKeys removeObject: key];
    [_animations removeObjectForKey: key];
    
    [_scheduler resumeTarget: self];
    
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

- (VAAnimation *)animationForKey:(NSString *)key
{
    return [_animations objectForKey: key];
}

#pragma mark - animatable properties

- (void)setPosition: (CGPoint)position
{
    if (!CGPointEqualToPoint(_position, position))
    {
        NSString *keyPath = @"position";
        [self willChangeValueForKey: keyPath];
        
        if (__currentBlockAnimationTransaction)
        {
            [_scheduler pauseTarget: self];
            
            VEBasicAnimation *animation = [VEBasicAnimation animationWithKeyPath: keyPath];
            [animation setDuration: [__currentBlockAnimationTransaction duration]];
            [animation setFromValue: [NSValue valueWithCGPoint: _position]];
            [animation setToValue: [NSValue valueWithCGPoint: position]];
            [animation setDelegate: __currentBlockAnimationTransaction];
            [animation setModelObject: self];
            
            [__currentBlockAnimationTransaction addAnimation: animation];
            
            [_scheduler resumeTarget: self];
        }
        
        [super setPosition: position];
        
        [self didChangeValueForKey: keyPath];
    }
}

- (void)setAnchorPoint: (CGPoint)anchorPoint
{
    if (!CGPointEqualToPoint(_anchorPoint, anchorPoint))
    {
        NSString *keyPath = @"anchorPoint";
        [self willChangeValueForKey: keyPath];
        
        if (__currentBlockAnimationTransaction)
        {
            [_scheduler pauseTarget: self];
            
            VEBasicAnimation *animation = [VEBasicAnimation animationWithKeyPath: keyPath];
            [animation setDuration: [__currentBlockAnimationTransaction duration]];
            [animation setFromValue: [NSValue valueWithCGPoint: _anchorPoint]];
            [animation setToValue: [NSValue valueWithCGPoint: anchorPoint]];
            [animation setDelegate: __currentBlockAnimationTransaction];
            [animation setModelObject: self];
            
            [__currentBlockAnimationTransaction addAnimation: animation];
            
            [_scheduler resumeTarget: self];
        }
        
        [super setAnchorPoint: anchorPoint];
        
        [self didChangeValueForKey: keyPath];
    }
}

- (void)setBackgroundColor: (GLKVector4)backgroundColor
{
    if (!GLKVector4AllEqualToVector4(_backgroundColor, backgroundColor))
    {
        NSString * keyPath = @"backgroundColor";
        
        if (__currentBlockAnimationTransaction)
        {
            //in block animation, pause animation update first
            //
            [_scheduler pauseTarget: self];
            
            VEBasicAnimation *animation = [VEBasicAnimation animationWithKeyPath: keyPath];
            [animation setDuration: [__currentBlockAnimationTransaction duration]];
            [animation setFromValue: [VGColor colorWithRed: _backgroundColor.r
                                                     green: _backgroundColor.g
                                                      blue: _backgroundColor.b
                                                     alpha: _backgroundColor.a]];
            
            [animation setToValue: [VGColor colorWithRed: backgroundColor.r 
                                                   green: backgroundColor.g 
                                                    blue: backgroundColor.b 
                                                   alpha: backgroundColor.a ]];
            [animation setDelegate: __currentBlockAnimationTransaction];
            [animation setModelObject: self];
            
            [__currentBlockAnimationTransaction addAnimation: animation];
            
            [_scheduler resumeTarget: self];
            
        }else
        {
            [self willChangeValueForKey: keyPath];

            _backgroundColor = backgroundColor;
            [self updateColor];
            
            [self didChangeValueForKey: keyPath];
        }
        
    }
}

- (GLKVector4)backgroundColor
{
    return _backgroundColor;
}

-(void) setOpacity: (GLfloat)opacity
{
    if (_backgroundColor.a != opacity)
    {
        [self setBackgroundColor: GLKVector4Make(_backgroundColor.r, _backgroundColor.g, _backgroundColor.b, opacity)];
    }
}

- (GLfloat)opacity
{
    return _backgroundColor.a;
}

#pragma mark - animation


+ (void)_setupAnimationWithDuration: (NSTimeInterval)duration
                              delay: (NSTimeInterval)delay
                               view: (VALayer *)layer
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
        VAAnimationTransaction *configuration = [[VAAnimationTransaction alloc] init];
        [configuration setDuration: duration];
        [configuration setDelay: delay];
        //[configuration setOptions: options];
        [configuration setStart: start];
        [configuration setCompletion: completion];
        
        __CCLayerPushConfiguration(configuration);
        
        [configuration release];
        
        animations();
        
        __CCLayerPopConfiguration();
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

+ (void)transitionWithLayer: (VALayer *)layer
                   duration: (NSTimeInterval)duration
                    options: (UIViewAnimationOptions)options
                 animations: (void (^)(void))animations
                 completion: (void (^)(BOOL finished))completion
{
    
}

+ (void)transitionFromLayer: (VALayer *)fromView
                    toLayer: (VALayer *)toView
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

- (id) initWithColor: (GLKVector4) start fadingTo: (GLKVector4) end
{
    return [self initWithColor:start fadingTo:end alongVector:ccp(0, -1)];
}

- (id) initWithColor: (GLKVector4) start
            fadingTo: (GLKVector4) end
         alongVector: (CGPoint) v
{
    if ((self = [super init]))
    {
        
        endColor_ = end;
        
        endOpacity_		= end.a;
        startOpacity_	= start.a;
        vector_ = v;
        
        start.a	= 1;
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
    
    float opacityf = _backgroundColor.a;
    
    GLKVector4 S = GLKVector4Make(
                                  _backgroundColor.r ,
                                  _backgroundColor.g ,
                                  _backgroundColor.b ,
                                  startOpacity_ * opacityf
                                  );
    
    GLKVector4 E = GLKVector4Make(
                                  endColor_.r ,
                                  endColor_.g ,
                                  endColor_.b ,
                                  endOpacity_*opacityf
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

- (GLKVector4)startColor
{
    return _backgroundColor;
}

-(void) setStartColor:(GLKVector4)colors
{
    [self setBackgroundColor: colors];
}

-(void) setEndColor:(GLKVector4)colors
{
    endColor_ = colors;
    [self updateColor];
}

-(void) setStartOpacity: (GLfloat) o
{
    startOpacity_ = o;
    [self updateColor];
}

-(void) setEndOpacity: (GLfloat) o
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

