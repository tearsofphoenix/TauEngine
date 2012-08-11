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
@property (nonatomic, getter = isHightLigt) BOOL hightLight;

+ (id)buttonWithDrawable: (TEDrawable *)drawable;

- (void)fire;

@end
