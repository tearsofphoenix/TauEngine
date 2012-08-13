//
//  VEAppDelegate.h
//  ExampleEngine
//
//  Created by Ian Terrell on 8/16/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "VEScene.h"

@interface VEAppDelegate : UIResponder <UIApplicationDelegate, GLKViewDelegate, GLKViewControllerDelegate> {
  VEScene *scene;
}

@property (strong, nonatomic) UIWindow *window;

- (void) nextScene:(id) sender;
@end
