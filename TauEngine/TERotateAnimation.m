//
//  TERotateAnimation.m
//  TauGame
//
//  Created by Ian Terrell on 7/13/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TERotateAnimation.h"
#import "TENode.h"

@implementation TERotateAnimation

@synthesize rotation = _rotation;

- (id)init
{
    self = [super init];
    if (self)
    {
        _rotation = 0.0;
    }
    
    return self;
}

- (float)easedRotation
{
    return self.easingFactor * _rotation;
}

- (void)permanentize
{
    self.node.rotation += _rotation;
}

@end
