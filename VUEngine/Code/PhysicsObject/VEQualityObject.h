//
//  VEQualityObject.h
//  VUEngine
//
//  Created by LeixSnake on 8/14/12.
//  Copyright (c) 2012 Ian Terrell. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VEShape;

@interface VEQualityObject : NSObject

@property (nonatomic, strong) VEShape *shape;

@property (nonatomic) float quality;

@end
