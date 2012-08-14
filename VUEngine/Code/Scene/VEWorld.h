//
//  VEWorld.h
//  VUEngine
//
//  Created by LeixSnake on 8/14/12.
//  Copyright (c) 2012 Ian Terrell. All rights reserved.
//

@class VEScene;

@class VEQualityObject;

@class VEField;

@interface VEWorld : NSObject
{
    NSMutableArray *_objects;
}

@property (nonatomic, strong) VEScene *scene;

@property (nonatomic, strong) NSArray *fields;

- (void)addField: (VEField *)field;

- (void)addObject: (VEQualityObject *)object;

- (void)update: (NSTimeInterval)dt;

- (void)render;

@end
