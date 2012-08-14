//
//  VEWorld.m
//  VUEngine
//
//  Created by LeixSnake on 8/14/12.
//  Copyright (c) 2012 Ian Terrell. All rights reserved.
//

#import "VEWorld.h"

#import "VEScene.h"

#import "VEField.h"

#import "VEQualityObject.h"

@implementation VEWorld

@synthesize scene = _scene;

@synthesize fields = _fields;

- (id)init
{
    if ((self = [super init]))
    {
        _objects = [[NSMutableArray alloc] init];
        _fields = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addObject: (VEQualityObject *)object
{
    [_objects addObject: object];
    [[_scene shapes] addObject: [object shape]];
}

- (void)dealloc
{
    [_scene release];
    [_fields release];
    [_objects release];
    
    [super dealloc];
}

- (void)addField: (VEField *)field
{
    [(NSMutableArray *)_fields addObject: field];
}

- (void)update: (NSTimeInterval)dt
{
    for (VEField *filed in _fields)
    {
        [filed applyOnObjects: _objects];
    }

    [_scene update: dt];
}

- (void)render
{
    [_scene render];
}

@end
