//
//  VEGravityField.m
//  VUEngine
//
//  Created by LeixSnake on 8/14/12.
//  Copyright (c) 2012 Ian Terrell. All rights reserved.
//

#import "VEGravityField.h"

#import "VEQualityObject.h"

#import "VEShape.h"

@implementation VEGravityField

@synthesize gravity = _gravity;

- (id)init
{
    if ((self = [super init]))
    {
        _gravity = GLKVector2Make(0, -10);
    }
    
    return self;
}

- (void)applyOnObject: (VEQualityObject *)qualityObject
{
    VEShape *shape = [qualityObject shape];
    
    GLKVector2 acceleration = GLKVector2Add([shape acceleration], _gravity);
    [shape setAcceleration: acceleration];
}

- (void)applyOnObjects: (NSArray *)objects
{
    for (VEQualityObject *obj in objects)
    {
        [self applyOnObject: obj];
    }
}

@end
