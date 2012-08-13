//
//  VEAnimation.h
//  ExampleEngine
//
//  Created by Ian Terrell on 8/19/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class VEShape;

@interface VEAnimation : NSObject
{
    NSTimeInterval _elapsedTime;    
}

@property (nonatomic) NSTimeInterval duration;

@property (nonatomic, readonly) NSTimeInterval elapsedTime;

@property (nonatomic) GLKVector2 positionDelta;
@property (nonatomic) GLKVector2  scaleDelta;

@property (nonatomic) float rotationDelta;

@property (nonatomic) GLKVector4 colorDelta;

- (void)animateShape: (VEShape *)shape
                  dt: (NSTimeInterval)dt;

@end
