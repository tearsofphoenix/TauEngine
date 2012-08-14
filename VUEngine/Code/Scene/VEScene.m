//
//  VEScene.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/16/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "VEScene.h"

#import "VEShape.h"

#import "VEGravityField.h"

@implementation VEScene

@synthesize clearColor = _clearColor;

@synthesize edgeInsets = _edgeInsets;

@synthesize shapes = _shapes;

- (id)init
{
    self = [super init];
    if (self)
    {
        _shapes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_shapes release];
    
    [super dealloc];
}

- (void)update: (NSTimeInterval)dt
{    
    for (VEShape *shapeLooper in _shapes)
    {
        [shapeLooper update: dt];
    }
}

- (void)render
{
    glClearColor(_clearColor.r, _clearColor.g, _clearColor.b, _clearColor.a);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [_shapes makeObjectsPerformSelector: @selector(renderInScene:)
                             withObject: self];
}

- (GLKMatrix4)projectionMatrix
{
    return GLKMatrix4MakeOrtho(_edgeInsets.left, _edgeInsets.right, _edgeInsets.bottom, _edgeInsets.top, 1, -1);
}

@end
