//
//  RectangleScene.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/17/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "RectangleScene.h"

@implementation RectangleScene

- (id)init
{
    self = [super init];
    if (self)
    {
        rectangle = [[VERectangle alloc] init];
        [rectangle setSize: CGSizeMake(2, 1)];
    }
    return self;
}

- (void)render
{
    [super render];
    [rectangle renderInScene:self];
}

@end