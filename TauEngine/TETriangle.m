//
//  TETriangle.m
//  TauGame
//
//  Created by Ian Terrell on 7/11/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TETriangle.h"

@implementation TETriangle

- (id)init
{
    self = [super initWithVertices: 3];
    if (self)
    {
        GLKVector2 *vertices = [self vertices];
        
        vertices[0] = GLKVector2Make(0.0, 1.0);
        vertices[1] = GLKVector2Make(-1.0, -1.0);
        vertices[2] = GLKVector2Make(1.0, -1.0);
    }
    
    return self;
}

@end
