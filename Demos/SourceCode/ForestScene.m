//
//  ForestScene.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/18/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "ForestScene.h"
#import "OptimizedTree.h"

@implementation ForestScene

- (id)init
{
    self = [super init];
    if (self)
    {
        for (int i = 0; i < 10; i++)
        {
            for (int j = 0; j < 10; j++)
            {
                OptimizedTree *tree = [[OptimizedTree alloc] init];
                [tree setBackgroundColor: GLKVector4Make(0.0, 1.0, 0.0, 0.5)];
                tree.scale = GLKVector2Make(0.08+((i+j)%2)*0.04, 0.08+((i+j)%2)*0.04);
                tree.rotation = ((i+j)%12)/12.0*(2 * M_PI);
                tree.position = GLKVector2Make(-2.7+i*0.6,-1.8+j*0.4);
                [_shapes addObject: tree];
                [tree release];
            }
        }
    }
    return self;
}

@end
