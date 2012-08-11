//
//  TEButton.m
//  TauGame
//
//  Created by Ian Terrell on 8/12/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "TEButton.h"

@implementation TEButton

@synthesize action = _action;
@synthesize hightLight = _hightLight;

+ (id)buttonWithDrawable: (TEDrawable *)drawable
{
    TEButton *node = [[TEButton alloc] init];
    [node setDrawable: drawable];
    return [node autorelease];
}

- (void)dealloc
{
    if (_action)
    {
        Block_release(_action);
    }
    
    [super dealloc];
}

- (void)setHightLight: (BOOL)hightLight
{
    
}

- (void)fire
{
    if (_action)
    {
        _action();
    }
}

@end
