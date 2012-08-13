//
//  AccelerationScene.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/19/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "AccelerationScene.h"
#import "VEEllipse.h"

@implementation AccelerationScene

- (id)init
{
    self = [super init];
    if (self)
    {
        VEEllipse *ball = [[VEEllipse alloc] init];
        ball.radiusX = 0.2;
        ball.radiusY = 0.2;
        ball.color = GLKVector4Make(1, 0, 0, 1);
        ball.position = GLKVector2Make(-3,-2);
        ball.velocity = GLKVector2Make(1,2.5);
        ball.acceleration = GLKVector2Make(0,-1);
        
        [_shapes addObject:ball];
        [ball release];
    }
    return self;
}

@end
