//
//  TEDrawable.m
//  TauGame
//
//  Created by Ian Terrell on 7/11/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEDrawable.h"
#import "TauEngine.h"

@implementation TEDrawable

@synthesize node = _node;

- (void)dealloc
{
    [_node release];
    
    [super dealloc];
}

- (void)renderInScene:(TEScene *)scene
{
    
}

@end
