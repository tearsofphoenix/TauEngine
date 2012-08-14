//
//  ComplexAnimationScene.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/19/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "ComplexAnimationScene.h"
#import "VERectangle.h"
#import "VEAnimation.h"

@implementation ComplexAnimationScene

- (id)init
{
    self = [super init];
    if (self)
    {
        VERectangle *rectangle = [[VERectangle alloc] init];
        rectangle.position = GLKVector2Make(-1, -1);
        [rectangle setSize: CGSizeMake(2, 1)];
        
        rectangle.scale = GLKVector2Make(0.5, 1);
        [rectangle setBackgroundColor: GLKVector4Make(1, 0, 0, 0)];
        
        VEAnimation *complexAnimation = [[VEAnimation alloc] init];
        
        complexAnimation.positionDelta = GLKVector2Make(2, 2);
        complexAnimation.scaleDelta = GLKVector2Make(1, -0.5);
        complexAnimation.rotationDelta = (2 * M_PI);
        complexAnimation.colorDelta = GLKVector4Make(0, 0, 0, 1);
        complexAnimation.duration = 3;
        
        [rectangle.animations addObject: complexAnimation];
        
        [complexAnimation release];
        
        VEAnimation *secondAnimation = [[VEAnimation alloc] init];
        secondAnimation.positionDelta = GLKVector2Make(-1,-1);
        secondAnimation.rotationDelta = (2 * M_PI);
        secondAnimation.colorDelta = GLKVector4Make(0, 1, 0, 0);
        secondAnimation.duration = 2;
        [rectangle.animations addObject: secondAnimation];
        
        [secondAnimation release];
        
        [_shapes addObject: rectangle];
        [rectangle release];
    }
    return self;
}

@end
