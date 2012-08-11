//
//  TEPolygon.m
//  TauGame
//
//  Created by Ian Terrell on 7/26/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEPolygon.h"

@implementation TEPolygon

- (id)initWithVertices: (int)num
{
    self = [super init];
    if (self)
    {
        _numVertices = num;
        _radius = 0;
    }
    
    return self;
}

- (int)numEdges
{
    return _numVertices;
}

- (int)edgeVerticesOffset
{
    return 0;
}

- (BOOL)isPolygon
{
    return YES;
}

- (float)radius
{
    if (_radius == 0)
    {
        for (int i = 0; i < _numVertices; i++)
        {
            _radius = MAX(_radius, GLKVector2Length(_vertices[i]));
        }
    }
    return _radius;
}

@end
