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

#import "ccTypes.h"
#import "ccGLStateCache.h"
#import "CCCamera.h"

enum
{
	kCCNodeTagInvalid = -1,
};

@class CCGLProgram;
@class CCScheduler;
@class CCAction;
@class VEContext;

/** CCNode is the main element. Anything thats gets drawn or contains things that get drawn is a CCNode.
 The most popular CCNodes are: CCScene, CCLayer, CCSprite, CCMenu.

 The main features of a CCNode are:
 - They can contain other CCNode nodes (addChild, getChildByTag, removeChild, etc)
 - They can schedule periodic callback (schedule, unschedule, etc)
 - They can execute actions (runAction, stopAction, etc)

 Some CCNode nodes provide extra functionality for them or their children.

 Subclassing a CCNode usually means (one/all) of:
 - overriding init to initialize resources and schedule callbacks
 - create callbacks to handle the advancement of time
 - overriding draw to render the node

 Features of CCNode:
 - position
 - scale (x, y)
 - rotation (in degrees, clockwise)
 - CCCamera (an interface to gluLookAt )
 - CCGridBase (to do mesh transformations)
 - anchor point
 - size
 - visible
 - z-order
 - openGL z position

 Default values:
  - rotation: 0
  - position: (x=0,y=0)
  - scale: (x=1,y=1)
  - contentSize: (x=0,y=0)
  - anchorPoint: (x=0,y=0)

 Limitations:
 - A CCNode is a "void" object. It doesn't have a texture

 Order in transformations with grid disabled
 -# The node will be translated (position)
 -# The node will be rotated (rotation)
 -# The node will be skewed (skewX, skewY)
 -# The node will be scaled (scale, scaleX, scaleY)
 -# The node will be moved according to the camera values (camera)

 Order in transformations with grid enabled
 -# The node will be translated (position)
 -# The node will be rotated (rotation)
 -# The node will be skewed (skewX, skewY)
 -# The node will be scaled (scale, scaleX, scaleY)
 -# The grid will capture the screen
 -# The node will be moved according to the camera values (camera)
 -# The grid will render the captured screen

 Camera:
 - Each node has a camera. By default it points to the center of the CCNode.
 */
@interface CCNode : NSObject
{
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
    
	CCGLProgram	*_shaderProgram;

	// Server side state
	ccGLServerState _glServerState;

	// Is running
	BOOL _isRunning;

	BOOL _isTransformDirty;
	BOOL _isInverseDirty;

	// is visible
	BOOL _visible;
	// If YES, the Anchor Point will be (0,0) when you position the CCNode.
	// Used by CCLayer and CCScene
	BOOL _ignoreAnchorPointForPosition;
}

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

/** The X skew angle of the node in degrees.
 This angle describes the shear distortion in the X direction.
 Thus, it is the angle between the Y axis and the left edge of the shape
 The default skewX angle is 0. Positive values distort the node in a CW direction.
 */
@property(nonatomic) float skewX;

/** The Y skew angle of the node in degrees.
 This angle describes the shear distortion in the Y direction.
 Thus, it is the angle between the X axis and the bottom edge of the shape
 The default skewY angle is 0. Positive values distort the node in a CCW direction.
 */
@property(nonatomic) float skewY;
/** The rotation (angle) of the node in degrees. 0 is the default rotation angle. Positive values rotate node CW. */
@property(nonatomic) float rotation;

/** A CCCamera object that lets you move the node using a gluLookAt */
@property(nonatomic,readonly) VECameraRef camera;

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

/**  If YES, the Anchor Point will be (0,0) when you position the CCNode.
 Used by CCLayer and CCScene.
 */
@property(nonatomic) BOOL ignoreAnchorPointForPosition;

/** A tag used to identify the node easily */
@property(nonatomic) NSInteger tag;

/** Similar to userData, but instead of holding a void* it holds an id */
@property(nonatomic, strong) id userObject;

/** Shader Program
 @since v2.0
 */
@property(nonatomic, strong) CCGLProgram *shaderProgram;

/** GL server side state
 @since v2.0
*/
@property (nonatomic) ccGLServerState glServerState;

@property (nonatomic, assign) CCScheduler *scheduler;

+ (id)node;

/** Event that is called when the running node is no longer running (eg: its CCScene is being removed from the "stage" ).
 On cleanup you should break any possible circular references.
 CCNode's cleanup removes any possible scheduled timer and/or any possible action.
 If you override cleanup, you shall call [super cleanup]
 @since v0.8
 */
- (void)cleanup;

@end

@interface CCNode (CCNodeHierarchy)

/** A weak reference to the parent */
@property(nonatomic, assign) id parent;

@property(nonatomic, readonly) NSMutableArray* children;

// scene managment

/** Event that is called every time the CCNode enters the 'stage'.
 If the CCNode enters the 'stage' with a transition, this event is called when the transition starts.
 During onEnter you can't access a sibling node.
 If you override onEnter, you shall call [super onEnter].
 */
-(void) onEnter;


/** Event that is called when the CCNode enters in the 'stage'.
 If the CCNode enters the 'stage' with a transition, this event is called when the transition finishes.
 If you override onEnterTransitionDidFinish, you shall call [super onEnterTransitionDidFinish].
 @since v0.8
 */
-(void) onEnterTransitionDidFinish;

/** Event that is called every time the CCNode leaves the 'stage'.
 If the CCNode leaves the 'stage' with a transition, this event is called when the transition finishes.
 During onExit you can't access a sibling node.
 If you override onExit, you shall call [super onExit].
 */
-(void) onExit;

/** callback that is called every time the CCNode leaves the 'stage'.
 If the CCNode leaves the 'stage' with a transition, this callback is called when the transition starts.
 */
-(void) onExitTransitionDidStart;

// composition: ADD

/** Adds a child to the container with z-order as 0.
 If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be called immediately.
 @since v0.7.1
 */
-(void) addChild: (CCNode*)node;

/** Adds a child to the container with a z-order.
 If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be called immediately.
 @since v0.7.1
 */
-(void) addChild: (CCNode*)node
               z: (NSInteger)z;

// composition: REMOVE

/** Remove itself from its parent node. If cleanup is YES, then also remove all actions and callbacks.
 If the node orphan, then nothing happens.
 @since v0.99.3
 */
-(void) removeFromParentAndCleanup: (BOOL)cleanup;

/** Removes a child from the container. It will also cleanup all running actions depending on the cleanup parameter.
 @since v0.7.1
 */
-(void) removeChild: (CCNode*)node
            cleanup: (BOOL)cleanup;

/** Removes all children from the container and do a cleanup all running actions depending on the cleanup parameter.
 @since v0.7.1
 */
- (void)removeAllChildrenWithCleanup: (BOOL)cleanup;

// composition: GET
/** Gets a child from the container given its tag
 @return returns a CCNode object
 @since v0.7.1
 */
- (CCNode*)getChildByTag: (NSInteger)tag;

/** performance improvement, Sort the children array once before drawing, instead of every time when a child is added or reordered
 don't call this manually unless a child added needs to be removed in the same frame */
- (void) sortAllChildren;

@end

@interface CCNode (CCNodeRendering)

// draw

/** Override this method to draw your own node.
 You should use cocos2d's GL API to enable/disable the GL state / shaders.
 For further info, please see ccGLstate.h.
 You shall NOT call [super draw];
 */
- (void)drawInContext: (VEContext *)context;

/** recursive method that visit its children and draw them */
-(void)visitWithContext: (VEContext *)context;


@end

@interface CCNode (CCNodeGeometry)

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


/** performs OpenGL view-matrix transformation based on position, scale, rotation and other attributes. */
- (void)transformInContext: (VEContext *)context;

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

#ifdef __CC_PLATFORM_IOS
/** Converts a UITouch to node (local) space coordinates. The result is in Points.
 @since v0.7.1
 */
- (CGPoint)convertTouchToNodeSpace:(UITouch *)touch;
/** Converts a UITouch to node (local) space coordinates. The result is in Points.
 This method is AR (Anchor Relative)..
 @since v0.7.1
 */
- (CGPoint)convertTouchToNodeSpaceAR:(UITouch *)touch;
#endif // __CC_PLATFORM_IOS
@end
