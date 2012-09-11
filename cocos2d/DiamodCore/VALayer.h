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

#import <GLKit/GLKit.h>
#import "VACamera.h"

@class CCScheduler;
@class VGContext;
@class VAAnimation;

#pragma mark - VALayer

/** VALayer is a subclass of VALayer that implements the CCTouchEventsDelegate protocol.
 
 All features from VALayer are valid, plus the following new features:
 - It can receive iPhone Touches
 - It can receive Accelerometer input
 */

@interface VALayer : NSObject <NSCoding>
{
	GLKVector4	_backgroundColor;
    GLfloat _opacity;
    
	GLKVector2	squareVertices_[4];
	GLKVector4	squareColors_[4];
        
    NSMutableArray *_animationKeys;
    NSMutableDictionary *_animations;
    // rotation angle
	float _rotation;
    
	// skew angles
	float _skewX, _skewY;
    
	// anchor point in points
	CGPoint _anchorPointInPoints;
	// anchor point normalized (NOT in points)
	CGPoint _anchorPoint;
    
    CGPoint _position;
	// untransformed size of the node
	CGSize	_contentSize;
    
	CGAffineTransform _transform;
    CGAffineTransform _inverse;
    
	// z-order value
	NSInteger _zOrder;
    
	CFMutableArrayRef _children;
    
    NSInteger _tag;
    
    CCScheduler *_scheduler;
    
	// Is running
	BOOL _isRunning;
    
	BOOL _isTransformDirty;
	BOOL _isInverseDirty;
    
	// is visible
	BOOL _visible;
	// If YES, the Anchor Point will be (0,0) when you position the VANode.
	// Used by VALayer and VAScene
	BOOL _ignoreAnchorPointForPosition;
    BOOL _isUserInteractionEnabled;
}

+ (id)layer;

- (id)presentationLayer;

- (id)modelLayer;

- (BOOL)pointInside: (CGPoint)point
          withEvent: (UIEvent *)event;

- (VALayer *)hitTest: (CGPoint)point
           withEvent: (UIEvent *)event;


/** The z order of the node relative to its "siblings": children of the same parent */
@property(nonatomic) NSInteger zOrder;
/** The real openGL Z vertex.
 Differences between openGL Z vertex and cocos2d Z order:
 - OpenGL Z modifies the Z vertex, and not the Z order in the relation between parent-children
 - OpenGL Z might require to set 2D projection
 - cocos2d Z order works OK if all the nodes uses the same openGL Z vertex. eg: vertexZ = 0
 @warning: Use it at your own risk since it might break the cocos2d parent-children z order
 @since v0.8
 */
@property (nonatomic) float vertexZ;

/** The X skew angle of the node in radians.
 This angle describes the shear distortion in the X direction.
 Thus, it is the angle between the Y axis and the left edge of the shape
 The default skewX angle is 0. Positive values distort the node in a CW direction.
 */
@property(nonatomic) float skewX;

/** The Y skew angle of the node in radians.
 This angle describes the shear distortion in the Y direction.
 Thus, it is the angle between the X axis and the bottom edge of the shape
 The default skewY angle is 0. Positive values distort the node in a CCW direction.
 */
@property(nonatomic) float skewY;

/** The rotation (angle) of the node in degrees. 0 is the default rotation angle. Positive values rotate node CW. */
@property(nonatomic) float rotation;

/** A VACamera object that lets you move the node using a gluLookAt */
@property(nonatomic,readonly) VACameraRef camera;

/** Whether of not the node is visible. Default is YES */
@property(nonatomic, getter = isVisible) BOOL visible;

/** anchorPoint is the point around which all transformations and positioning manipulations take place.
 It's like a pin in the node where it is "attached" to its parent.
 The anchorPoint is normalized, like a percentage. (0,0) means the bottom-left corner and (1,1) means the top-right corner.
 But you can use values higher than (1,1) and lower than (0,0) too.
 The default anchorPoint is (0,0). It starts in the bottom-left corner. CCSprite and other subclasses have a different default anchorPoint.
 @since v0.8
 */
@property(nonatomic) CGPoint anchorPoint;
/** The anchorPoint in absolute pixels.
 Since v0.8 you can only read it. If you wish to modify it, use anchorPoint instead
 */
@property(nonatomic, readonly) CGPoint anchorPointInPoints;

/** The untransformed size of the node in Points
 The contentSize remains the same no matter the node is scaled or rotated.
 All nodes has a size. Layer and Scene has the same size of the screen.
 @since v0.8
 */
@property (nonatomic) CGSize contentSize;

/** whether or not the node is running */
@property(nonatomic, readonly) BOOL isRunning;

/**  If YES, the Anchor Point will be (0,0) when you position the VANode.
 Used by VALayer and VAScene.
 */
@property(nonatomic) BOOL ignoreAnchorPointForPosition;

/** A tag used to identify the node easily */
@property(nonatomic) NSInteger tag;

@property (nonatomic, assign) CCScheduler *scheduler;

/** Event that is called when the running node is no longer running (eg: its VAScene is being removed from the "stage" ).
 On cleanup you should break any possible circular references.
 CCNode's cleanup removes any possible scheduled timer and/or any possible action.
 If you override cleanup, you shall call [super cleanup]
 @since v0.8
 */
- (void)cleanup;

/** whether or not it will receive Touch events.
 You can enable / disable touch events with this property.
 Only the touches of this node will be affected. This "method" is not propagated to its children.
 
 Valid on iOS and Mac OS X v10.6 and later.
 
 @since v0.8.1
 */
@property (nonatomic,getter=isUserInteractionEnabled) BOOL userInteractionEnabled;

@property (atomic) GLKVector4 backgroundColor;

@property (atomic) GLfloat opacity;

/** Animation methods. **/

/* Attach an animation object to the layer. Typically this is implicitly
 * invoked through an action that is an CAAnimation object.
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

- (void)addAnimation: (VAAnimation *)anim
              forKey: (NSString *)key;

/* Remove all animations attached to the layer. */

- (void)removeAllAnimations;

/* Remove any animation attached to the layer for 'key'. */

- (void)removeAnimationForKey:(NSString *)key;

/* Returns an array containing the keys of all animations currently
 * attached to the receiver. The order of the array matches the order
 * in which animations will be applied. */

- (NSArray *)animationKeys;

/* Returns the animation added to the layer with identifier 'key', or nil
 * if no such animation exists. Attempting to modify any properties of
 * the returned object will result in undefined behavior. */

- (VAAnimation *)animationForKey:(NSString *)key;

+ (void)animateWithDuration:(NSTimeInterval)duration
                      delay: (NSTimeInterval)delay
                    options:(UIViewAnimationOptions)options
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion ;

+ (void)animateWithDuration: (NSTimeInterval)duration
                 animations: (void (^)(void))animations
                 completion: (void (^)(BOOL finished))completion; // delay = 0.0, options = 0

+ (void)animateWithDuration: (NSTimeInterval)duration
                 animations: (void (^)(void))animations ; // delay = 0.0, options = 0, completion = NULL

+ (void)transitionWithLayer: (VALayer *)layer
                   duration: (NSTimeInterval)duration
                    options: (UIViewAnimationOptions)options
                 animations: (void (^)(void))animations
                 completion: (void (^)(BOOL finished))completion ;

+ (void)transitionFromLayer: (VALayer *)fromView
                    toLayer: (VALayer *)toView
                   duration: (NSTimeInterval)duration
                    options: (UIViewAnimationOptions)options
                 completion: (void (^)(BOOL finished))completion; // toView added to fromView.superview, fromView removed from its superview


#pragma mark - User Interaction

-(void) touchBegan:(UITouch *)touch
         withEvent:(UIEvent *)event;

-(void) touchEnded:(UITouch *)touch
         withEvent:(UIEvent *)event;

-(void) touchCancelled:(UITouch *)touch
             withEvent:(UIEvent *)event;

-(void) touchMoved: (UITouch *)touch
         withEvent: (UIEvent *)event;

@end

@interface VALayer (CCNodeHierarchy)

/** A weak reference to the parent */
@property(nonatomic, assign) id parent;

@property(nonatomic, readonly) NSMutableArray* children;

// scene managment

/** Event that is called every time the VALayer enters the 'stage'.
 If the VALayer enters the 'stage' with a transition, this event is called when the transition starts.
 During onEnter you can't access a sibling node.
 If you override onEnter, you shall call [super onEnter].
 */
-(void) onEnter;

/** Event that is called every time the VALayer leaves the 'stage'.
 If the VALayer leaves the 'stage' with a transition, this event is called when the transition finishes.
 During onExit you can't access a sibling node.
 If you override onExit, you shall call [super onExit].
 */
-(void) onExit;

/** callback that is called every time the VALayer leaves the 'stage'.
 If the VALayer leaves the 'stage' with a transition, this callback is called when the transition starts.
 */
-(void) onExitTransitionDidStart;

// composition: ADD

/** Adds a child to the container.
 If the child is added to a 'running' node, then 'onEnter' will be called immediately.
 @since v0.7.1
 */
- (void)addChild: (VALayer*)node;

// composition: REMOVE

/** Remove itself from its parent node. If cleanup is YES, then also remove all actions and callbacks.
 If the node orphan, then nothing happens.
 @since v0.99.3
 */
-(void) removeFromParentAndCleanup: (BOOL)cleanup;

/** Removes a child from the container. It will also cleanup all running actions depending on the cleanup parameter.
 @since v0.7.1
 */
-(void) removeChild: (VALayer*)node
            cleanup: (BOOL)cleanup;

/** Removes all children from the container and do a cleanup all running actions depending on the cleanup parameter.
 @since v0.7.1
 */
- (void)removeAllChildrenWithCleanup: (BOOL)cleanup;

/** performance improvement, Sort the children array once before drawing, instead of every time when a child is added or reordered
 don't call this manually unless a child added needs to be removed in the same frame */
- (void) sortAllChildren;

@end

@interface VALayer (CCNodeRendering)

// draw

/** Override this method to draw your own node.
 You should use cocos2d's GL API to enable/disable the GL state / shaders.
 For further info, please see ccGLstate.h.
 You shall NOT call [super draw];
 */
- (void)drawInContext: (VGContext *)context;

/** recursive method that visit its children and draw them */
- (void)visitWithContext: (VGContext *)context;


@end

@interface VALayer (CCNodeGeometry)

/** The scale factor of the node. 1.0 is the default scale factor. It modifies the X and Y scale at the same time. */
@property(nonatomic) float scale;
/** The scale factor of the node. 1.0 is the default scale factor. It only modifies the X scale factor. */
@property(nonatomic) float scaleX;
/** The scale factor of the node. 1.0 is the default scale factor. It only modifies the Y scale factor. */
@property(nonatomic) float scaleY;

/** Position (x,y) of the node in points. (0,0) is the left-bottom corner. */
@property(nonatomic) CGPoint position;

/** returns a "local" axis aligned bounding box of the node in points.
 The returned box is relative only to its parent.
 The returned box is in Points.
 
 @since v0.8.2
 */
- (CGRect)bounds;

- (void)setBounds: (CGRect)bounds;

/** performs OpenGL view-matrix transformation based on position, scale, rotation and other attributes. */
- (void)transformInContext: (VGContext *)context;

// transformation methods

/** Returns the matrix that transform the node's (local) space coordinates into the parent's space coordinates.
 The matrix is in Pixels.
 @since v0.7.1
 */
- (CGAffineTransform)nodeToParentTransform;


/** Returns the matrix that transform parent's space coordinates to the node's (local) space coordinates.
 The matrix is in Pixels.
 @since v0.7.1
 */
- (CGAffineTransform)parentToNodeTransform;
/** Retrusn the world affine transform matrix. The matrix is in Pixels.
 @since v0.7.1
 */
- (CGAffineTransform)nodeToWorldTransform;
/** Returns the inverse world affine transform matrix. The matrix is in Pixels.
 @since v0.7.1
 */
- (CGAffineTransform)worldToNodeTransform;
/** Converts a Point to node (local) space coordinates. The result is in Points.
 @since v0.7.1
 */
- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint;
/** Converts a Point to world space coordinates. The result is in Points.
 @since v0.7.1
 */
- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint;
/** Converts a Point to node (local) space coordinates. The result is in Points.
 treating the returned/received node point as anchor relative.
 @since v0.7.1
 */
- (CGPoint)convertToNodeSpaceAR:(CGPoint)worldPoint;
/** Converts a local Point to world space coordinates.The result is in Points.
 treating the returned/received node point as anchor relative.
 @since v0.7.1
 */
- (CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint;

@end


