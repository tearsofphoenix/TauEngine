//
//  VEGravityField.h
//  VUEngine
//
//  Created by LeixSnake on 8/14/12.
//  Copyright (c) 2012 Ian Terrell. All rights reserved.
//

#import "VEField.h"

@class VEQualityObject;

@interface VEGravityField : VEField

@property (nonatomic) GLKVector2 gravity;

- (void)applyOnObject: (VEQualityObject *)qualityObject;

@end
