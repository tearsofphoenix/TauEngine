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

- (void)highlight
{
    
}

- (void)unhighlight
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
