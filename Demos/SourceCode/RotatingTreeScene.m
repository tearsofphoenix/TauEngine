//
//  RotatingTreeScene.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/19/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "RotatingTreeScene.h"
#import "Tree.h"

@implementation RotatingTreeScene

- (id)init
{
    self = [super init];
    if (self)
    {
        Tree *tree = [[Tree alloc] init];
        tree.rotation = 0;
        tree.angularVelocity = (2 * M_PI);
        tree.angularAcceleration = 0.1*(2 * M_PI);
        
        [_shapes addObject:tree];
        [tree release];
    }
    return self;
}


@end
