//
//  TEAnimation.h
//  TauGame
//
//  Created by Ian Terrell on 7/12/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "TENode.h"

@class TEAnimation;

enum
{
    kTEAnimationEasingLinear = 0,
};

typedef NSUInteger TEAnimationEasingType;

#define kTEAnimationRepeatForever -1

@interface TEAnimation : NSObject
{
    TEAnimationEasingType easing;
    int repeat;
    BOOL _forward;
}

@property (nonatomic, strong) TENode *node;

@property (nonatomic, strong) TEAnimation *next;

@property (nonatomic) TEAnimationEasingType easing;

@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic) NSTimeInterval  duration;

@property (nonatomic) int repeat;
@property (nonatomic) BOOL remove;
@property (nonatomic) BOOL  reverse;
@property (nonatomic) BOOL  backward;
@property (nonatomic) BOOL  permanent;

@property (nonatomic, copy) TEActionBlock onRemoval;
@property (nonatomic, copy) TEActionBlock onComplete;

@property (nonatomic, readonly) float percentDone;
@property (nonatomic, readonly) float easingFactor;

- (id)initWithNode: (TENode *)_node;

- (void)incrementElapsedTime: (double)time;

- (void)permanentize;

@end
