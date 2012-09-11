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
#import "TransformUtils.h"

@interface VALayer ()
{
@private
    VALayer *_presentationLayer;
    //cached model
    VEGLProgram *_shaderProgram;
    IMP _renderInContextIMP;
    IMP _drawInContextIMP;
    
    // scaling factors
	float _scaleX, _scaleY;
    
    VACameraRef _camera;
    
    VALayer *_parent;
    
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
        
        _anchorPoint = ccp(0.5f, 0.5f);
                
        [self setBackgroundColor: ccBLACK];
        
        CCDirector *director = [CCDirector sharedDirector];
		CGSize s = [director winSize];
		[self setContentSize: s];
        
        _shaderProgram = VEShaderCacheGetProgramByName(CCShaderPositionColorProgram);
        
        _isRunning = NO;
        
		_skewX = _skewY = 0.0f;
		_rotation = 0.0f;
		_scaleX = _scaleY = 1.0f;
        _position = CGPointZero;
        _contentSize = CGSizeZero;
		_anchorPointInPoints = _anchorPoint = CGPointZero;
        
        
		// "whole screen" objects. like Scenes and Layers, should set ignoreAnchorPointForPosition to YES
		_ignoreAnchorPointForPosition = NO;
        
		_isTransformDirty = _isInverseDirty = YES;
        
		_vertexZ = 0;
        
		_visible = YES;
        
		_tag = 0;
        
		_zOrder = 0;
        
		// lazy alloc
		_camera = nil;
        
		// children (lazy allocs)
		_children = nil;
        
		//initialize parent to nil
		_parent = nil;
		
        _renderInContextIMP = [self methodForSelector: @selector(visitWithContext:)];
        _drawInContextIMP = [self methodForSelector: @selector(drawInContext:)];
        
        
        [self setScheduler: [VEDataSource serviceByIdentity: CCScheduleServiceID]];
	}
    
	return self;
}


- (void)cleanup
{
	// actions
	[_scheduler unscheduleAllSelectorsForTarget:self];
    
	// timers
    
	[(NSMutableArray *)_children makeObjectsPerformSelector: @selector(cleanup)];
}

- (NSString*)description
{
	return [NSString stringWithFormat: @"<%@ = %p | origin: %@, Tag = %ld>", [self class], self,
            [NSValue valueWithCGPoint: _position], (long)_tag];
}

- (void)dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);
    VACameraFinalize(_camera);
    
	// children
    
    [(NSArray *)_children makeObjectsPerformSelector: @selector(setParent:)
                                          withObject: nil];
    
    if (_children)
    {
        CFRelease(_children);
    }
    
	[super dealloc];
}

@synthesize visible = _visible;

@synthesize zOrder = _zOrder;
@synthesize tag = _tag;
@synthesize vertexZ = _vertexZ;
@synthesize isRunning = _isRunning;

#pragma mark VANode - Transform related properties

@synthesize rotation = _rotation;

@synthesize anchorPoint = _anchorPoint;
@synthesize anchorPointInPoints = _anchorPointInPoints;

@synthesize contentSize = _contentSize;

@synthesize ignoreAnchorPointForPosition = _ignoreAnchorPointForPosition;

@synthesize skewX = _skewX;
@synthesize skewY = _skewY;

@synthesize scheduler = _scheduler;

- (void)setScheduler: (CCScheduler *)scheduler
{
    if (_scheduler != scheduler)
    {
        [_scheduler unscheduleUpdateForTarget: self];
        _scheduler = scheduler;
    }
}

- (NSMutableArray *)children
{
    if( ! _children )
    {
        _children = CFArrayCreateMutable(CFAllocatorGetDefault(), 4, NULL);
    }
    
    return (NSMutableArray *)_children;
}


#pragma mark - Setters

- (void)setRotation: (float)newRotation
{
    if (_rotation != newRotation)
    {
        _rotation = newRotation;
        _isTransformDirty = _isInverseDirty = YES;
    }
}

- (void)setSkewX: (float)newSkewX
{
    if (_skewX != newSkewX)
    {
        _skewX = newSkewX;
        _isTransformDirty = _isInverseDirty = YES;
    }
}

- (void)setSkewY: (float)newSkewY
{
    if (_skewY != newSkewY)
    {
        _skewY = newSkewY;
        _isTransformDirty = _isInverseDirty = YES;
    }
}

- (void)setIgnoreAnchorPointForPosition: (BOOL)newValue
{
	if( newValue != _ignoreAnchorPointForPosition )
    {
		_ignoreAnchorPointForPosition = newValue;
		_isTransformDirty = _isInverseDirty = YES;
	}
}

- (void)setContentSize: (CGSize)size
{
	if( ! CGSizeEqualToSize(size, _contentSize) )
    {
		_contentSize = size;
        
		_anchorPointInPoints = ccp( _contentSize.width * _anchorPoint.x, _contentSize.height * _anchorPoint.y );
		_isTransformDirty = _isInverseDirty = YES;
        
        squareVertices_[1].x = size.width;
        squareVertices_[2].y = size.height;
        squareVertices_[3].x = size.width;
        squareVertices_[3].y = size.height;
	}
}

#pragma mark VANode Composition

// camera: lazy alloc
- (VACameraRef)camera
{
	if( ! _camera )
    {
		_camera = VACameraCreate();
	}
    
	return _camera;
}

- (void)setZOrder: (NSInteger)zOrder
{
    if (_zOrder != zOrder)
    {
        _zOrder = zOrder;
        
        [_parent sortAllChildren];
    }
}

// used internally to alter the zOrder variable. DON'T call this method manually
- (void)_setZOrder: (NSInteger) z
{
	_zOrder = z;
}


- (void)detachChild: (VALayer *)child
            cleanup: (BOOL)doCleanup
{
	// IMPORTANT:
	//  -1st do onExit
	//  -2nd cleanup
	if (_isRunning)
	{
		[child onExitTransitionDidStart];
		[child onExit];
	}
    
	// If you don't do cleanup, the child's actions will not get removed and the
	// its scheduledSelectors_ dict will not get released!
	if (doCleanup)
    {
		[child cleanup];
    }
    
	// set parent nil at the end (issue #476)
	[child setParent: nil];
    
	[(NSMutableArray *)_children removeObject:child];
}

// helper used by reorderChild & add
- (void)insertChild: (VALayer *)child
                  z: (NSInteger)z
{
    if( ! _children )
    {
        _children = CFArrayCreateMutable(CFAllocatorGetDefault(), 4, NULL);
    }
    
    CFArrayAppendValue(_children, [child retain]);
    
	[child _setZOrder:z];
    [child setParent: self];
    
    //[self sortAllChildren];
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

- (void) updateColor
{
	for( NSUInteger i = 0; i < 4; i++ )
	{
		squareColors_[i] = _backgroundColor ;
	}
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
        
        _position = position;
        _isTransformDirty = _isInverseDirty = YES;
        
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
        
		_anchorPoint = anchorPoint;
		_anchorPointInPoints = ccp( _contentSize.width * _anchorPoint.x, _contentSize.height * _anchorPoint.y );
		_isTransformDirty = _isInverseDirty = YES;
        
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

- (void)setOpacity: (GLfloat)opacity
{
    if (_opacity != opacity)
    {
        _opacity = opacity;
        
        [self setBackgroundColor: GLKVector4Make(_backgroundColor.r, _backgroundColor.g, _backgroundColor.b, _opacity)];
        for (VALayer *layerLooper in (NSArray *)_children)
        {
            [layerLooper setOpacity: opacity];
        }
    }
}

- (GLfloat)opacity
{
    return _opacity;
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


#pragma mark - VANode Draw

@implementation  VALayer (CCNodeRendering)

- (void)drawInContext: (VGContext *)context
{
	VEGLProgramUse(_shaderProgram);
	VEGLProgramUniformForMVPMatrix(_shaderProgram, VGContextGetMVPMatrix(context));
    
	VEGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );
    
	// Attributes
	//
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, squareVertices_);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_TRUE, 0, squareColors_);
    
	//CCGLBlendFunc( _blendFunc.src, _blendFunc.dst );
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	CC_INCREMENT_GL_DRAWS(1);
}

- (void)visitWithContext: (VGContext *)context
{
	// quick return if not visible. children won't be drawn.
	if (_visible)
    {
        VGContextSaveState(context);
        
        [self transformInContext: context];
        
        _drawInContextIMP(self, @selector(drawInContext:), context);
        
        if(_children)
        {
            for(CFIndex i = 0 ; i < CFArrayGetCount(_children); i++ )
            {
                VALayer *child =  CFArrayGetValueAtIndex(_children, i);
                _renderInContextIMP(child, _cmd, context);
            }
        }
        
        VGContextRestoreState(context);
    }
}

@end

#pragma mark - VANode - SceneManagement

@implementation VALayer (CCNodeHierarchy)

#pragma mark VANode - Transformations

- (void)setParent: (VALayer *)parent
{
    if (_parent != parent)
    {
        _parent = parent;
    }
}

- (VALayer *)parent
{
    return _parent;
}

- (void)onEnter
{
	[(NSArray *)_children makeObjectsPerformSelector:@selector(onEnter)];
    
    [_scheduler resumeTarget: self];
    
	_isRunning = YES;
}

- (void)onExitTransitionDidStart
{
	[(NSArray *)_children makeObjectsPerformSelector: @selector(onExitTransitionDidStart)];
}

- (void)onExit
{
    [_scheduler pauseTarget: self];
    
	_isRunning = NO;
    
	[(NSArray *)_children makeObjectsPerformSelector:@selector(onExit)];
}

/* "add" logic MUST only be on this method
 * If a class want's to extend the 'addChild' behaviour it only needs
 * to override this method
 */

- (void)addChild: (VALayer *)child
{
    NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( [child parent] == nil, @"child already added. It can't be added again");
    
	[self insertChild: child
                    z: [child zOrder]];
    
	if( _isRunning )
    {
		[child onEnter];
	}
    
    [child setOpacity: _opacity];
}

- (void)removeFromParentAndCleanup: (BOOL)cleanup
{
	[_parent removeChild: self
                 cleanup: cleanup];
}

/* "remove" logic MUST only be on this method
 * If a class want's to extend the 'removeChild' behavior it only needs
 * to override this method
 */
- (void)removeChild: (VALayer *)child
            cleanup: (BOOL)cleanup
{
	if (child && CFArrayContainsValue(_children, CFRangeMake(0, CFArrayGetCount(_children)), child))
    {
		[self detachChild: child
                  cleanup: cleanup];
    }
}

- (void)removeAllChildrenWithCleanup: (BOOL)cleanup
{
	// not using detachChild improves speed here
    
	for(VALayer *c in (NSArray *)_children)
	{
		// IMPORTANT:
		//  -1st do onExit
		//  -2nd cleanup
		if (_isRunning)
		{
			[c onExitTransitionDidStart];
			[c onExit];
		}
        
		if (cleanup)
        {
			[c cleanup];
        }
		// set parent nil at the end (issue #476)
		[c setParent:nil];
	}
    
    [(NSMutableArray *)_children removeAllObjects];
}

- (void) sortAllChildren
{
    [(NSMutableArray *)_children sortUsingComparator: (^NSComparisonResult(VALayer *obj1, VALayer *obj2)
                                                       {
                                                           NSInteger z1 = [obj1 zOrder];
                                                           NSInteger z2 = [obj2 zOrder];
                                                           if (z1 < z2)
                                                           {
                                                               return NSOrderedAscending;
                                                           }
                                                           if (z1 > z2)
                                                           {
                                                               return NSOrderedDescending;
                                                           }
                                                           return NSOrderedSame;
                                                       })];
}

@end

#pragma mark - VANode Geometry

@implementation VALayer (CCNodeGeometry)

- (CGRect)bounds
{
	CGRect rect = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
	return CGRectApplyAffineTransform(rect, [self nodeToParentTransform]);
}

- (void)setBounds: (CGRect)bounds
{
    [self setPosition: bounds.origin];
    [self setContentSize: bounds.size];
}

-(float) scale
{
	NSAssert( _scaleX == _scaleY, @"VANode#scale. ScaleX != ScaleY. Don't know which one to return");
	return _scaleX;
}

- (void)setScale: (float) s
{
	_scaleX = _scaleY = s;
	_isTransformDirty = _isInverseDirty = YES;
}

- (void)setScaleX: (float)newScaleX
{
    if (_scaleX != newScaleX)
    {
        _scaleX = newScaleX;
        _isTransformDirty = _isInverseDirty = YES;
    }
}

- (float)scaleX
{
    return _scaleX;
}

- (void)setScaleY: (float)newScaleY
{
    if (_scaleY != newScaleY)
    {
        _scaleY = newScaleY;
        _isTransformDirty = _isInverseDirty = YES;
    }
}

- (float)scaleY
{
    return _scaleY;
}

- (CGPoint)position
{
    return _position;
}

- (void)transformInContext: (VGContext *)context
{
	GLKMatrix4 transfrom4x4;
    
	// Convert 3x3 into 4x4 matrix
	CGAffineTransform tmpAffine = [self nodeToParentTransform];
    
	CGAffineToGL(&tmpAffine, transfrom4x4.m);
    
	// Update Z vertex manually
	transfrom4x4.m[14] = _vertexZ;
    
	VGContextConcatCTM(context, transfrom4x4 );
    
    
	// XXX: Expensive calls. Camera should be integrated into the cached affine matrix
	if ( _camera )
	{
		BOOL needTranslate = !CGPointEqualToPoint(_anchorPoint, CGPointZero);
        
		if( needTranslate )
        {
			VGContextTranslateCTM(context, _anchorPointInPoints.x, _anchorPointInPoints.y, 0 );
            
            VGContextConcatCTM(context, VACameraGetLookAtMatrix(_camera));
            
			VGContextTranslateCTM(context, -_anchorPointInPoints.x, -_anchorPointInPoints.y, 0 );
            
        }else
        {
            VGContextConcatCTM(context, VACameraGetLookAtMatrix(_camera));
        }
	}
}

- (CGAffineTransform)nodeToParentTransform
{
	if ( _isTransformDirty )
    {
        
		// Translate values
		float x = _position.x;
		float y = _position.y;
        
		if ( _ignoreAnchorPointForPosition )
        {
			x += _anchorPointInPoints.x;
			y += _anchorPointInPoints.y;
		}
        
		// Rotation values
		float c = 1, s = 0;
		if( _rotation )
        {
			c = cosf(- _rotation);
			s = sinf(- _rotation);
		}
        
		BOOL needsSkewMatrix = ( _skewX || _skewY );
        
        
		// optimization:
		// inline anchor point calculation if skew is not needed
		
        if( !needsSkewMatrix && !CGPointEqualToPoint(_anchorPointInPoints, CGPointZero) )
        {
			x += c * -_anchorPointInPoints.x * _scaleX + -s * -_anchorPointInPoints.y * _scaleY;
			y += s * -_anchorPointInPoints.x * _scaleX +  c * -_anchorPointInPoints.y * _scaleY;
		}
        
        
		// Build Transform Matrix
		_transform = CGAffineTransformMake( c * _scaleX,  s * _scaleX,
										   -s * _scaleY, c * _scaleY,
										   x, y );
        
		// XXX: Try to inline skew
		// If skew is needed, apply skew and then anchor point
		if( needsSkewMatrix )
        {
			CGAffineTransform skewMatrix = CGAffineTransformMake(1.0f, tanf(_skewY),
																 tanf(_skewX), 1.0f,
																 0.0f, 0.0f );
			_transform = CGAffineTransformConcat(skewMatrix, _transform);
            
			// adjust anchor point
			if( ! CGPointEqualToPoint(_anchorPointInPoints, CGPointZero) )
            {
				_transform = CGAffineTransformTranslate(_transform, -_anchorPointInPoints.x, -_anchorPointInPoints.y);
            }
		}
        
		_isTransformDirty = NO;
	}
    
	return _transform;
}

- (CGAffineTransform)parentToNodeTransform
{
	if ( _isInverseDirty )
    {
		_inverse = CGAffineTransformInvert([self nodeToParentTransform]);
		_isInverseDirty = NO;
	}
    
	return _inverse;
}

- (CGAffineTransform)nodeToWorldTransform
{
	CGAffineTransform t = [self nodeToParentTransform];
    
	for (VALayer *p = _parent; p != nil; p = p->_parent)
    {
		t = CGAffineTransformConcat(t, [p nodeToParentTransform]);
    }
    
	return t;
}

- (CGAffineTransform)worldToNodeTransform
{
	return CGAffineTransformInvert([self nodeToWorldTransform]);
}

- (CGPoint)convertToNodeSpace: (CGPoint)worldPoint
{
	CGPoint ret = CGPointApplyAffineTransform(worldPoint, [self worldToNodeTransform]);
	return ret;
}

- (CGPoint)convertToWorldSpace: (CGPoint)nodePoint
{
	CGPoint ret = CGPointApplyAffineTransform(nodePoint, [self nodeToWorldTransform]);
	return ret;
}

- (CGPoint)convertToNodeSpaceAR: (CGPoint)worldPoint
{
	CGPoint nodePoint = [self convertToNodeSpace:worldPoint];
	return ccpSub(nodePoint, _anchorPointInPoints);
}

- (CGPoint)convertToWorldSpaceAR: (CGPoint)nodePoint
{
	nodePoint = ccpAdd(nodePoint, _anchorPointInPoints);
	return [self convertToWorldSpace:nodePoint];
}

- (CGPoint)convertToWindowSpace: (CGPoint)nodePoint
{
    CGPoint worldPoint = [self convertToWorldSpace:nodePoint];
	return [[CCDirector sharedDirector] convertToUI:worldPoint];
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

