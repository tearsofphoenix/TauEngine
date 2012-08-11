//
//  TETranslateAnimation.m
//  TauGame
//
//  Created by Ian Terrell on 7/13/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TETranslateAnimation.h"
#import "TENode.h"

@implementation TETranslateAnimation

@synthesize translation = _translation;

- (id)init
{
    self = [super init];
    if (self)
    {
        _translation = GLKVector2Make(0.0, 0.0);
    }
    
    return self;
}

- (GLKVector2)easedTranslation
{
    return GLKVector2MultiplyScalar(_translation, self.easingFactor);
}

- (void)permanentize
{
    self.node.position = GLKVector2Add(self.node.position, _translation);
}

@end
