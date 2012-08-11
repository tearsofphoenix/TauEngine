//
//  TENode.m
//  TauGame
//
//  Created by Ian Terrell on 7/11/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TENode.h"
#import "TEDrawable.h"
#import "TEAnimation.h"
#import "TETranslateAnimation.h"
#import "TERotateAnimation.h"
#import "TEScaleAnimation.h"
#import "TEScene.h"
#import "TEShape.h"


@implementation TENode

@synthesize name = _name;
@synthesize drawable = _drawable;

@synthesize maxVelocity = _maxVelocity;
@synthesize maxAcceleration = _maxAcceleration;
@synthesize maxAngularVelocity = _maxAngularVelocity;
@synthesize maxAngularAcceleration = _maxAngularAcceleration;

@synthesize remove = _remove;
@synthesize collide = _collide;

@synthesize parent = _parent;
@synthesize renderChildrenFirst;

@synthesize currentAnimations = _currentAnimations;
@synthesize dirtyFullModelViewMatrix = _dirtyFullModelViewMatrix;

@synthesize position = _position;
@synthesize velocity = _velocity;
@synthesize acceleration = _acceleration;

@synthesize scale = _scale;

@synthesize rotation = _rotation;
@synthesize angularVelocity = _angularVelocity;
@synthesize angularAcceleration = _angularAcceleration;

- (id)init
{
    self = [super init];
    if (self)
    {
        _scale = 1.0;
        _rotation = 0.0;
        _position = GLKVector2Make(0.0, 0.0);
        
        _velocity = GLKVector2Make(0, 0);
        _acceleration = GLKVector2Make(0, 0);
        _maxVelocity = INFINITY;
        _maxAcceleration = INFINITY;
        
        _angularVelocity = 0;
        _angularAcceleration = 0;
        _maxAngularVelocity = INFINITY;
        _maxAngularAcceleration = INFINITY;
        
        _currentAnimations = [[NSMutableArray alloc] init];
        
        _remove = NO;
        renderChildrenFirst = NO;
        _children = [[NSMutableArray alloc] init];
        
        dirtyObjectModelViewMatrix = YES;
    }
    
    return self;
}

- (void)dealloc
{
    [_currentAnimations release];
    [super dealloc];
}

# pragma mark Factories

+ (TENode *)nodeWithDrawable:(TEDrawable *)drawable
{
    TENode *node = [[TENode alloc] init];
    [node setDrawable: drawable];
    return [node autorelease];
}

# pragma mark Rendering

- (void)renderInScene:(TEScene *)scene
{
    if (renderChildrenFirst)
    {
        [_children makeObjectsPerformSelector: @selector(renderInScene:)
                                   withObject: scene];
        [_drawable renderInScene:scene];
        
    } else
    {
        [_drawable renderInScene:scene];
        [_children makeObjectsPerformSelector: @selector(renderInScene:)
                                   withObject: scene];
    }
}

# pragma mark Update

- (void)update: (NSTimeInterval)dt
       inScene: (TEScene *)scene
{
    // Update positions
    [self updatePosition: dt
                 inScene: scene];
    
    // Update animations
    [self traverseUsingBlock: (^(TENode *node)
                               {
                                   NSMutableArray *removed = [[NSMutableArray alloc] init];
                                   // Remove animations that are done
                                   [node.currentAnimations filterUsingPredicate: [NSPredicate predicateWithBlock: (^BOOL(TEAnimation *animation, NSDictionary *bindings)
                                                                                                                   {
                                                                                                                       if (animation.remove)
                                                                                                                       {
                                                                                                                           [removed addObject:animation];
                                                                                                                           return NO;
                                                                                                                       } else
                                                                                                                       {
                                                                                                                           return YES;
                                                                                                                       }
                                                                                                                   })]];
                                   
                                   for (TEAnimation *animation in removed)
                                   {
                                       if (animation.next != nil)
                                       {
                                           [node.currentAnimations addObject:animation.next];
                                       }
                                       if (animation.onRemoval != nil)
                                       {
                                           animation.onRemoval();
                                       }
                                       
                                   }
                                   
                                   [node.currentAnimations enumerateObjectsUsingBlock: (^(id animation, NSUInteger idx, BOOL *stop)
                                                                                        {
                                                                                            [((TEAnimation *)animation) incrementElapsedTime:dt];
                                                                                        })];
                               })];
}

# pragma mark Drawable

- (void)setDrawable: (TEDrawable *)drawable
{
    if (_drawable != drawable)
    {
        [_drawable release];
        _drawable = [drawable retain];
        
        [_drawable setNode: self];
    }
}

- (TEShape *)shape
{
    return (TEShape *)_drawable;
}

# pragma mark Motion Methods

- (void)setPosition: (GLKVector2)position
{
    _position = position;
    [self markModelViewMatrixDirty];
}

- (void)setScale: (float)scale
{
    _scale = scale;
    [self markModelViewMatrixDirty];
}

- (void)setRotation: (float)rotation
{
    _rotation = rotation;
    [self markModelViewMatrixDirty];
}

- (void)updatePosition: (NSTimeInterval)dt
               inScene: (TEScene *)scene
{
    self.velocity = GLKVector2Add(_velocity, GLKVector2MultiplyScalar(_acceleration, dt));
    self.position = GLKVector2Add(_position, GLKVector2MultiplyScalar(_velocity, dt));
    
    self.angularVelocity += _angularAcceleration * dt;
    self.rotation += self.angularVelocity * dt;
}


- (void)setVelocity: (GLKVector2)newVelocity
{
    if (GLKVector2Length(newVelocity) > _maxVelocity)
    {
        _velocity = GLKVector2MultiplyScalar(GLKVector2Normalize(newVelocity), _maxVelocity);
        
    }else
    {
        _velocity = newVelocity;
    }
}

- (void)setAcceleration: (GLKVector2)newAcceleration
{
    if (GLKVector2Length(newAcceleration) > _maxAcceleration)
    {
        _acceleration = GLKVector2MultiplyScalar(GLKVector2Normalize(newAcceleration), _maxAcceleration);
        
    }else
    {
        _acceleration = newAcceleration;
    }
}

- (void)setAngularVelocity: (float)newAngularVelocity
{
    _angularVelocity = MIN(_maxAngularVelocity, newAngularVelocity);
}

- (void)setAngularAcceleration: (float)newAngularAcceleration
{
    _angularAcceleration = MIN(_maxAngularAcceleration, newAngularAcceleration);
}

# pragma mark Position Shortcuts

- (void)wraparoundInScene:(TEScene *)scene
{
    [self wraparoundXInScene:scene];
    [self wraparoundYInScene:scene];
}

- (void)wraparoundXInScene:(TEScene *)scene
{
    if (self.position.x > scene.topRightVisible.x)
        self.position = GLKVector2Make(scene.bottomLeftVisible.x, self.position.y);
    else if (self.position.x < scene.bottomLeftVisible.x)
        self.position = GLKVector2Make(scene.topRightVisible.x, self.position.y);
}

-(void)wraparoundYInScene:(TEScene *)scene {
    if (self.position.y > scene.topRightVisible.y)
        self.position = GLKVector2Make(self.position.x, scene.bottomLeftVisible.y);
    else if (self.position.y < scene.bottomLeftVisible.y)
        self.position = GLKVector2Make(self.position.x, scene.topRightVisible.y);
}

-(void)bounceXInScene:(TEScene *)scene buffer:(float)buffer {
    [self bounceXInScene:scene bufferLeft:buffer bufferRight:buffer];
}

- (void)bounceXInScene: (TEScene *)scene
            bufferLeft: (float)left
           bufferRight: (float)right
{
    UIEdgeInsets edgeInsets = [scene edgeInsets];
    
    BOOL farLeft = self.position.x < edgeInsets.left + left;
    BOOL farRight = self.position.x > edgeInsets.right - right;
    
    if (farLeft)
    {
        self.position = GLKVector2Make(edgeInsets.left + left, self.position.y);
    }
    
    if (farRight)
    {
        self.position = GLKVector2Make(edgeInsets.right - right, self.position.y);
    }
    
    if (farLeft || farRight)
    {
        self.velocity = GLKVector2Make(-1*self.velocity.x, self.velocity.y);
        self.acceleration = GLKVector2Make(-1*self.acceleration.x, self.acceleration.y);
    }
}

- (void)bounceYInScene: (TEScene *)scene
                buffer: (float)buffer
{
    [self bounceYInScene: scene
               bufferTop: buffer
            bufferBottom: buffer];
}

- (void)bounceYInScene: (TEScene *)scene
             bufferTop: (float)top
          bufferBottom: (float)bottom
{
    UIEdgeInsets edgeInsets = [scene edgeInsets];
    
    BOOL low = self.position.y < edgeInsets.bottom + bottom;
    BOOL high = self.position.y > edgeInsets.top - top;
    
    if (low)
    {
        self.position = GLKVector2Make(self.position.x, edgeInsets.bottom + bottom);
    }
    if (high)
    {
        self.position = GLKVector2Make(self.position.x, edgeInsets.top - top);
    }
    
    if (low || high)
    {
        self.velocity = GLKVector2Make(self.velocity.x, -1*self.velocity.y);
        self.acceleration = GLKVector2Make(self.acceleration.x, -1*self.acceleration.y);
    }
}

-(void)removeOutOfScene:(TEScene *)scene buffer:(float)buffer {
    if (self.position.y < scene.bottomLeftVisible.y - buffer || self.position.y > scene.topRightVisible.y + buffer ||
        self.position.x < scene.bottomLeftVisible.x - buffer || self.position.x > scene.topRightVisible.x + buffer)
        self.remove = YES;
}

-(GLKVector2)vectorToNode:(TENode *)node {
    return GLKVector2Subtract(node.position, self.position);
}

# pragma mark Animation Methods

- (void)startAnimation:(TEAnimation *)animation
{
    [_currentAnimations addObject:animation];
    [self markModelViewMatrixDirty];
}

# pragma mark Tree Methods

- (void)addChild: (TENode *)child
{
    child.parent = self;
    [_children addObject:child];
}

-(void)traverseUsingBlock: (void (^)(TENode *))block
{
    if (block)
    {
        block(self);
    }
    
    [_children makeObjectsPerformSelector: @selector(traverseUsingBlock:)
                               withObject: block];
}

-(TENode *)childNamed:(NSString *)nodeName
{
    __block TENode *namedNode = nil;
    
    [self traverseUsingBlock: (^(TENode *node)
                               {
                                   if ([node.name isEqualToString:nodeName])
                                   {
                                       namedNode = node;
                                       return;
                                   }
                               })];
    
    return namedNode;
}

-(NSArray *)childrenNamed:(NSArray *)nodeNames {
    NSMutableArray *namedChildren = [NSMutableArray arrayWithArray:nodeNames];
    [self traverseUsingBlock:^(TENode *node) {
        if ([nodeNames containsObject:node.name])
            [namedChildren replaceObjectAtIndex:[namedChildren indexOfObject:node.name] withObject:node];
    }];
    return namedChildren;
}


# pragma mark Callbacks

-(void)onRemoval
{
    
}

# pragma mark - Matrix Methods

-(GLKMatrix4)modelViewMatrix
{
    if (dirtyObjectModelViewMatrix)
    {
        __block GLKVector2 mvTranslation = _position;
        __block GLfloat mvScaleX = _scale;
        __block GLfloat mvScaleY = _scale;
        __block GLfloat mvRotation = _rotation;
        
        [_currentAnimations enumerateObjectsUsingBlock: (^(id animation, NSUInteger idx, BOOL *stop)
                                                         {
                                                             if ([animation isKindOfClass:[TETranslateAnimation class]])
                                                                 mvTranslation = GLKVector2Add(mvTranslation, ((TETranslateAnimation *)animation).easedTranslation);
                                                             else if ([animation isKindOfClass:[TERotateAnimation class]])
                                                                 mvRotation += ((TERotateAnimation *)animation).easedRotation;
                                                             else if ([animation isKindOfClass:[TEScaleAnimation class]]) {
                                                                 mvScaleX *= ((TEScaleAnimation *)animation).easedScaleX;
                                                                 mvScaleY *= ((TEScaleAnimation *)animation).easedScaleY;
                                                             }
                                                         })];
        
        cachedObjectModelViewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(mvTranslation.x, mvTranslation.y, 0.0),GLKMatrix4MakeScale(mvScaleX, mvScaleY, 1.0));
        cachedObjectModelViewMatrix = GLKMatrix4Multiply(cachedObjectModelViewMatrix, GLKMatrix4MakeZRotation(mvRotation));
        if ([self hasCustomTransformation])
            cachedObjectModelViewMatrix = GLKMatrix4Multiply(cachedObjectModelViewMatrix, [self customTransformation]);
        
        dirtyObjectModelViewMatrix = [_currentAnimations count] > 0;
        _dirtyFullModelViewMatrix = YES;
    }
    
    if (_dirtyFullModelViewMatrix)
    {
        if (_parent)
        {
            cachedFullModelViewMatrix = GLKMatrix4Multiply([self.parent modelViewMatrix], cachedObjectModelViewMatrix);
        }else
        {
            cachedFullModelViewMatrix = cachedObjectModelViewMatrix;
        }
        
        _dirtyFullModelViewMatrix = NO;
    }
    
    return cachedFullModelViewMatrix;
}

- (void)markModelViewMatrixDirty
{
    dirtyObjectModelViewMatrix = YES;
    
    BOOL tmpSelfValue = self.dirtyFullModelViewMatrix;
    [self traverseUsingBlock: (^(TENode *node)
                               {
                                   node.dirtyFullModelViewMatrix = YES;
                               })];
    self.dirtyFullModelViewMatrix = tmpSelfValue;
}

- (BOOL)hasCustomTransformation
{
    return NO;
}

- (GLKMatrix4)customTransformation
{
    return GLKMatrix4Identity;
}

@end
