//
//  TERegularPolygon.m
//  TauGame
//
//  Created by Ian Terrell on 7/27/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TauEngine.h"
#import "TERegularPolygon.h"

@implementation TERegularPolygon

- (id)initWithSides: (int)num
{
    self = [super initWithVertices: num + 2];
    if (self)
    {
        _numSides = num;
        _radius = 1.0;
    }
    
    return self;
}

- (int)numEdges
{
    return _numVertices - 2;
}

- (int)edgeVerticesOffset
{
    return 1;
}

- (void)updateVertices
{
    self.vertices[0] = GLKVector2Make(0,0);
    for (int i = 0; i <= _numSides; i++)
    {
        float theta = ((float)i) / _numSides * M_TAU;
        self.vertices[i+1] = GLKVector2Make(cos(theta) * _radius, sin(theta) * _radius);
    }
}

-(void)setRadius: (float)radius
{
    _radius = radius;
    [self updateVertices];
}


@end
