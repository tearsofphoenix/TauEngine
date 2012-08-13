//
//  ManuallyMovedTree.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/19/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "ManuallyMovedTree.h"
#import "Tree.h"
#import "VEAnimation.h"

@implementation ManuallyMovedTree

- (id)init
{
    self = [super init];
    if (self)
    {
        Tree *tree = [[Tree alloc] init];
        tree.position = GLKVector2Make(-1.5,0);
        
        VEAnimation *moveRightAnimation = [[VEAnimation alloc] init];
        moveRightAnimation.positionDelta = GLKVector2Make(3, 0);
        moveRightAnimation.duration = 3;
        [tree.animations addObject:moveRightAnimation];
        
        [moveRightAnimation release];
        
        [_shapes addObject:tree];
        
        [tree release];
    }
    
    return self;
}

@end
