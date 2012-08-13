//
//  VERectangle.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/17/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "VERectangle.h"

@implementation VERectangle

@synthesize size = _size;

- (int)numVertices
{
    return 4;
}

- (void)updateVertices
{
    CGFloat halfwidth = _size.width * 0.5;
    CGFloat halfheight = _size.height * 0.5;
    
    GLKVector2 *vertices = [self vertices];

    vertices[0] = GLKVector2Make( halfwidth, - halfheight);
    vertices[1] = GLKVector2Make( halfwidth,  halfheight);
    vertices[2] = GLKVector2Make(- halfwidth,  halfheight);
    vertices[3] = GLKVector2Make(- halfwidth, - halfheight);
}


- (void)setSize: (CGSize)size
{
    if (!CGSizeEqualToSize(_size, size))
    {
        _size = size;
        [self updateVertices];
    }
}

@end
