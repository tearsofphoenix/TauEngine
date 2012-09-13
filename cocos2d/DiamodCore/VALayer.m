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
#import "VALayer+Private.h"
#import "VAAnimation.h"
#import "VEDataSource.h"
#import "CGPointExtension.h"
#import "CCScheduler.h"
#import "VGContext.h"
#import "VGColor.h"
#import "ccGLStateCache.h"
#import "TransformUtils.h"
#import "VGColor.h"
#import "VALayer+Private.h"
#import "OpenGLInternal.h"
#import "VEDirector.h"

@interface VALayer ()
{
@private
    VALayer *_presentationLayer;
    //cached model
    //VEGLProgram *_shaderProgram;
    GLKBaseEffect *_effect;
    // scaling factors
	float _scaleX, _scaleY;
    
    VACameraRef _camera;

    GLKVector2 _vertices[4];
}

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

+ (id)layer
{
    return [[[self alloc] init] autorelease];
}

- (id)presentationLayer
{
    if (!_presentationLayer)
    {
        _presentationLayer = [[[self class] alloc] init];
        _presentationLayer->_superlayer =  [[[self superlayer] presentationLayer] retain];
        
        NSMutableArray *presentationSublayers = [[NSMutableArray alloc] init];
        for (VALayer *layer in _sublayers)
        {
            [presentationSublayers addObject: [layer presentationLayer]];
        }
        _presentationLayer->_sublayers = presentationSublayers;
    }
    
    return _presentationLayer;
}

- (id)modelLayer
{
    return self;
}

/* TODO: list all properties below */
static NSString * s_VALayerInitializationKeys[] =
{
    @"anchorPoint", @"transform", @"sublayerTransform",
    @"opacity", @"delegate", @"contentsRect", @"shouldRasterize",
    @"backgroundColor",
    
    @"beginTime", @"duration", @"speed", @"autoreverses",
    @"repeatCount",
    
    @"shadowColor", @"shadowOffset", @"shadowOpacity",
    @"shadowPath", @"shadowRadius",
    
    @"bounds", @"position"
};

- (id)init
{
	if( (self=[super init]) )
    {
		_scaleX = _scaleY = 1.0f;
        _position = CGPointZero;
        _contentSize = CGSizeZero;
		_anchorPointInPoints = _anchorPoint = CGPointZero;
                
        _attr = calloc(1, sizeof(struct VALayerAttribute));
        _sublayers = [[NSMutableArray alloc] init];
        _animations = [[NSMutableDictionary alloc] init];
        _animationKeys = [[NSMutableArray alloc] init];
        //_shaderProgram = VEShaderCacheGetProgramByName(CCShaderPositionColorProgram);
        
        _effect = [[GLKBaseEffect alloc] init];
        [[_effect transform] setProjectionMatrix: GLKMatrix4MakeOrtho(0, 1024, 0, 768, -1024, 1024)];
        [_effect setUseConstantColor: GL_TRUE];
        [_effect setConstantColor: GLKVector4Make(1.0, 0, 0, 1)];
                
        _camera = VACameraCreate();
        
        [self setBounds: CGRectMake(0, 0, 1024, 768)];
        
        for (int i = 0; i < sizeof(s_VALayerInitializationKeys)/sizeof(s_VALayerInitializationKeys[0]); i++)
        {
            id defaultValue = [[self class] defaultValueForKey: s_VALayerInitializationKeys[i]];
            if (defaultValue)
            {
                [self setValue: defaultValue
                        forKey: s_VALayerInitializationKeys[i]];
            }
        }
        
        
	}
	return self;
}

- (id)initWithLayer: (id)layer
{
    if ((self = [super init]))
    {
        
    }
    return self;
}

- (void)dealloc
{
    free(_attr);
    
    [self removeAllAnimations];
    
    [_animationKeys release];
    [_animations release];
    
    [_sublayers makeObjectsPerformSelector: @selector(removeFromSuperlayer)];
    [_sublayers release];
    
    
    [super dealloc];
}

#pragma mark - VALayer (Property)

/* VALayer implements the standard NSKeyValueCoding protocol for all
 * Objective C properties defined by the class and its subclasses. It
 * dynamically implements missing accessor methods for properties
 * declared by subclasses.
 *
 * When accessing properties via KVC whose values are not objects, the
 * standard KVC wrapping conventions are used, with extensions to
 * support the following types:
 *
 *	C Type			Class
 *      ------			-----
 *	CGPoint			NSValue
 *	CGSize			NSValue
 *	CGRect			NSValue
 *	CGAffineTransform	NSValue
 *	CATransform3D		NSValue  */

/* Returns the default value of the named property, or nil if no
 * default value is known. Subclasses that override this method to
 * define default values for their own properties should call `super'
 * for unknown properties. */

static NSMutableDictionary *s_VALayerDefaultValues = nil;

+ (void)load
{
    if (!__CCLayerAnimationStack)
    {
        __CCLayerAnimationStack = [[NSMutableArray alloc] initWithCapacity: 10];
    }
    
    if (!s_VALayerDefaultValues)
    {
        s_VALayerDefaultValues = [[NSMutableDictionary alloc] init];
        [s_VALayerDefaultValues setObject: [NSValue valueWithCGPoint: CGPointMake(0.5, 0.5)]
                                   forKey: @"anchorPoint"];
        [s_VALayerDefaultValues setObject: [NSValue valueWithCATransform3D: CATransform3DIdentity]
                                   forKey: @"transform"];
        [s_VALayerDefaultValues setObject: [NSValue valueWithCATransform3D: CATransform3DIdentity]
                                   forKey: @"sublayerTransform"];
        [s_VALayerDefaultValues setObject: [NSNumber numberWithBool: NO]
                                   forKey: @"shouldRasterize"];
        [s_VALayerDefaultValues setObject: [NSNumber numberWithFloat: 1.0]
                                   forKey: @"opacity"];
        [s_VALayerDefaultValues setObject: [NSValue valueWithCGRect: CGRectMake(0, 0, 1, 1)]
                                   forKey: @"contentsRect"];
        [s_VALayerDefaultValues setObject: [NSValue valueWithCGSize: CGSizeMake(0, -3)]
                                   forKey: @"shadowOffset"];
        [s_VALayerDefaultValues setObject: [NSNumber numberWithFloat: 3.0]
                                   forKey: @"shadowRadius"];
        
        /* CAMediaTiming */
        
        [s_VALayerDefaultValues setObject: [NSNumber numberWithFloat: __builtin_inf()]
                                   forKey: @"duration"];
        [s_VALayerDefaultValues setObject: [NSNumber numberWithFloat: 1.0]
                                   forKey: @"speed"];
        [s_VALayerDefaultValues setObject: [NSNumber numberWithBool: NO]
                                   forKey: @"autoreverses"];
        [s_VALayerDefaultValues setObject: [NSNumber numberWithFloat: 1.0]
                                   forKey: @"repeatCount"];
        [s_VALayerDefaultValues setObject: [NSNumber numberWithFloat: 0.0]
                                   forKey: @"beginTime"];
    }
}

+ (id)defaultValueForKey:(NSString *)key
{
    return [s_VALayerDefaultValues objectForKey: key];
}

/* Method for subclasses to override. Returning true for a given
 * property causes the layer's contents to be redrawn when the property
 * is changed (including when changed by an animation attached to the
 * layer). The default implementation returns NO. Subclasses should
 * call super for properties defined by the superclass. (For example,
 * do not try to return YES for properties implemented by VALayer,
 * doing will have undefined results.) */

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    return NO;
}

/* Called by the object's implementation of -encodeWithCoder:, returns
 * false if the named property should not be archived. The base
 * implementation returns YES. Subclasses should call super for
 * unknown properties. */

- (BOOL)shouldArchiveValueForKey:(NSString *)key
{
    return YES;
}

#pragma mark -  VALayer (Geometry)

/* The bounds of the layer. Defaults to CGRectZero. Animatable. */
- (void) setBounds: (CGRect)bounds
{
    if (!CGRectEqualToRect(bounds, _bounds))
    {
        return;
        
        [self willChangeValueForKey: @"bounds"];
        _bounds = bounds;
        
        _vertices[0] =  GLKVector2Make(0, 0);
        _vertices[1] =  GLKVector2Make(1, 0);
        _vertices[2] =  GLKVector2Make(0, 1);
        _vertices[3] =  GLKVector2Make(1, 1);

//        _quad.bl.geometryVertex = CGPointMake(0, 0);
//        _quad.br.geometryVertex = CGPointMake(_bounds.size.width, 0);
//        _quad.tl.geometryVertex = CGPointMake(0, _bounds.size.height);
//        _quad.tr.geometryVertex = CGPointMake(_bounds.size.width, _bounds.size.height);

        [self didChangeValueForKey: @"bounds"];
        
        if ([self needsDisplayOnBoundsChange])
        {
            [self setNeedsDisplay];
        }
    }
}

- (CGRect)bounds
{
    return _bounds;
}

/* The position in the superlayer that the anchor point of the layer's
 * bounds rect is aligned to. Defaults to the zero point. Animatable. */

- (void)setPosition: (CGPoint)position
{
    if(!CGPointEqualToPoint(_position, position))
    {
        [self willChangeValueForKey: @"position"];
        
        _position = position;
        
        [self didChangeValueForKey: @"postition"];
    }
}

- (CGPoint)position
{
    return _position;
}

/* The Z component of the layer's position in its superlayer. Defaults
 * to zero. Animatable. */
- (void)setZPosition:(CGFloat)zPosition
{
    if(!_zPosition != zPosition)
    {
        [self willChangeValueForKey: @"zPosition"];
        
        _zPosition = zPosition;
        
        [self didChangeValueForKey: @"zPosition"];
    }
    
}

- (CGFloat)zPosition
{
    return _zPosition;
}

/* Defines the anchor point of the layer's bounds rect, as a point in
 * normalized layer coordinates - '(0, 0)' is the bottom left corner of
 * the bounds rect, '(1, 1)' is the top right corner. Defaults to
 * '(0.5, 0.5)', i.e. the center of the bounds rect. Animatable. */
- (void)setAnchorPoint: (CGPoint)anchorPoint
{
    if(!CGPointEqualToPoint(_anchorPoint, anchorPoint))
    {
        [self willChangeValueForKey: @"anchorPoint"];
        
        _anchorPoint = anchorPoint;
        
        [self didChangeValueForKey: @"anchorPoint"];
    }
}

- (CGPoint)anchorPoint
{
    return _anchorPoint;
}

/* The Z component of the layer's anchor point (i.e. reference point for
 * position and transform). Defaults to zero. Animatable. */

- (void)setAnchorPointZ: (CGFloat)anchorPointZ
{
    if(_anchorPointZ != anchorPointZ)
    {
        [self willChangeValueForKey: @"anchorPointZ"];
        
        _anchorPointZ = anchorPointZ;
        
        [self didChangeValueForKey: @"anchorPointZ"];
    }
    
}

- (CGFloat)anchorPointZ
{
    return _anchorPointZ;
}

/* A transform applied to the layer relative to the anchor point of its
 * bounds rect. Defaults to the identity transform. Animatable. */

- (void)setTransform: (CATransform3D)transform
{
    if(!CATransform3DEqualToTransform(_transform, transform))
    {
        [self willChangeValueForKey: @"transform"];
        
        _transform = transform;
        
        [self didChangeValueForKey: @"transform"];
    }
}

- (CATransform3D)transform
{
    return _transform;
}

/* Convenience methods for accessing the `transform' property as an
 * affine transform. */

- (CGAffineTransform)affineTransform
{
    return CATransform3DGetAffineTransform(_transform);
}

- (void)setAffineTransform: (CGAffineTransform)m
{
    [self setTransform: CATransform3DMakeAffineTransform(m)];
}

/* Unlike NSView, each Layer in the hierarchy has an implicit frame
 * rectangle, a function of the `position', `bounds', `anchorPoint',
 * and `transform' properties. When setting the frame the `position'
 * and `bounds.size' are changed to match the given frame. */

- (void)setFrame: (CGRect)frame
{
    if(!CGRectEqualToRect(_frame, frame))
    {
        [self willChangeValueForKey: @"frame"];
        
        _frame = frame;
        
        [self didChangeValueForKey: @"frame"];
    }
    
}

- (CGRect)frame
{
    return _frame;
}


/* When true the layer and its sublayers are not displayed. Defaults to
 * NO. Animatable. */

- (void)setHidden: (BOOL)hidden
{
    if(_attr->_isHidden != hidden)
    {
        [self willChangeValueForKey: @"hidden"];
        
        _attr->_isHidden = hidden;
        
        [self didChangeValueForKey: @"hidden"];
    }
}

- (BOOL)isHidden
{
    return _attr->_isHidden;
}

/* When false layers facing away from the viewer are hidden from view.
 * Defaults to YES. Animatable. */

- (void)setDoubleSided: (BOOL)doubleSided
{
    if(_doubleSided != doubleSided)
    {
        [self willChangeValueForKey: @"doubleSided"];
        
        _doubleSided = doubleSided;
        
        [self didChangeValueForKey: @"doubleSided"];
    }
}

- (BOOL)isDoubleSided
{
    return _doubleSided;
}

/* Whether or not the geometry of the layer (and its sublayers) is
 * flipped vertically. Defaults to NO. Note that even when geometry is
 * flipped, image orientation remains the same (i.e. a CGImageRef
 * stored in the `contents' property will display the same with both
 * flipped=NO and flipped=YES, assuming no transform on the layer). */

- (void)setGeometryFlipped: (BOOL)geometryFlipped
{
    if(_attr->_isGeometryFlipped != geometryFlipped)
    {
        [self willChangeValueForKey: @"geometryFlipped"];
        
        _attr->_isGeometryFlipped = geometryFlipped;
        
        [self didChangeValueForKey: @"geometryFlipped"];
    }
}

- (BOOL)isGeometryFlipped
{
    return _attr->_isGeometryFlipped;
}

/* Returns true if the contents of the contents property of the layer
 * will be implicitly flipped when rendered in relation to the local
 * coordinate space (e.g. if there are an odd number of layers with
 * flippedGeometry=YES from the receiver up to and including the
 * implicit container of the root layer). Subclasses should not attempt
 * to redefine this method. When this method returns true the
 * CGContextRef object passed to -drawInContext: by the default
 * -display method will have been y- flipped (and rectangles passed to
 * -setNeedsDisplayInRect: will be similarly flipped). */

- (BOOL)contentsAreFlipped
{
    return NO;
}

/* The receiver's superlayer object. Implicitly changed to match the
 * hierarchy described by the `sublayers' properties. */

- (VALayer *)superlayer
{
    return _superlayer;
}

/* Removes the layer from its superlayer, works both if the receiver is
 * in its superlayer's `sublayers' array or set as its `mask' value. */

- (void)removeFromSuperlayer
{
    if(_superlayer)
    {
        [_superlayer->_sublayers removeObject: self];
        _superlayer = nil;
    }
}

/* The array of sublayers of this layer. The layers are listed in back
 * to front order. Defaults to nil. When setting the value of the
 * property, any newly added layers must have nil superlayers, otherwise
 * the behavior is undefined. Note that the returned array is not
 * guaranteed to retain its elements. */

- (void)setSublayers: (NSArray *)sublayers
{
    if(_sublayers != sublayers)
    {
        [self willChangeValueForKey: @"sublayers"];
        
        [_sublayers setArray: sublayers];
        
        [self didChangeValueForKey: @"sublayers"];
    }
}

/* Add 'layer' to the end of the receiver's sublayers array. If 'layer'
 * already has a superlayer, it will be removed before being added. */

- (void)addSublayer: (VALayer *)layer
{
    if(layer)
    {
        [layer removeFromSuperlayer];
        
        [_sublayers addObject: layer];
        layer->_superlayer = self;
    }
}

/* Insert 'layer' at position 'idx' in the receiver's sublayers array.
 * If 'layer' already has a superlayer, it will be removed before being
 * inserted. */

- (void)insertSublayer: (VALayer *)layer
               atIndex: (unsigned)idx
{
    if(layer)
    {
        [layer removeFromSuperlayer];
        [_sublayers insertObject: layer
                         atIndex: idx];
        layer->_superlayer = self;
    }
}

/* Insert 'layer' either above or below the specified layer in the
 * receiver's sublayers array. If 'layer' already has a superlayer, it
 * will be removed before being inserted. */

- (void)insertSublayer:(VALayer *)layer
                 below:(VALayer *)sibling
{
    NSInteger index = [_sublayers indexOfObject: sibling];
    [self insertSublayer: layer
                 atIndex: index];
}

- (void)insertSublayer: (VALayer *)layer
                 above: (VALayer *)sibling
{
    NSInteger index = [_sublayers indexOfObject: sibling];
    [self insertSublayer: layer
                 atIndex: index + 1];
}

/* Remove 'layer' from the sublayers array of the receiver and insert
 * 'layer2' if non-nil in its position. If the superlayer of 'layer'
 * is not the receiver, the behavior is undefined. */

- (void)replaceSublayer:(VALayer *)layer
                   with:(VALayer *)layer2
{
    NSInteger index = [_sublayers indexOfObject: layer];
    [layer removeFromSuperlayer];
    
    [_sublayers replaceObjectAtIndex: index
                          withObject: layer2];
    layer2->_superlayer = self;
}

/* A transform applied to each member of the `sublayers' array while
 * rendering its contents into the receiver's output. Typically used as
 * the projection matrix to add perspective and other viewing effects
 * into the model. Defaults to identity. Animatable. */

- (void)setSublayerTransform:(CATransform3D)sublayerTransform
{
    if(!CATransform3DEqualToTransform(_sublayerTransform, sublayerTransform))
    {
        [self willChangeValueForKey: @"sublayerTransform"];
        
        _sublayerTransform = sublayerTransform;
        
        [self didChangeValueForKey: @"sublayerTransform"];
    }
}

- (CATransform3D)sublayerTransform
{
    return _sublayerTransform;
}

/* A layer whose alpha channel is used as a mask to select between the
 * layer's background and the result of compositing the layer's
 * contents with its filtered background. Defaults to nil. When used as
 * a mask the layer's `compositingFilter' and `backgroundFilters'
 * properties are ignored. When setting the mask to a new layer, the
 * new layer must have a nil superlayer, otherwise the behavior is
 * undefined. */
- (void)setMask: (VALayer *)mask
{
    if(_maskLayer != mask)
    {
        [self willChangeValueForKey: @"mask"];
        
        [_maskLayer release];
        _maskLayer = [mask retain];
        
        [self didChangeValueForKey: @"mask"];
    }
}

- (VALayer *)mask
{
    return _maskLayer;
}

/* When true an implicit mask matching the layer bounds is applied to
 * the layer (including the effects of the `cornerRadius' property). If
 * both `mask' and `masksToBounds' are non-nil the two masks are
 * multiplied to get the actual mask values. Defaults to NO.
 * Animatable. */

- (void)setMasksToBounds: (BOOL)masksToBounds
{
    if(_attr->_masksToBounds != masksToBounds)
    {
        [self willChangeValueForKey: @"masksToBounds"];
        
        _attr->_masksToBounds = masksToBounds;
        
        [self didChangeValueForKey: @"masksToBounds"];
    }
}

- (BOOL)masksToBounds
{
    return _attr->_masksToBounds;
}

#pragma mark - VALayer (CoordinateMapping)

- (CGAffineTransform)nodeToParentTransform
{
    CGAffineTransform affineTransform; // = CGAffineTransformIdentity;
    
	if ( !_attr->_isTransformClean )
    {
        
		// Translate values
		float x = _position.x + _anchorPointInPoints.x;
		float y = _position.y + _anchorPointInPoints.y;
                
		// Rotation values
		float c = 1, s = 0;
        
		BOOL needsSkewMatrix = NO;
        
        
		// optimization:
		// inline anchor point calculation if skew is not needed
		
        if( !needsSkewMatrix && !CGPointEqualToPoint(_anchorPointInPoints, CGPointZero) )
        {
			x += c * -_anchorPointInPoints.x * _scaleX + -s * -_anchorPointInPoints.y * _scaleY;
			y += s * -_anchorPointInPoints.x * _scaleX +  c * -_anchorPointInPoints.y * _scaleY;
		}
        
        
		// Build Transform Matrix
		affineTransform = CGAffineTransformMake( c * _scaleX,  s * _scaleX,
                                                -s * _scaleY, c * _scaleY,
                                                x, y );
        
		_attr->_isTransformClean = YES;
	}
    
	return affineTransform;
}

- (CGAffineTransform)parentToNodeTransform
{
	if ( !_attr->_isInverseClean )
    {
		_inverse = CGAffineTransformInvert([self nodeToParentTransform]);
		_attr->_isInverseClean = YES;
	}
    
	return _inverse;
}

- (CGAffineTransform)nodeToWorldTransform
{
	CGAffineTransform t = [self nodeToParentTransform];
    
	for (VALayer *p = _superlayer; p != nil; p = p->_superlayer)
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
	return [[VEDirector sharedDirector] convertToUI:worldPoint];
}

- (CGPoint)convertPoint: (CGPoint)p
              fromLayer: (VALayer *)l
{
    return CGPointApplyAffineTransform(p, [l affineTransform]);
}

- (CGPoint)convertPoint: (CGPoint)p
                toLayer: (VALayer *)l
{
    return [l convertPoint: p
                 fromLayer: self];
}

- (CGRect)convertRect:(CGRect)r
            fromLayer:(VALayer *)l
{
    return CGRectApplyAffineTransform(r, [l affineTransform]);
}

- (CGRect)convertRect:(CGRect)r toLayer:(VALayer *)l
{
    return [l convertRect: r
                fromLayer: self];
}

- (CFTimeInterval)convertTime:(CFTimeInterval)t fromLayer:(VALayer *)l
{
    return 0;
}

- (CFTimeInterval)convertTime:(CFTimeInterval)t toLayer:(VALayer *)l
{
    return 0;
}

#pragma mark - VALayer (HitTest)

static BOOL _VALayerIgnoresTouchEvents(VALayer *layer)
{
    if (layer->_attr->_isUserInteractionDisabled
        || layer->_attr->_isHidden
        || layer->_opacity < 0.01)
    {
        return YES;
    }
    return NO;
}

/* Returns the farthest descendant of the layer containing point 'p'.
 * Siblings are searched in top-to-bottom order. 'p' is defined to be
 * in the coordinate space of the receiver's nearest ancestor that
 * isn't a CATransformLayer (transform layers don't have a 2D
 * coordinate space in which the point could be specified). */

- (VALayer *)hitTest: (CGPoint)p
{
    if(_VALayerIgnoresTouchEvents(self))
    {
        return nil;
    }
    
    __block VALayer *responsibleLayer = self;
    
    [_sublayers enumerateObjectsWithOptions: NSEnumerationReverse
                                 usingBlock: (^(VALayer *obj, NSUInteger idx, BOOL *stop)
                                              {
                                                  if ([obj containsPoint: p])
                                                  {
                                                      VALayer *layer = [obj hitTest: p];
                                                      if (layer)
                                                      {
                                                          responsibleLayer = layer;
                                                          *stop = YES;
                                                      }
                                                  }
                                                  
                                              })];
    
    return responsibleLayer;
}

/* Returns true if the bounds of the layer contains point 'p'. */

- (BOOL)containsPoint:(CGPoint)p
{
    return CGRectContainsPoint(_bounds, p);
}

#pragma mark - VALayer (ContentProperties)

/* An object providing the contents of the layer, typically a CGImageRef,
 * but may be something else. (For example, NSImage objects are
 * supported on Mac OS X 10.6 and later.) Default value is nil.
 * Animatable. */

- (void)setContents: (id)contents
{
    if(_contents != contents)
    {
        [self willChangeValueForKey: @"contents"];
        
        [_contents release];
        _contents = [contents retain];
        
        [self didChangeValueForKey: @"contents"];
    }
}

- (id)contents
{
    return _contents;
}

/* A rectangle in normalized image coordinates defining the
 * subrectangle of the `contents' property that will be drawn into the
 * layer. If pixels outside the unit rectangles are requested, the edge
 * pixels of the contents image will be extended outwards. If an empty
 * rectangle is provided, the results are undefined. Defaults to the
 * unit rectangle [0 0 1 1]. Animatable. */

- (void)setContentsRect: (CGRect)contentsRect
{
    if (!CGRectEqualToRect(_contentsRect, contentsRect))
    {
        [self willChangeValueForKey: @"contentsRect"];
        
        _contentsRect = contentsRect;
        
        [self didChangeValueForKey: @"contentsRect"];
    }
}

- (CGRect)contentsRect
{
    return _contentsRect;
}

/* A string defining how the contents of the layer is mapped into its
 * bounds rect. Options are `center', `top', `bottom', `left',
 * `right', `topLeft', `topRight', `bottomLeft', `bottomRight',
 * `resize', `resizeAspect', `resizeAspectFill'. The default value is
 * `resize'. Note that "bottom" always means "Minimum Y" and "top"
 * always means "Maximum Y". */

- (void)setContentsGravity: (NSString *)contentsGravity
{
    if(![_contentsGravity isEqualToString: contentsGravity])
    {
        [self willChangeValueForKey: @"contentsGravity"];
        
        [_contentsGravity release];
        _contentsGravity = [contentsGravity copy];
        
        [self didChangeValueForKey: @"contentsGravity"];
    }
}

- (NSString *)contentsGravity
{
    return _contentsGravity;
}

/* Defines the scale factor applied to the contents of the layer. If
 * the physical size of the contents is '(w, h)' then the logical size
 * (i.e. for contentsGravity calculations) is defined as '(w /
 * contentsScale, h / contentsScale)'. Applies to both images provided
 * explicitly and content provided via -drawInContext: (i.e. if
 * contentsScale is two -drawInContext: will draw into a buffer twice
 * as large as the layer bounds). Defaults to one. Animatable. */

- (void)setContentsScale: (CGFloat)contentsScale
{
    if(_contentsScale != contentsScale)
    {
        [self willChangeValueForKey: @"contentsScale"];
        
        _contentsScale = contentsScale;
        
        [self didChangeValueForKey: @"contentsScale"];
    }
}

- (CGFloat)contentsScale
{
    return _contentsScale;
}

/* A rectangle in normalized image coordinates defining the scaled
 * center part of the `contents' image.
 *
 * When an image is resized due to its `contentsGravity' property its
 * center part implicitly defines the 3x3 grid that controls how the
 * image is scaled to its drawn size. The center part is stretched in
 * both dimensions; the top and bottom parts are only stretched
 * horizontally; the left and right parts are only stretched
 * vertically; the four corner parts are not stretched at all. (This is
 * often called "9-slice scaling".)
 *
 * The rectangle is interpreted after the effects of the `contentsRect'
 * property have been applied. It defaults to the unit rectangle [0 0 1
 * 1] meaning that the entire image is scaled. As a special case, if
 * the width or height is zero, it is implicitly adjusted to the width
 * or height of a single source pixel centered at that position. If the
 * rectangle extends outside the [0 0 1 1] unit rectangle the result is
 * undefined. Animatable. */

- (void)setContentsCenter: (CGRect)contentsCenter
{
    if(!CGRectEqualToRect(_contentsCenter, contentsCenter))
    {
        [self willChangeValueForKey: @"contentsCenter"];
        
        _contentsCenter = contentsCenter;
        
        [self didChangeValueForKey: @"contentsCenter"];
    }
}

- (CGRect)contentsCenter
{
    return _contentsCenter;
}

/* The filter types to use when rendering the `contents' property of
 * the layer. The minification filter is used when to reduce the size
 * of image data, the magnification filter to increase the size of
 * image data. Currently the allowed values are `nearest' and `linear'.
 * Both properties default to `linear'. */
- (void)setMinificationFilter: (NSString *)minificationFilter
{
    if(_minificationFilter != minificationFilter)
    {
        [self willChangeValueForKey: @"minificationFilter"];
        
        [_minificationFilter release];
        _minificationFilter = [minificationFilter copy];
        
        [self didChangeValueForKey: @"minificationFilter"];
    }
}

- (NSString *)minificationFilter
{
    return _minificationFilter;
}

- (void)setMagnificationFilter: (NSString *)magnificationFilter
{
    if(_magnificationFilter != magnificationFilter)
    {
        [self willChangeValueForKey: @"magnificationFilter"];
        
        [_magnificationFilter release];
        _magnificationFilter =[magnificationFilter copy];
        
        [self didChangeValueForKey: @"magnificationFilter"];
    }
}

- (NSString *)magnificationFilter
{
    return _magnificationFilter;
}

/* The bias factor added when determining which levels of detail to use
 * when minifying using trilinear filtering. The default value is 0.
 * Animatable. */
- (void)setMinificationFilterBias: (float)minificationFilterBias
{
    if(_minificationFilterBias != minificationFilterBias)
    {
        [self willChangeValueForKey: @"minificationFilterBias"];
        
        _minificationFilterBias = minificationFilterBias;
        
        [self didChangeValueForKey: @"minificationFilterBias"];
    }
}

/* A hint marking that the layer contents provided by -drawInContext:
 * is completely opaque. Defaults to NO. Note that this does not affect
 * the interpretation of the `contents' property directly. */
- (void)setOpaque: (BOOL)opaque
{
    if(_attr->_isOpaque != opaque)
    {
        [self willChangeValueForKey: @"opaque"];
        
        _attr->_isOpaque = opaque;
        
        [self didChangeValueForKey: @"opaque"];
    }
}

- (BOOL)isOpaque
{
    return _attr->_isOpaque;
}

/* Reload the content of this layer. Calls the -drawInContext: method
 * then updates the `contents' property of the layer. Typically this is
 * not called directly. */

- (void)display
{
    if(_attr->_delegateRespondsToDisplayLayer)
    {
        [_delegate displayLayer: self];
        
    }else
    {
        VGContext *context  = VGContextGetCurrentContext();
        VGContextSaveState(context);
        
        [self drawInContext: context];
        
        VGContextRestoreState(context);
    }
}

/* Marks that -display needs to be called before the layer is next
 * committed. If a region is specified, only that region of the layer
 * is invalidated. */

- (void)setNeedsDisplay
{
    _attr->_needsDisplay = YES;
}

- (void)setNeedsDisplayInRect: (CGRect)r
{
    _attr->_needsDisplay = YES;
}

/* Returns true when the layer is marked as needing redrawing. */

- (BOOL)needsDisplay
{
    return _attr->_needsDisplay;
}

/* Call -display if receiver is marked as needing redrawing. */

- (void)displayIfNeeded
{
    if(_attr->_needsDisplay)
    {
        [self display];
        _attr->_needsDisplay = NO;
    }
}

/* When true -setNeedsDisplay will automatically be called when the
 * bounds of the layer changes. Default value is NO. */

- (void)setNeedsDisplayOnBoundsChange: (BOOL)needsDisplayOnBoundsChange
{
    if(_attr->_needsDisplayOnBoundsChange != needsDisplayOnBoundsChange)
    {
        [self willChangeValueForKey: @"needsDisplayOnBoundsChange"];
        
        _attr->_needsDisplayOnBoundsChange = needsDisplayOnBoundsChange;
        
        [self didChangeValueForKey: @"needsDisplayOnBoundsChange"];
    }
}

- (BOOL)needsDisplayOnBoundsChange
{
    return _attr->_needsDisplayOnBoundsChange;
}

/* When true, the CGContext object passed to the -drawInContext: method
 * may queue the drawing commands submitted to it, such that they will
 * be executed later (i.e. asynchronously to the execution of the
 * -drawInContext: method). This may allow the layer to complete its
 * drawing operations sooner than when executing synchronously. The
 * default value is NO. */
- (void)setDrawsAsynchronously: (BOOL)drawsAsynchronously
{
    if(_attr->_drawsAsynchronously != drawsAsynchronously)
    {
        [self willChangeValueForKey: @"drawsAsynchronously"];
        
        _attr->_drawsAsynchronously = drawsAsynchronously;
        
        [self didChangeValueForKey: @"drawsAsynchronously"];
    }
}

- (BOOL)drawsAsynchronously
{
    return _attr->_drawsAsynchronously;
}

/* Called via the -display method when the `contents' property is being
 * updated. Default implementation does nothing. The context may be
 * clipped to protect valid layer content. Subclasses that wish to find
 * the actual region to draw can call CGContextGetClipBoundingBox(). */

- (void)drawInContext: (VGContext *)context
{
    if(_attr->_delegateRespondsToDrawLayerInContext)
    {
        [_delegate drawLayer: self
                   inContext: context];
    }
}

#pragma mark - VALayer (Rendering)

- (void)transformInContext: (VGContext *)context
{
	GLKMatrix4 transfrom4x4;
    
	// Convert 3x3 into 4x4 matrix
	CGAffineTransform tmpAffine = [self nodeToParentTransform];
    
	CGAffineToGL(&tmpAffine, transfrom4x4.m);
    
	// Update Z vertex manually
	transfrom4x4.m[14] = _anchorPointZ;
    
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

- (GLKMatrix4) modelMatrix
{    
    GLKMatrix4 modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, self.position.x, self.position.y, 0);
    modelMatrix = GLKMatrix4Translate(modelMatrix, -_bounds.size.width/2, -_bounds.size.height/2, 0);

    return modelMatrix;
    
}

/* Renders the receiver and its sublayers into 'ctx'. This method
 * renders directly from the layer tree. Renders in the coordinate space
 * of the layer.
 *
 * WARNING: currently this method does not implement the full
 * CoreAnimation composition model, use with caution. */

- (void)renderInContext: (VGContext *)ctx
{
#if 0
    VGContextSaveState(ctx);
    
    [self transformInContext: ctx];
    
    {
        VEGLProgramUse(_shaderProgram);
        VEGLProgramUniformForMVPMatrix(_shaderProgram, VGContextGetMVPMatrix(ctx));
        
        VEGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );
        
        // Attributes
        //
        glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, squareVertices_);
        glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_TRUE, 0, squareColors_);
        
        //CCGLBlendFunc( _blendFunc.src, _blendFunc.dst );
        //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        CC_INCREMENT_GL_DRAWS(1);
    }
    
    for (VALayer *layer in _sublayers)
    {
        [layer renderInContext: ctx];
    }
    
    VGContextRestoreState(ctx);
#else
//    self.effect.texture2d0.name = self.textureInfo.name;
//    self.effect.texture2d0.enabled = YES;
    [[_effect transform] setModelviewMatrix: [self modelMatrix]];
    [_effect setUseConstantColor: GL_TRUE];
    [_effect setConstantColor: GLKVector4Make(1.0, 0, 0, 1)];
    
    [_effect prepareToDraw];
    
    // Set up transparency
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // Set up position vertices
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, _vertices);
    
    // Draw arrays
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    // Tear down position vertices
    glDisableVertexAttribArray(GLKVertexAttribPosition);
        
    // Disable transparency
    glDisable(GL_BLEND);
    
#endif
}

/* Defines how the edges of the layer are rasterized. For each of the
 * four edges (left, right, bottom, top) if the corresponding bit is
 * set the edge will be antialiased. Typically this property is used to
 * disable antialiasing for edges that abut edges of other layers, to
 * eliminate the seams that would otherwise occur. The default value is
 * for all edges to be antialiased. */
- (void)setEdgeAntialiasingMask: (unsigned int)edgeAntialiasingMask
{
    if(_edgeAntialiasingMask != edgeAntialiasingMask)
    {
        [self willChangeValueForKey: @"edgeAntialiasingMask"];
        
        _edgeAntialiasingMask = edgeAntialiasingMask;
        
        [self didChangeValueForKey: @"edgeAntialiasingMask"];
    }
}

- (unsigned int)edgeAntialiasingMask
{
    return _edgeAntialiasingMask;
}

/* The background color of the layer. Default value is nil. Colors
 * created from tiled patterns are supported. Animatable. */

- (void)setBackgroundColor: (VGColor *)backgroundColor
{
    if(_backgroundColor != backgroundColor)
    {
        [self willChangeValueForKey: @"backgroundColor"];
        
        [_backgroundColor release];
        _backgroundColor = [backgroundColor retain];
        [self updateColor];
        
        [self didChangeValueForKey: @"backgroundColor"];
    }
}

/* When positive, the background of the layer will be drawn with
 * rounded corners. Also effects the mask generated by the
 * `masksToBounds' property. Defaults to zero. Animatable. */
- (void)setCornerRadius: (CGFloat)cornerRadius
{
    if(_cornerRadius != cornerRadius)
    {
        [self willChangeValueForKey: @"cornerRadius"];
        
        _cornerRadius = cornerRadius;
        
        [self didChangeValueForKey: @"cornerRadius"];
    }
}

- (CGFloat)cornerRadius
{
    return _cornerRadius;
}

/* The width of the layer's border, inset from the layer bounds. The
 * border is composited above the layer's content and sublayers and
 * includes the effects of the `cornerRadius' property. Defaults to
 * zero. Animatable. */
- (void)setBorderWidth: (CGFloat)borderWidth
{
    if(_borderWidth != borderWidth)
    {
        [self willChangeValueForKey: @"borderWidth"];
        
        _borderWidth = borderWidth;
        
        [self didChangeValueForKey: @"borderWidth"];
    }
}

- (CGFloat)borderWidth
{
    return _borderWidth;
}

/* The color of the layer's border. Defaults to opaque black. Colors
 * created from tiled patterns are supported. Animatable. */
- (void)setBorderColor: (VGColor *)borderColor
{
    if(_borderColor != borderColor)
    {
        [self willChangeValueForKey: @"borderColor"];
        
        [_borderColor release];
        _borderColor = [borderColor retain];
        
        [self didChangeValueForKey: @"borderColor"];
    }
}

- (VGColor *)borderColor
{
    return _borderColor;
}

/* The opacity of the layer, as a value between zero and one. Defaults
 * to one. Specifying a value outside the [0,1] range will give undefined
 * results. Animatable. */
- (void)setOpacity: (float)opacity
{
    if(_opacity != opacity)
    {
        [self willChangeValueForKey: @"opacity"];
        
        _opacity = opacity;
        
        [self didChangeValueForKey: @"opacity"];
    }
}

- (float)opacity
{
    return _opacity;
}

/* A filter object used to composite the layer with its (possibly
 * filtered) background. Default value is nil, which implies source-
 * over compositing. Animatable.
 *
 * Note that if the inputs of the filter are modified directly after
 * the filter is attached to a layer, the behavior is undefined. The
 * filter must either be reattached to the layer, or filter properties
 * should be modified by calling -setValue:forKeyPath: on each layer
 * that the filter is attached to. (This also applies to the `filters'
 * and `backgroundFilters' properties.) */

- (void)setCompositingFilter: (id)compositingFilter
{
    if(_compositingFilter != compositingFilter)
    {
        [self willChangeValueForKey: @"compositingFilter"];
        
        [_compositingFilter release];
        _compositingFilter = [compositingFilter retain];
        
        [self didChangeValueForKey: @"compositingFilter"];
    }
}

- (id)compositingFilter
{
    return _compositingFilter;
}

/* An array of filters that will be applied to the contents of the
 * layer and its sublayers. Defaults to nil. Animatable. */

- (void)setFilters: (NSArray *)filters
{
    if(_filters != filters)
    {
        [self willChangeValueForKey: @"filters"];
        
        [_filters setArray: filters];
        
        [self didChangeValueForKey: @"filters"];
    }
}

- (NSArray *)filters
{
    return [NSArray arrayWithArray: _filters];
}

/* An array of filters that are applied to the background of the layer.
 * The root layer ignores this property. Animatable. */

- (void)setBackgroundFilters: (NSArray *)backgroundFilters
{
    if(_backgroundFilters != backgroundFilters)
    {
        [self willChangeValueForKey: @"backgroundFilters"];
        
        [_backgroundFilters setArray: backgroundFilters];
        
        [self didChangeValueForKey: @"backgroundFilters"];
    }
}

- (NSArray *)backgroundFilters
{
    return [NSArray arrayWithArray: _backgroundFilters];
}

/* When true, the layer is rendered as a bitmap in its local coordinate
 * space ("rasterized"), then the bitmap is composited into the
 * destination (with the minificationFilter and magnificationFilter
 * properties of the layer applied if the bitmap needs scaling).
 * Rasterization occurs after the layer's filters and shadow effects
 * are applied, but before the opacity modulation. As an implementation
 * detail the rendering engine may attempt to cache and reuse the
 * bitmap from one frame to the next. (Whether it does or not will have
 * no affect on the rendered output.)
 *
 * When false the layer is composited directly into the destination
 * whenever possible (however, certain features of the compositing
 * model may force rasterization, e.g. adding filters).
 *
 * Defaults to NO. Animatable. */

- (void)setShouldRasterize: (BOOL)shouldRasterize
{
    if(_attr->_shouldRasterize != shouldRasterize)
    {
        [self willChangeValueForKey: @"shouldRasterize"];
        
        _attr->_shouldRasterize = shouldRasterize;
        
        [self didChangeValueForKey: @"shouldRasterize"];
    }
}

- (BOOL)shouldRasterize
{
    return _attr->_shouldRasterize;
}

/* The scale at which the layer will be rasterized (when the
 * shouldRasterize property has been set to YES) relative to the
 * coordinate space of the layer. Defaults to one. Animatable. */
- (void)setRasterizationScale: (CGFloat)rasterizationScale
{
    if(_rasterizationScale != rasterizationScale)
    {
        [self willChangeValueForKey: @"rasterizationScale"];
        
        _rasterizationScale = rasterizationScale;
        
        [self didChangeValueForKey: @"rasterizationScale"];
    }
}

- (CGFloat)rasterizationScale
{
    return _rasterizationScale;
}


#pragma mark - VALayer (Shadow)

/* The color of the shadow. Defaults to opaque black. Colors created
 * from patterns are currently NOT supported. Animatable. */
- (void)setShadowColor: (VGColor *)shadowColor
{
    if(_shadowColor != shadowColor)
    {
        [self willChangeValueForKey: @"shadowColor"];
        
        _shadowColor = shadowColor;
        
        [self didChangeValueForKey: @"shadowColor"];
    }
}

- (VGColor *)shadowColor
{
    return _shadowColor;
}

/* The opacity of the shadow. Defaults to 0. Specifying a value outside the
 * [0,1] range will give undefined results. Animatable. */
- (void)setShadowOpacity: (float)shadowOpacity
{
    if(_shadowOpacity != shadowOpacity)
    {
        [self willChangeValueForKey: @"shadowOpacity"];
        
        _shadowOpacity = shadowOpacity;
        
        [self didChangeValueForKey: @"shadowOpacity"];
    }
}

- (float)shadowOpacity
{
    return _shadowOpacity;
}

/* The shadow offset. Defaults to (0, -3). Animatable. */
- (void)setShadowOffset: (CGSize)shadowOffset
{
    if(!CGSizeEqualToSize(_shadowOffset, shadowOffset))
    {
        [self willChangeValueForKey: @"shadowOffset"];
        
        _shadowOffset = shadowOffset;
        
        [self didChangeValueForKey: @"shadowOffset"];
    }
}

- (CGSize)shadowOffset
{
    return _shadowOffset;
}

/* The blur radius used to create the shadow. Defaults to 3. Animatable. */
- (void)setShadowRadius: (CGFloat)shadowRadius
{
    if(_shadowRadius != shadowRadius)
    {
        [self willChangeValueForKey: @"shadowRadius"];
        
        _shadowRadius = shadowRadius;
        
        [self didChangeValueForKey: @"shadowRadius"];
    }
}

- (CGFloat)shadowRadius
{
    return _shadowRadius;
}

/* When non-null this path defines the outline used to construct the
 * layer's shadow instead of using the layer's composited alpha
 * channel. The path is rendered using the non-zero winding rule.
 * Specifying the path explicitly using this property will usually
 * improve rendering performance, as will sharing the same path
 * reference across multiple layers. Defaults to null. Animatable. */
- (void)setShadowPath: (CGPathRef)shadowPath
{
    if(_shadowPath != shadowPath)
    {
        [self willChangeValueForKey: @"shadowPath"];
        
        CGPathRelease(_shadowPath);
        _shadowPath =  CGPathRetain(shadowPath);
        
        [self didChangeValueForKey: @"shadowPath"];
    }
}

- (CGPathRef)shadowPath
{
    return _shadowPath;
}

#pragma mark - VALayer (Layout)

/* Returns the preferred frame size of the layer in the coordinate
 * space of the superlayer. The default implementation calls the layout
 * manager if one exists and it implements the -preferredSizeOfLayer:
 * method, otherwise returns the size of the bounds rect mapped into
 * the superlayer. */

- (CGSize)preferredFrameSize
{
    //    if(_layoutManager)
    //    {
    //        return [_layoutManager preferredSizeOfLayer: self];
    //    }else
    {
        CGRect rect = [self convertRect: _bounds
                                toLayer: _superlayer];
        return rect.size;
    }
}

/* Marks that -layoutSublayers needs to be invoked on the receiver
 * before the next update. If the receiver's layout manager implements
 * the -invalidateLayoutOfLayer: method it will be called.
 *
 * This method is automatically invoked on a layer whenever its
 * `sublayers' or `layoutManager' property is modified, and is invoked
 * on the layer and its superlayer whenever its `bounds' or `transform'
 * properties are modified. Implicit calls to -setNeedsLayout are
 * skipped if the layer is currently executing its -layoutSublayers
 * method. */

- (void)setNeedsLayout
{
    if(!_attr->_isLayoutingSublayers)
    {
        _attr->_needsLayout = YES;
    }
}

/* Returns true when the receiver is marked as needing layout. */

- (BOOL)needsLayout
{
    return _attr->_needsLayout;
}

/* Traverse upwards from the layer while the superlayer requires layout.
 * Then layout the entire tree beneath that ancestor. */

- (void)layoutIfNeeded
{
    if(_attr->_needsLayout)
    {
        [self layoutSublayers];
        _attr->_needsLayout = NO;
    }
}

/* Called when the layer requires layout. The default implementation
 * calls the layout manager if one exists and it implements the
 * -layoutSublayersOfLayer: method. Subclasses can override this to
 * provide their own layout algorithm, which should set the frame of
 * each sublayer. */

- (void)layoutSublayers
{
    _attr->_isLayoutingSublayers = YES;
    
    if(_attr->_delegateRespondsToLayoutSublayersOfLayer)
    {
        [_delegate layoutSublayersOfLayer: self];
        
    }else
    {
        [_layoutManager layoutSublayersOfLayer: self];
    }
    
    _attr->_isLayoutingSublayers = NO;
}

#pragma mark - VALayer (Action)

/* An "action" is an object that responds to an "event" via the
 * VAAction protocol (see below). Events are named using standard
 * dot-separated key paths. Each layer defines a mapping from event key
 * paths to action objects. Events are posted by looking up the action
 * object associated with the key path and sending it the method
 * defined by the VAAction protocol.
 *
 * When an action object is invoked it receives three parameters: the
 * key path naming the event, the object on which the event happened
 * (i.e. the layer), and optionally a dictionary of named arguments
 * specific to each event.
 *
 * To provide implicit animations for layer properties, an event with
 * the same name as each property is posted whenever the value of the
 * property is modified. A suitable VAAnimation object is associated by
 * default with each implicit event (VAAnimation implements the action
 * protocol).
 *
 * The layer class also defines the following events that are not
 * linked directly to properties:
 *
 * onOrderIn
 *	Invoked when the layer is made visible, i.e. either its
 *	superlayer becomes visible, or it's added as a sublayer of a
 *	visible layer
 *
 * onOrderOut
 *	Invoked when the layer becomes non-visible. */

/* Returns the default action object associated with the event named by
 * the string 'event'. The default implementation returns a suitable
 * animation object for events posted by animatable properties, nil
 * otherwise. */

+ (id<VAAction>)defaultActionForKey:(NSString *)event
{
    return nil;
}

/* Returns the action object associated with the event named by the
 * string 'event'. The default implementation searches for an action
 * object in the following places:
 *
 * 1. if defined, call the delegate method -actionForLayer:forKey:
 * 2. look in the layer's `actions' dictionary
 * 3. look in any `actions' dictionaries in the `style' hierarchy
 * 4. call +defaultActionForKey: on the layer's class
 *
 * If any of these steps results in a non-nil action object, the
 * following steps are ignored. If the final result is an instance of
 * NSNull, it is converted to `nil'. */

- (id<VAAction>)actionForKey:(NSString *)key
{
    if (_attr->_delegateRespondsToActionForLayerForKey)
    {
        id<VAAction> returnValue = [_delegate actionForLayer: self
                                                      forKey: key];
        
        if ([(id)returnValue isKindOfClass: [NSNull class]])
        {
            /* Abort search */
            return nil;
        }
        
        if (returnValue)
        {
            /* Return the value */
            return returnValue;
        }
        
        /* It's nil? Continue the search */
    }
    
    id<VAAction> dictValue = [_actions objectForKey: key];
    
    if ([(id)dictValue isKindOfClass: [NSNull class]])
    {
        /* Abort search */
        return nil;
    }
    
    if (dictValue)
    {
        /* Return the value */
        return dictValue;
    }
    
    /* It's nil? Continue the search */
    
    
    NSDictionary* styleActions = [[self style] objectForKey: @"actions"];
    if (styleActions)
    {
        dictValue = [styleActions objectForKey: key];
        
        if ([(id)dictValue isKindOfClass: [NSNull class]])
        {
            /* Abort search */
            return nil;
        }
        if (dictValue)
        {
            /* Return the value */
            return dictValue;
        }
        
        /* It's nil? Continue the search */
    }
    
    /* Before generating an action, let's also see if
     defaultActionForKey: has an offering to make to us. */
    id<VAAction> action = [[self class] defaultActionForKey: key];
    
    if ([(id)action isKindOfClass: [NSNull class]])
    {
        /* Abort search */
        return nil;
    }
    if (action)
    {
        /* Return the value */
        return action;
    }
    /* It's nil? That's it. Now we can only generate our own animation. */
    
    /***********************/
    
    /* construct new animation */
    VEBasicAnimation * animation = [VEBasicAnimation animationWithKeyPath: key];
    
    if (_attr->_isPresentationLayer)
    {
        [animation setFromValue: [self valueForKeyPath: key]];
    }else
    {
        [animation setFromValue: [[self presentationLayer] valueForKeyPath: key]];
    }
    
    return animation;
}

/* A dictionary mapping keys to objects implementing the VAAction
 * protocol. Default value is nil. */
- (void)setActions: (NSDictionary *)actions
{
    if(![_actions isEqualToDictionary: actions])
    {
        [self willChangeValueForKey: @"actions"];
        
        [_actions setDictionary: actions];
        
        [self didChangeValueForKey: @"actions"];
    }
    
}

- (NSDictionary *)actions
{
    return [NSDictionary dictionaryWithDictionary: _actions];
}

#pragma mark - VALayer (Animation)

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

- (void)addAnimation:(VAAnimation *)anim
              forKey:(NSString *)key
{
    if(anim && key)
    {
        [_animations setObject: anim
                        forKey: key];
        [key retain];
        
        [_animationKeys removeObject: key];
        [_animationKeys addObject: key];
        
        [key release];
        
        if(![anim duration])
        {
            [anim setDuration: 2.5];
        }
        
    }
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
    [_animations removeObjectForKey: key];
    [_animationKeys removeObject: key];
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

#pragma mark - VALayer (Miscellaneous)

/* The name of the layer. Used by some layout managers. Defaults to nil. */
- (void)setName: (NSString *)name
{
    if(![_name isEqualToString: name])
    {
        [self willChangeValueForKey: @"name"];
        
        [_name release];
        _name = [name copy];
        
        [self didChangeValueForKey: @"name"];
    }
}

- (NSString *)name
{
    return [NSString stringWithString: _name];
}

/* An object that will receive the VALayer delegate methods defined
 * below (for those that it implements). The value of this property is
 * not retained. Default value is nil. */
- (void)setDelegate: (id)delegate
{
    if(_delegate != delegate)
    {
        [self willChangeValueForKey: @"delegate"];
        
        _delegate = delegate;
        
        _attr->_delegateRespondsToDisplayLayer = [_delegate respondsToSelector: @selector(displayLayer:)];
        _attr->_delegateRespondsToActionForLayerForKey = [_delegate respondsToSelector: @selector(actionForLayer:forKey:)];
        _attr->_delegateRespondsToDrawLayerInContext = [_delegate respondsToSelector: @selector(drawLayer:inContext:)];
        _attr->_delegateRespondsToLayoutSublayersOfLayer = [_delegate respondsToSelector: @selector(layoutSublayersOfLayer:)];
        
        [self didChangeValueForKey: @"delegate"];
    }
}

- (id)delegate
{
    return _delegate;
}

/* When non-nil, a dictionary dereferenced to find property values that
 * aren't explicitly defined by the layer. (This dictionary may in turn
 * have a `style' property, forming a hierarchy of default values.)
 * If the style dictionary doesn't define a value for an attribute, the
 * +defaultValueForKey: method is called. Defaults to nil.
 *
 * Note that if the dictionary or any of its ancestors are modified,
 * the values of the layer's properties are undefined until the `style'
 * property is reset. */
- (void)setStyle: (NSDictionary *)style
{
    if(![_style isEqualToDictionary: style])
    {
        [self willChangeValueForKey: @"style"];
        
        [_style setDictionary: style];
        
        [self didChangeValueForKey: @"style"];
    }
}

- (NSDictionary *)style
{
    return [NSDictionary dictionaryWithDictionary: _style];
}

- (void) touchBegan: (UITouch*)touch
          withEvent: (UIEvent*)event
{
}

- (void) touchMoved:(UITouch*)touch withEvent:(UIEvent*)event
{
}

- (void) touchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
}

- (void)touchesCancelled: (UITouch *)touch
               withEvent: (UIEvent *)event
{
    
}


- (id)valueForUndefinedKey: (NSString *)key
{
    /* Core Graphics types apparently are not KVC-compliant under Cocoa. */
    
    if ([key isEqualToString: @"backgroundColor"])
    {
        return [self backgroundColor];
    }
    if ([key isEqualToString: @"shadowColor"])
    {
        return [self shadowColor];
    }
    if ([key isEqualToString: @"shadowPath"])
    {
        return [self shadowColor];
    }
    
    return [super valueForUndefinedKey: key];
}

- (void)setValue: (id)value
 forUndefinedKey: (NSString *)key
{
    /* Core Graphics types apparently are not KVC-compliant under Cocoa. */
    
    if ([key isEqualToString: @"backgroundColor"])
    {
        [self setBackgroundColor: value];
        return;
    }
    if ([key isEqualToString: @"shadowColor"])
    {
        [self setShadowColor: value];
        return;
    }
    if ([key isEqualToString: @"shadowPath"])
    {
        [self setShadowPath: (CGPathRef)value];
        return;
    }
    
    [super setValue: value forUndefinedKey: key];
}

@end

