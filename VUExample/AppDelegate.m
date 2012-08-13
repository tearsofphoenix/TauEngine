//
//  AppDelegate.m
//  TauExample
//
//  Created by LeixSnake on 8/11/12.
//  Copyright (c) 2012 Ian Terrell. All rights reserved.
//

#import "AppDelegate.h"
#import "VUEngine.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [_window setBackgroundColor: [UIColor grayColor]];
    [_window makeKeyAndVisible];
    
    return YES;
}

@end
