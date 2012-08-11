//
//  TEShape.h
//  TauGame
//
//  Created by Ian Terrell on 7/11/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEDrawable.h"

enum
{
    kTERenderStyleNone          = 0,
    kTERenderStyleConstantColor = 1 << 0,
    kTERenderStyleVertexColors  = 1 << 1,
    kTERenderStyleTexture       = 1 << 2,
    
};

typedef NSUInteger TERenderStyle;

@interface TEShape : TEDrawable
{
    NSMutableData *_vertexData;
    NSMutableData *_textureData;
    NSMutableData *_colorData;
    
    GLKVector2 *_vertices;
    GLKVector2 *_textureCoordinates;
    GLKVector4 *_colorVertices;
    int _numVertices;
    float _radius;
}

@property (strong, nonatomic) GLKBaseEffect *effect;
@property (nonatomic) TERenderStyle renderStyle;
@property (nonatomic) GLKVector4 color;

@property (nonatomic, readonly) int numVertices;
@property (nonatomic, readonly) GLKVector2 *vertices;
@property (nonatomic, readonly) GLKVector2 *textureCoordinates;
@property (nonatomic, strong, readonly) NSMutableData *colorData;
@property (nonatomic, readonly) GLKVector4 *colorVertices;

@property (nonatomic, readonly) float radius; // for bounding circle collision detection

@property (nonatomic, readonly) GLenum renderMode;

- (void)updateVertices;

- (BOOL)isPolygon;

- (BOOL)isCircle;

@end
