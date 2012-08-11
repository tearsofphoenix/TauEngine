//
//  TEEllipse.m
//  TauGame
//
//  Created by Ian Terrell on 7/11/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TauEngine.h"
#import "TEEllipse.h"

@implementation TEEllipse

@synthesize radiusX = _radiusX;
@synthesize radiusY = _radiusY;

- (id)init
{
    self = [super init];
    if (self)
    {
        _radiusX = _radiusY = 1.0;
        [self updateVertices];
    }
    
    return self;
}

- (int)numVertices
{
    return TE_ELLIPSE_NUM_VERTICES;
}

- (void)updateVertices
{
    self.vertices[0] = GLKVector2Make(0,0);
    for (int i = 0; i <= TE_ELLIPSE_RESOLUTION; i++)
    {
        float theta = ((float)i) / TE_ELLIPSE_RESOLUTION * M_TAU;
        self.vertices[i+1] = GLKVector2Make(cos(theta) * _radiusX, sin(theta) * _radiusY);
    }
}

- (void)setRadiusX: (GLfloat)radius
{
    _radiusX = radius;
    [self updateVertices];
}

- (void)setRadiusY: (GLfloat)radius
{
    _radiusY = radius;
    [self updateVertices];
}

- (float)radius
{
    return _radiusX;
}

- (void)setRadius: (float)radius
{
    _radiusX = _radiusY = radius;
    [self updateVertices];
}

@end
