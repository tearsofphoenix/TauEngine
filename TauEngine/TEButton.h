//
//  TEButton.h
//  TauGame
//
//  Created by Ian Terrell on 8/12/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "TENode.h"

@interface TEButton : TENode

@property (nonatomic, copy) TEActionBlock action;

+ (id)buttonWithDrawable: (TEDrawable *)drawable;

- (void)highlight;

- (void)unhighlight;

- (void)fire;

@end
