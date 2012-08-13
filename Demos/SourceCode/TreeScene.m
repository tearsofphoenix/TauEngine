//
//  TreeScene.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/18/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "TreeScene.h"

@implementation TreeScene

-(id)init {
    self = [super init];
    if (self) {
        VETriangle *leaves = [[VETriangle alloc] init];
        leaves.vertices[0] = GLKVector2Make(-1, 0);
        leaves.vertices[1] = GLKVector2Make( 1, 0);
        leaves.vertices[2] = GLKVector2Make( 0, 3);
        [leaves setPosition: GLKVector2Make(0,-1.2)];
        leaves.color = GLKVector4Make(0, 0.5, 0, 1);
        
        VERectangle *trunk = [[VERectangle alloc] init];
        [trunk setSize: CGSizeMake(0.4, 1)];
        
        trunk.position = GLKVector2Make(0, -1.25);
        trunk.color = GLKVector4Make(0.4, 0.1, 0, 1);
        
        VEShape *tree = [[VEShape alloc] init];
        [tree addSubShape: trunk];
        
        [trunk release];
        
        [tree addSubShape: leaves];
        [leaves release];
        
        tree.scale = GLKVector2Make(0.5, 0.5);
        tree.position = GLKVector2Make(1,0);
        
        [_shapes addObject: tree];
        
        [tree release];
    }
    return self;
}

@end