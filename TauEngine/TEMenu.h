//
//  TEMenu.h
//  TauGame
//
//  Created by Ian Terrell on 8/12/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "TEScene.h"
#import "TEButton.h"

@interface TEMenu : TEScene
{
    NSMutableArray *_buttons;
    TEButton *_currentButton;
}

@property (nonatomic) BOOL enabled;

- (void)addButton: (TEButton*)button;
- (void)removeButton: (TEButton*)button;

@end
