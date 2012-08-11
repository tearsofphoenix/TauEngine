//
//  TEColorAnimation.m
//  TauGame
//
//  Created by Ian Terrell on 7/25/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEColorAnimation.h"
#import "TEShape.h"
#import "TENode.h"

@implementation TEColorAnimation

@synthesize color = _color;
@synthesize previousColor = _previousColor;

- (id)initWithNode: (TENode *)node
{
    self = [super initWithNode: node];
    if (self)
    {
        _color = [self node].shape.color;
        _previousColor = _color;
    }
    
    return self;
}

- (GLKVector4)easedColor
{
    return GLKVector4MultiplyScalar(GLKVector4Subtract(_color, _previousColor), self.easingFactor);
}

- (void)permanentize
{
    self.node.shape.color = _color;
}

@end
