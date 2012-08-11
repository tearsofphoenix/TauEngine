//
//  TETranslateAnimation.h
//  TauGame
//
//  Created by Ian Terrell on 7/13/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEAnimation.h"

@interface TETranslateAnimation : TEAnimation

@property (nonatomic) GLKVector2 translation;
@property (nonatomic, readonly) GLKVector2 easedTranslation;

@end
