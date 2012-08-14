//
//  EllipseScene.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/17/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "EllipseScene.h"

@implementation EllipseScene

- (id)init
{
    self = [super init];
    if (self)
    {
        ellipse = [[VEEllipse alloc] init];
        ellipse.radiusX = 1;
        ellipse.radiusY = 1;
        [ellipse setBackgroundColor: GLKVector4Make(0.0, 1.0, 0.0, 1.0)];
        
        [_shapes addObject: ellipse];
    }
    return self;
}


@end
