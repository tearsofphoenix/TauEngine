//
//  VEQualityObject.m
//  VUEngine
//
//  Created by LeixSnake on 8/14/12.
//  Copyright (c) 2012 Ian Terrell. All rights reserved.
//

#import "VEQualityObject.h"

#import "VEShape.h"

@implementation VEQualityObject

@synthesize shape = _shape;

@synthesize quality = _quality;

- (void)dealloc
{
    [_shape release];
    
    [super dealloc];
}

@end
