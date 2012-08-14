//
//  VERegularPolygon.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/17/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "VERegularPolygon.h"

@implementation VERegularPolygon

@synthesize numSides = _numSides;
@synthesize radius = _radius;

- (id)initWithNumSides: (int)numSides
{
    self = [super init];
    if (self)
    {
        _numSides = numSides;
    }
    return self;
}

- (int)numVertices
{
    return _numSides;
}

- (void)updateVertices
{
    GLKVector2 *vertices = [self vertices];
    
    for (int i = 0; i < _numSides; ++i)
    {
        float theta = (2 * M_PI * i) / _numSides;
        
        vertices[i] = GLKVector2Make(cos(theta) * _radius, sin(theta) * _radius);
    }
}

- (void)setRadius: (float)radius
{
    if (_radius != radius)
    {
        _radius = radius;
        
        [self updateVertices];
    }
}

@end
