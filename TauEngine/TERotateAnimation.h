//
//  TERotateAnimation.h
//  TauGame
//
//  Created by Ian Terrell on 7/13/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEAnimation.h"

@interface TERotateAnimation : TEAnimation

@property (nonatomic) float rotation;

@property (nonatomic, readonly) float easedRotation;

@end
