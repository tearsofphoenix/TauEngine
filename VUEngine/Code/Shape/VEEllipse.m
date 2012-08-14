//
//  VEEllipse.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/17/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "VEEllipse.h"

#define VE_ELLIPSE_RESOLUTION 64

@implementation VEEllipse

@synthesize radiusX = _radiusX;
@synthesize radiusY = _radiusY;

- (GLKVector2)center
{
    float rotation = [self rotation];
    
    float cosR = cos(rotation);
    float sinR = sin(rotation);
    
    GLKVector2 position = [self position];
    
    return GLKVector2Make(position.x + _radiusX * sinR - _radiusY * cosR, position.y - _radiusX * cosR - _radiusY * sinR);
}

- (void)setCenter: (GLKVector2)center
{
    float rotation = [self rotation];
    
    float cosR = cos(rotation);
    float sinR = sin(rotation);

    [self setPosition: GLKVector2Make(center.x - (_radiusX * sinR - _radiusY * cosR), center.y + (_radiusX * cosR + _radiusY * sinR))];
    
}

- (int)numVertices
{
    return VE_ELLIPSE_RESOLUTION;
}

- (void)updateVertices
{
    GLKVector2 *vertices = [self vertices];
    
    for (int i = 0; i < VE_ELLIPSE_RESOLUTION; i++)
    {
        GLfloat theta = (2 * M_PI * i) / VE_ELLIPSE_RESOLUTION;
        
        vertices[i] = GLKVector2Make( cos(theta) * _radiusX, sin(theta) * _radiusY);
    }
}

- (void)setRadiusX: (float)radiusX
{
    if (_radiusX != radiusX)
    {
        _radiusX = radiusX;
        
        [self updateVertices];
    }
}


- (void)setRadiusY: (float)radiusY
{
    if (_radiusY != radiusY)
    {
        _radiusY = radiusY;
        
        [self updateVertices];
    }
}

@end
