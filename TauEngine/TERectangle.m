//
//  TERectangle.m
//  TauGame
//
//  Created by Ian Terrell on 7/11/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TERectangle.h"

@implementation TERectangle

@synthesize width = _width;
@synthesize height = _height;

- (id)init
{
    self = [super initWithVertices:4];
    if (self)
    {
        _width = _height = 1.0;
        [self updateVertices];
    }
    
    return self;
}

- (void)updateVertices
{
    self.vertices[kTERectangleBottomRight] = GLKVector2Make( _width/2.0, -_height/2.0);
    self.vertices[kTERectangleTopRight]    = GLKVector2Make( _width/2.0,  _height/2.0);
    self.vertices[kTERectangleTopLeft]     = GLKVector2Make(-_width/2.0,  _height/2.0);
    self.vertices[kTERectangleBottomLeft]  = GLKVector2Make(-_width/2.0, -_height/2.0);
}

- (void)setHeight: (GLfloat)height
{
    _height = height;
    [self updateVertices];
}

- (void)setWidth: (GLfloat)width
{
    _width = width;
    [self updateVertices];
}

@end
