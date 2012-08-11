//
//  TERectangle.m
//  TauGame
//
//  Created by Ian Terrell on 7/11/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TERectangle.h"

@implementation TERectangle

@synthesize size = _size;

- (id)init
{
    self = [super initWithVertices:4];
    if (self)
    {
        _size = CGSizeMake(1.0, 1.0);
        
        [self updateVertices];
    }
    
    return self;
}

- (void)updateVertices
{
    CGFloat width = _size.width;
    CGFloat height = _size.height;
    
    GLKVector2 *vertices = [self vertices];

    vertices[kTERectangleBottomRight] = GLKVector2Make( width/2.0, -height/2.0);
    vertices[kTERectangleTopRight]    = GLKVector2Make( width/2.0,  height/2.0);
    vertices[kTERectangleTopLeft]     = GLKVector2Make(- width/2.0,  height/2.0);
    vertices[kTERectangleBottomLeft]  = GLKVector2Make(- width/2.0, -height/2.0);
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
