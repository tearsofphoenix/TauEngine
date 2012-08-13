//
//  VESpriteAnimation.h
//  ExampleEngine
//
//  Created by Ian Terrell on 8/22/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface VESpriteAnimation : NSObject
{
    NSMutableArray *_frames;
    NSTimeInterval _timePerFrame;
    NSTimeInterval _elapsedTime;
}

- (id)initWithTimePerFrame: (NSTimeInterval)timePerFrame
               framesNamed: (NSArray *)frameNames;

- (void)update: (NSTimeInterval)dt;

- (GLKTextureInfo *)currentFrame;

@end
