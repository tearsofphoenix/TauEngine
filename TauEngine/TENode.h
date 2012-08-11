//
//  TENode.h
//  TauGame
//
//  Created by Ian Terrell on 7/11/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import <GLKit/GLKit.h>

@class TEDrawable;
@class TEShape;
@class TEScene;
@class TEAnimation;

@interface TENode : NSObject
{            
    __weak TENode *_parent;
    NSMutableArray *_children;
        
    GLKMatrix4 cachedObjectModelViewMatrix;
    GLKMatrix4 cachedFullModelViewMatrix;
    BOOL dirtyObjectModelViewMatrix;
}

@property (nonatomic) GLKVector2 position;
@property (nonatomic) GLKVector2 velocity;
@property (nonatomic) GLKVector2 acceleration;

@property (nonatomic) float scale;

@property (nonatomic) float rotation;
@property (nonatomic) float angularVelocity;
@property (nonatomic) float angularAcceleration;

@property(strong, nonatomic) NSMutableArray *currentAnimations;
@property BOOL dirtyFullModelViewMatrix; // can be marked by parents

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) TEDrawable *drawable;
@property(nonatomic, readonly) TEShape *shape;
@property(weak, nonatomic) TENode *parent;

@property (nonatomic) float maxVelocity;
@property (nonatomic) float maxAcceleration;
@property (nonatomic) float maxAngularVelocity;
@property (nonatomic) float maxAngularAcceleration;

@property (nonatomic) BOOL remove;
@property (nonatomic) BOOL collide;
@property (nonatomic) BOOL renderChildrenFirst;

# pragma mark Factories

+ (TENode *)nodeWithDrawable: (TEDrawable *)drawable;

# pragma mark Update
- (void)update: (NSTimeInterval)dt
       inScene: (TEScene *)scene;

# pragma mark Motion Methods
- (void)updatePosition: (NSTimeInterval)dt
               inScene: (TEScene *)scene;

# pragma mark Position Shortcuts

- (void)wraparoundInScene: (TEScene *)scene;
- (void)wraparoundXInScene: (TEScene *)scene;
- (void)wraparoundYInScene: (TEScene *)scene;

- (void)bounceXInScene: (TEScene *)scene
                buffer: (float)buffer;
- (void)bounceXInScene: (TEScene *)scene
            bufferLeft: (float)left
           bufferRight: (float)right;
- (void)bounceYInScene: (TEScene *)scene
                buffer: (float)buffer;
- (void)bounceYInScene: (TEScene *)scene
             bufferTop: (float)top
          bufferBottom: (float)bottom;

- (void)removeOutOfScene: (TEScene *)scene
                  buffer: (float)buffer;

- (GLKVector2)vectorToNode: (TENode *)node;

# pragma mark Animation Methods

- (void)startAnimation: (TEAnimation *)animation;

# pragma mark Tree Methods

- (void)addChild: (TENode *)child;
- (void)traverseUsingBlock: (void (^)(TENode *))block;
- (TENode *)childNamed: (NSString *)name;
- (NSArray *)childrenNamed: (NSArray *)names;

# pragma mark Callbacks

- (void)onRemoval;

# pragma mark Rendering

- (void)renderInScene:(TEScene *)scene;

# pragma mark Matrix Methods

- (GLKMatrix4)modelViewMatrix;
- (void)markModelViewMatrixDirty;
- (BOOL)hasCustomTransformation;
- (GLKMatrix4)customTransformation;

@end
