//
//  VEShape.h
//  ExampleEngine
//
//  Created by Ian Terrell on 8/17/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class VEScene;
@class VESpriteAnimation;

@interface VEShape : NSObject
{
    GLKVector2 *_vertices;
    GLKVector4 *_vertexColors;
    GLKVector2 *_textureCoordinates;
        
    GLKTextureInfo *_texture;
    
    NSMutableArray *_subShapes;
    VEShape *_parent;
    
    NSMutableArray *_animations;
    VESpriteAnimation *_spriteAnimation;
    
    UIImage *_textureImage;
}

@property (nonatomic, readonly) int numVertices;

@property (nonatomic, readonly) GLKVector2 *vertices;

@property (nonatomic, readonly) GLKVector4 *vertexColors;

@property (nonatomic, readonly) GLKVector2 *textureCoordinates;

@property (nonatomic) GLKVector4 color;
@property (nonatomic) BOOL useConstantColor;

@property (nonatomic) GLKVector2 position;
@property (nonatomic) GLKVector2 scale;

@property (nonatomic) GLKVector2 velocity;
@property (nonatomic) GLKVector2 acceleration;


@property (nonatomic) GLKMatrix4 transform;
@property (nonatomic) GLKMatrix4 subShapeTransform;

@property (nonatomic) float rotation;

@property (nonatomic) float angularVelocity;
@property (nonatomic) float angularAcceleration;

@property (nonatomic, strong, readonly) NSMutableArray *subShapes;

@property (nonatomic, weak, readonly) VEShape *parent;

- (void)removeFromParent;

@property (nonatomic, readonly) GLKMatrix4 modelViewMatrix;

@property (nonatomic, strong, readonly) GLKTextureInfo *texture;

@property (nonatomic, strong, readonly) NSMutableArray *animations;

@property (nonatomic, strong) VESpriteAnimation *spriteAnimation;

- (void)update: (NSTimeInterval)dt;

- (void)renderInScene: (VEScene *)scene;

- (void)setTextureImage: (UIImage *)image;

- (void)addSubShape: (VEShape *)child;

- (void)animateWithDuration: (NSTimeInterval)duration
                 animations: (void (^)(void))animations
                 completion: (void(^)(BOOL finished))completion;

@end