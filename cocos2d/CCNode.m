/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
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
 */

#import "CCNode.h"
#import "CCDirector.h"

#import "CCCamera.h"
#import "ccConfig.h"
#import "ccMacros.h"
#import "CCScheduler.h"
#import "Support/CGPointExtension.h"

#import "Support/TransformUtils.h"

#import "CCGLProgram.h"


#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#endif


#if CC_NODE_RENDER_SUBPIXEL
#define RENDER_IN_SUBPIXEL
#else
#define RENDER_IN_SUBPIXEL (NSInteger)
#endif


@interface CCNode ()
{
@private
    IMP _renderInContextIMP;
    IMP _drawInContextIMP;
    
    // scaling factors
	float _scaleX, _scaleY;
    
	// openGL real Z vertex
	float _vertexZ;
    
    VECameraRef _camera;
    
    CCNode *_parent;
    
}

// helper that reorder a child
- (void)insertChild: (CCNode*)child
                  z: (NSInteger)z;
// used internally to alter the zOrder variable. DON'T call this method manually
- (void)_setZOrder: (NSInteger) z;
- (void)detachChild: (CCNode *)child cleanup: (BOOL)doCleanup;
@end

@implementation CCNode

@synthesize visible = _visible;

@synthesize zOrder = _zOrder;
@synthesize tag = _tag;
@synthesize vertexZ = _vertexZ;
@synthesize isRunning = _isRunning;
@synthesize userObject = userObject_;
@synthesize	shaderProgram = _shaderProgram;
@synthesize glServerState = _glServerState;

#pragma mark CCNode - Transform related properties

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

#pragma mark CCNode - Init & cleanup
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, (^
                               {
                                   lazyInitialize();
                               }));
}

+ (id)node
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	if ((self=[super init]) )
    {
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
        
		_tag = kCCNodeTagInvalid;
        
		_zOrder = 0;
        
		// lazy alloc
		_camera = nil;
        
		// children (lazy allocs)
		_children = nil;
        
		// userData is always inited as nil
		userObject_ = nil;
        
		//initialize parent to nil
		_parent = nil;
        
		_shaderProgram = nil;
        
		_glServerState = CC_GL_BLEND;
		
        _renderInContextIMP = [self methodForSelector: @selector(visitWithContext:)];
        _drawInContextIMP = [self methodForSelector: @selector(drawInContext:)];
        
		// set default scheduler and actionManager
		CCDirector *director = [CCDirector sharedDirector];
        
        [self setScheduler: [director scheduler]];
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
    VECameraFinalize(_camera);
	[_shaderProgram release];
	[userObject_ release];
    
	// children
    
    [(NSArray *)_children makeObjectsPerformSelector: @selector(setParent:)
                                          withObject: nil];
    
    if (_children)
    {
        CFRelease(_children);
    }
    
	[super dealloc];
}

#pragma mark Setters

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

- (void)setAnchorPoint: (CGPoint)point
{
	if( ! CGPointEqualToPoint(point, _anchorPoint) )
    {
		_anchorPoint = point;
		_anchorPointInPoints = ccp( _contentSize.width * _anchorPoint.x, _contentSize.height * _anchorPoint.y );
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
	}
}

#pragma mark CCNode Composition

// camera: lazy alloc
- (VECameraRef)camera
{
	if( ! _camera )
    {
		_camera = VECameraCreate();
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


- (void)detachChild: (CCNode *)child
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
- (void)insertChild: (CCNode*)child
                  z: (NSInteger)z
{
    CFArrayAppendValue(_children, [child retain]);
    
	[child _setZOrder:z];
    [self sortAllChildren];
}

@end

#pragma mark - CCNode Draw

@implementation  CCNode (CCNodeRendering)

- (void)drawInContext: (VEContext *)context
{
    
}

-(void)visitWithContext: (VEContext *)context
{
	// quick return if not visible. children won't be drawn.
	if (_visible)
    {
        VEGLPushMatrix();
        
        [self transform];
        
        _drawInContextIMP(self, @selector(drawInContext:), context);
        
        if(_children)
        {            
            for(CFIndex i = 0 ; i < CFArrayGetCount(_children); i++ )
            {
                CCNode *child =  CFArrayGetValueAtIndex(_children, i);
                _renderInContextIMP(child, _cmd, context);
            }            
        }
        
        VEGLPopMatrix();
    }
}

@end

#pragma mark - CCNode - SceneManagement

@implementation CCNode (CCNodeHierarchy)

#pragma mark CCNode - Transformations

- (void)setParent: (CCNode *)parent
{
    if (_parent != parent)
    {
        _parent = parent;
    }
}

- (CCNode *)parent
{
    return _parent;
}

- (void)onEnter
{
	[(NSArray *)_children makeObjectsPerformSelector:@selector(onEnter)];
    
    [_scheduler resumeTarget: self];
    [_actionManager resumeTarget: self];
    
	_isRunning = YES;
}

- (void)onEnterTransitionDidFinish
{
	[(NSArray *)_children makeObjectsPerformSelector:@selector(onEnterTransitionDidFinish)];
}

- (void)onExitTransitionDidStart
{
	[(NSArray *)_children makeObjectsPerformSelector: @selector(onExitTransitionDidStart)];
}

- (void)onExit
{
    [_scheduler pauseTarget: self];
    [_actionManager pauseTarget: self];
    
	_isRunning = NO;
    
	[(NSArray *)_children makeObjectsPerformSelector:@selector(onExit)];
}


-(CCNode*) getChildByTag: (NSInteger) aTag
{
	NSAssert( aTag != kCCNodeTagInvalid, @"Invalid tag");
    
	for(CCNode *node in (NSArray *)_children)
    {
		if( node.tag == aTag)
        {
			return node;
        }
	}
	// not found
	return nil;
}

/* "add" logic MUST only be on this method
 * If a class want's to extend the 'addChild' behaviour it only needs
 * to override this method
 */
- (void)addChild: (CCNode*)child
               z: (NSInteger)z
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( child.parent == nil, @"child already added. It can't be added again");
    
	if( ! _children )
    {
        _children = CFArrayCreateMutable(CFAllocatorGetDefault(), 4, NULL);
    }
    
	[self insertChild: child
                    z: z];
    
	[child setParent: self];
    
	if( _isRunning )
    {
		[child onEnter];
		[child onEnterTransitionDidFinish];
	}
}

- (void)addChild: (CCNode*) child
{
	NSAssert( child != nil, @"Argument must be non-nil");
	[self addChild:child z:child.zOrder];
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
- (void)removeChild: (CCNode*)child
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
    
	for(CCNode *c in (NSArray *)_children)
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
    [(NSMutableArray *)_children sortUsingComparator: (^NSComparisonResult(CCNode *obj1, CCNode *obj2)
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

#pragma mark - CCNode Geometry

@implementation CCNode (CCNodeGeometry)

- (CGRect) bounds
{
	CGRect rect = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
	return CGRectApplyAffineTransform(rect, [self nodeToParentTransform]);
}

-(float) scale
{
	NSAssert( _scaleX == _scaleY, @"CCNode#scale. ScaleX != ScaleY. Don't know which one to return");
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

- (void)setPosition: (CGPoint)newPosition
{
    if (!CGPointEqualToPoint(_position, newPosition))
    {
        _position = newPosition;
        _isTransformDirty = _isInverseDirty = YES;
    }
}

- (CGPoint)position
{
    return _position;
}

- (void)transformAncestors
{
	if( _parent )
    {
		[_parent transformAncestors];
		[_parent transform];
	}
}

- (void)transform
{
	GLKMatrix4 transfrom4x4;
    
	// Convert 3x3 into 4x4 matrix
	CGAffineTransform tmpAffine = [self nodeToParentTransform];
    
	CGAffineToGL(&tmpAffine, transfrom4x4.m);
    
	// Update Z vertex manually
	transfrom4x4.m[14] = _vertexZ;
    
	VECurrentGLMatrixStackMultiplyMatrix4( transfrom4x4 );
    
    
	// XXX: Expensive calls. Camera should be integrated into the cached affine matrix
	if ( _camera )
	{
		BOOL translate = (_anchorPointInPoints.x != 0.0f || _anchorPointInPoints.y != 0.0f);
        
		if( translate )
        {
			VEGLTranslatef(RENDER_IN_SUBPIXEL(_anchorPointInPoints.x), RENDER_IN_SUBPIXEL(_anchorPointInPoints.y), 0 );
        }
        
        VECameraLocate(_camera);
        
		if( translate )
        {
			VEGLTranslatef(RENDER_IN_SUBPIXEL(-_anchorPointInPoints.x), RENDER_IN_SUBPIXEL(-_anchorPointInPoints.y), 0 );
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
			float radians = -CC_DEGREES_TO_RADIANS(_rotation);
			c = cosf(radians);
			s = sinf(radians);
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
			CGAffineTransform skewMatrix = CGAffineTransformMake(1.0f, tanf(CC_DEGREES_TO_RADIANS(_skewY)),
																 tanf(CC_DEGREES_TO_RADIANS(_skewX)), 1.0f,
																 0.0f, 0.0f );
			_transform = CGAffineTransformConcat(skewMatrix, _transform);
            
			// adjust anchor point
			if( ! CGPointEqualToPoint(_anchorPointInPoints, CGPointZero) )
				_transform = CGAffineTransformTranslate(_transform, -_anchorPointInPoints.x, -_anchorPointInPoints.y);
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
    
	for (CCNode *p = _parent; p != nil; p = p.parent)
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

// convenience methods which take a UITouch instead of CGPoint

#ifdef __CC_PLATFORM_IOS

- (CGPoint)convertTouchToNodeSpace: (UITouch *)touch
{
	CGPoint point = [touch locationInView: [touch view]];
	point = [[CCDirector sharedDirector] convertToGL: point];
	return [self convertToNodeSpace:point];
}

- (CGPoint)convertTouchToNodeSpaceAR: (UITouch *)touch
{
	CGPoint point = [touch locationInView: [touch view]];
	point = [[CCDirector sharedDirector] convertToGL: point];
	return [self convertToNodeSpaceAR:point];
}

#endif // __CC_PLATFORM_IOS

@end

