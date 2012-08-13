//
//  VEShape.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/17/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "VEShape.h"
#import "VEAnimation.h"
#import "VEScene.h"
#import "VESpriteAnimation.h"

@interface VEShape ()
{
@private
    GLKMatrix4 _fullModelViewMatrixCache;
    GLKMatrix4 _objectModelViewMatrixCache;
    
    BOOL _dirtyObjectModelViewMatrix;
    BOOL _dirtyFullModelViewMatrix;
}

@end

@implementation VEShape

@synthesize color = _color;
@synthesize useConstantColor = _useConstantColor;
@synthesize position = _position;
@synthesize velocity = _velocity;
@synthesize acceleration = _acceleration;

@synthesize rotation = _rotation;
@synthesize angularVelocity = _angularVelocity;
@synthesize angularAcceleration = _angularAcceleration;

@synthesize scale = _scale;

@synthesize subShapes = _subShapes;
@synthesize parent = _parent;

@synthesize texture = _texture;
@synthesize animations = _animations;
@synthesize spriteAnimation = _spriteAnimation;

@synthesize transform = _transform;
@synthesize subShapeTransform = _subShapeTransform;

- (id)init
{
    self = [super init];
    if (self)
    {
        // Draw with the _color white
        _useConstantColor = YES;
        _color = GLKVector4Make(1, 1, 1, 1);
        
        // No texture
        //
        _texture = nil;
        
        // Center on the origin
        //
        _position = GLKVector2Make(0,0);
        
        // Don't rotate
        //
        _rotation = 0;
        
        // Scale to original size
        _scale = GLKVector2Make(1,1);
        
        // No _children by default
        _subShapes = [[NSMutableArray alloc] init];
        
        // No _animations by default
        _animations = [[NSMutableArray alloc] init];
        
        _transform = GLKMatrix4Identity;
        _subShapeTransform = GLKMatrix4Identity;
        
        _fullModelViewMatrixCache = GLKMatrix4Identity;
        _objectModelViewMatrixCache = GLKMatrix4Identity;
        
//        _dirtyFullModelViewMatrix = YES;
//        _dirtyObjectModelViewMatrix = YES;
        
    }
    return self;
}

- (void)dealloc
{
    [_subShapes release];
    [_animations release];
    
    [super dealloc];
}

- (int)numVertices
{
    //it's subclass's responsibility for this method
    //
    return 0;
}

- (GLKVector2 *)vertices
{
    if (!_vertices)
    {
        _vertices = malloc(sizeof(GLKVector2) * [self numVertices]);
    }
    
    return _vertices;
}

- (GLKVector4 *)vertexColors
{
    if (!_vertexColors)
    {
        _vertexColors = malloc(sizeof(GLKVector4) * [self numVertices]);
    }
    return _vertexColors;
}

- (GLKVector2 *)textureCoordinates
{
    if (!_textureCoordinates)
    {
        _textureCoordinates = malloc(sizeof(GLKVector2) * [self numVertices]);
    }
    
    return _textureCoordinates;
}

- (GLKMatrix4)modelViewMatrix
{
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(_position.x, _position.y, 0),
                                                    GLKMatrix4MakeRotation(_rotation, 0, 0, 1));
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeScale(_scale.x, _scale.y, 1));
    
    if (_parent)
    {
        modelViewMatrix = GLKMatrix4Multiply([_parent modelViewMatrix], modelViewMatrix);
    }
    
    return modelViewMatrix;
}
//
//- (GLKMatrix4)xxx
//{
//    if (_dirtyObjectModelViewMatrix)
//    {
//        __block GLKVector2 mvTranslation = _position;
//        __block GLKVector2 mvScale = _scale;
//        __block GLfloat mvRotation = _rotation;
//        
//        [_animations enumerateObjectsUsingBlock: (^(VEAnimation *animation, NSUInteger idx, BOOL *stop)
//                                                  {
//                                                      mvTranslation = GLKVector2Add(mvTranslation, [animation positionDelta]);
//                                                      mvRotation += [animation rotationDelta];
//                                                      mvScale = GLKVector2Multiply(mvScale, [animation scaleDelta]);
//                                                  })];
//        
//        _objectModelViewMatrixCache = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(mvTranslation.x, mvTranslation.y, 0.0),
//                                                         GLKMatrix4MakeScale(mvScale.x, mvScale.y, 1.0));
//        
//        _objectModelViewMatrixCache = GLKMatrix4Multiply(_objectModelViewMatrixCache, GLKMatrix4MakeZRotation(mvRotation));
//        
//        _objectModelViewMatrixCache = GLKMatrix4Multiply(_objectModelViewMatrixCache, _transform);
//        
//        
//        _dirtyObjectModelViewMatrix = [_animations count] > 0;
//        
//        _dirtyFullModelViewMatrix = YES;
//    }
//    
//    if (_dirtyFullModelViewMatrix)
//    {
//        if (_parent)
//        {
//            _fullModelViewMatrixCache = GLKMatrix4Multiply([_parent modelViewMatrix], _objectModelViewMatrixCache);
//            
//        }else
//        {
//            _fullModelViewMatrixCache = _objectModelViewMatrixCache;
//        }
//        
//        _dirtyFullModelViewMatrix = NO;
//    }
//    
//    return _fullModelViewMatrixCache;
//}

- (void)update: (NSTimeInterval)dt
{
    
    _angularVelocity += _angularAcceleration * dt;
    _rotation += _angularVelocity * dt;
    
    GLKVector2 changeInVelocity = GLKVector2MultiplyScalar(_acceleration, dt);
    _velocity = GLKVector2Add(_velocity, changeInVelocity);
    
    GLKVector2 distanceTraveled = GLKVector2MultiplyScalar(_velocity, dt);
    _position = GLKVector2Add(_position, distanceTraveled);
    
    [_animations enumerateObjectsUsingBlock: (^(VEAnimation *animation, NSUInteger idx, BOOL *stop)
                                              {
                                                  [animation animateShape: self
                                                                       dt: dt];
                                              })];
    
    
    [_animations filterUsingPredicate: [NSPredicate predicateWithBlock: (^BOOL(VEAnimation *animation, NSDictionary *bindings)
                                                                         {
                                                                             BOOL shouldKeepAnimation = [animation elapsedTime] <= [animation duration];
                                                                             if (!shouldKeepAnimation)
                                                                             {
                                                                                 VEAnimationCompletionBlock completion = [animation completion];
                                                                                 if (completion)
                                                                                 {
                                                                                     completion(YES);
                                                                                 }
                                                                             }
                                                                             return shouldKeepAnimation;
                                                                         })]];
    
    [_spriteAnimation update: dt];
}

- (void)renderInScene: (VEScene *)scene
{
    // Set up our rendering effect
    GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
    
    // Set up the constant _color effect if set
    if (_useConstantColor)
    {
        [effect setUseConstantColor: YES];
        [effect setConstantColor: _color];
    }
    
    // Set up our _texture effect if set
    if (_texture != nil)
    {
        GLKEffectPropertyTexture *texture2d0 = [effect texture2d0];
        
        [texture2d0 setEnvMode: GLKTextureEnvModeReplace];
        [texture2d0 setTarget: GLKTextureTarget2D];
        
        if (_spriteAnimation)
        {
            [texture2d0 setName: [[_spriteAnimation currentFrame] name]];
        }else
        {
            [texture2d0 setName: [_texture name]];
        }
    }
    
    // Create a modelview matrix to _position and rotate the object
    GLKEffectPropertyTransform *transform = [effect transform];
    [transform setModelviewMatrix: [self modelViewMatrix]];
    
    // Set up the projection matrix to fit the scene's boundaries
    //
    [transform setProjectionMatrix: [scene projectionMatrix]];
    
    // Tell OpenGL that we're going to use this effect for our upcoming drawing
    [effect prepareToDraw];
    
    [effect release];
    
    // Enable transparency
    //
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // Tell OpenGL that we'll be using vertex position data
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, [self vertices]);
    
    // If we're using vertex coloring, tell OpenGL that we'll be using vertex color data
    if (!_useConstantColor)
    {
        glEnableVertexAttribArray(GLKVertexAttribColor);
        glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, [self vertexColors]);
    }
    
    // If we have a texture, tell OpenGL that we'll be using texture coordinate data
    //
    if (_texture)
    {
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, [self textureCoordinates]);
    }
    
    // Draw our primitives!
    //
    glDrawArrays(GL_TRIANGLE_FAN, 0, [self numVertices]);
    
    // Cleanup: Done with _position data
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    
    // Cleanup: Done with _color data (only if we used it)
    if (!_useConstantColor)
    {
        glDisableVertexAttribArray(GLKVertexAttribColor);
    }
    
    // Cleanup: Done with _texture data (only if we used it)
    if (_texture)
    {
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    }
    
    // Cleanup: Done with the current blend function
    glDisable(GL_BLEND);
    
    // Draw our subShapes
    //
    [_subShapes makeObjectsPerformSelector: @selector(renderInScene:)
                                withObject: scene];
}

- (void)setTextureImage: (UIImage *)image
{
    if (_textureImage != image)
    {
        [_textureImage release];
        _textureImage = [image retain];
        
        NSError *error = nil;
        [_texture release];
        _texture = [[GLKTextureLoader textureWithCGImage: [_textureImage CGImage]
                                                 options: [NSDictionary dictionaryWithObject: [NSNumber numberWithBool:YES]
                                                                                      forKey: GLKTextureLoaderOriginBottomLeft]
                                                   error: &error] retain];
        if (error)
        {
            NSLog(@"Error loading _texture from image: %@",error);
        }
    }
    
}

- (void)addSubShape: (VEShape *)child
{
    if (child)
    {
        [child retain];
        
        [child removeFromParent];
        
        child->_parent = self;
        
        [_subShapes addObject: child];
        
        [child release];
    }
}

- (void)removeFromParent
{
    if (_parent)
    {
        [[_parent subShapes] removeObject: self];
        _parent = nil;
    }
}

- (void)animateWithDuration: (NSTimeInterval)duration
                 animations: (void (^)(void))animationsBlock
                 completion: (void (^)(BOOL))completion
{
    GLKVector2 currentPosition = _position;
    GLKVector2 currentScale = _scale;
    GLKVector4 currentColor = _color;
    float currentRotation = _rotation;
    
    if (animationsBlock)
    {
        animationsBlock();
    }
    
    VEAnimation *animation = [[VEAnimation alloc] init];
    
    [animation setPositionDelta: GLKVector2Subtract(_position, currentPosition)];
    
    [animation setScaleDelta: GLKVector2Subtract(_scale, currentScale)];
    [animation setRotationDelta: _rotation - currentRotation];
    [animation setColorDelta: GLKVector4Subtract(_color, currentColor)];
    [animation setDuration: duration];
    [animation setCompletion: completion];
    
    [_animations addObject: animation];
    
    [animation release];
    
    _position = currentPosition;
    _scale = currentScale;
    _color = currentColor;
    _rotation = currentRotation;
}

@end
