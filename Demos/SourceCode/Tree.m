//
//  Tree.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/18/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "Tree.h"
#import "VETriangle.h"
#import "VERectangle.h"

@implementation Tree

- (id)init
{
    self = [super init];
    if (self)
    {
        VETriangle *leaves = [[VETriangle alloc] init];
        leaves.vertices[0] = GLKVector2Make(-1, 0);
        leaves.vertices[1] = GLKVector2Make( 1, 0);
        leaves.vertices[2] = GLKVector2Make( 0, 3);
        [leaves setPosition: GLKVector2Make(0,-1.2)];
        [leaves setBackgroundColor: GLKVector4Make(0, 0.5, 0, 1)];
        
        VERectangle *trunk = [[VERectangle alloc] init];
        [trunk setSize: CGSizeMake(0.4, 1)];
        
        trunk.position = GLKVector2Make(0, -1.25);
        [trunk setBackgroundColor: GLKVector4Make(0.4, 0.1, 0, 1)];
        
        [self addSubShape: trunk];
        [self addSubShape: leaves];
        
        [trunk release];
        [leaves release];
    }
    return self;
}

@end
