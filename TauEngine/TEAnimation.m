//
//  TEAnimation.m
//  TauGame
//
//  Created by Ian Terrell on 7/12/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEAnimation.h"
#import "TENode.h"


@implementation TEAnimation

@synthesize node = _node;
@synthesize next = _next;

@synthesize elapsedTime = _elapsedTime;
@synthesize duration = _duration;

@synthesize repeat = _repeat;

@synthesize easing = _easing;
@synthesize remove = _remove;
@synthesize reverse = _reverse;

@synthesize permanent = _permanent;

@synthesize onRemoval = _onRemoval;
@synthesize onComplete = _onComplete;

- (id)init
{
    self = [super init];
    if (self)
    {
        _easing = kTEAnimationEasingLinear;
        _forward = YES;
        _reverse = NO;
        _permanent = NO;
        _elapsedTime = 0.0;
    }
    
    return self;
}

- (id)initWithNode: (TENode *)node
{
    self = [self init];
    if (self)
    {
        [self setNode: node];
    }
    
    return self;
}

#pragma mark - Easing

- (float)percentDone
{
    return _forward ? _elapsedTime / _duration : 1.0 - _elapsedTime / _duration;
}

- (float)easingFactor
{
    switch (easing)
    {
        case kTEAnimationEasingLinear:
        {
            return [self percentDone];
        }
        default:
        {
            return 0.0;
        }
    }
}

#pragma mark - Updating

- (void)incrementElapsedTime: (NSTimeInterval)time
{
    _elapsedTime += time;
    if (_elapsedTime >= _duration)
    {
        // Reverse the animation if going forward and set to reverse
        if (_forward && _reverse)
        {
            _elapsedTime -= _duration;
            _forward = !_forward;
        }
        // Repeat the animation if we have repeats left
        else if (_repeat > 0 || _repeat == kTEAnimationRepeatForever)
        {
            _forward = !_forward;
            _elapsedTime -= _duration;
            
            // Perform onComplete since a cycle is up
            if (_onComplete)
            {
                _onComplete();
            }
            // Keep track of how many times we've repeated
            if (repeat > 0)
                repeat -= 1;
        }
        // We're done!
        else
        {
            if (_onComplete)
            {
                _onComplete();
            }
            if (_permanent)
            {
                _elapsedTime = 0;
                [self permanentize];
            }
            _remove = YES;
        }
    }
}

#pragma mark - Going backward!

- (BOOL)backward
{
    return !_forward;
}

- (void)setBackward: (BOOL)backward
{
    _forward = !backward;
}

#pragma mark - Permanentizing

- (void)setPermanent: (BOOL)permanent
{
    if (permanent && _node == nil)
    {
        NSLog(@"WARNING! Permanentize will fail if node is not set.");
    }
    
    _permanent = permanent;
}

- (void)permanentize
{
    NSLog(@"Permanentize ot yet implemented by %@.", [[self class] description]);
}

@end
