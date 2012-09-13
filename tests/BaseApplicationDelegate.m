//
//  AppController.m
//  cocos2d-ios
//
//  Created by Ricardo Quesada on 12/17/11.
//  Copyright (c) 2011 Sapus Media. All rights reserved.
//

#import "BaseApplicationDelegate.h"

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGLDrawable.h>

#import "cocos2d.h"

@implementation VAWindow

@end

@implementation BaseApplicationDelegate

@synthesize window=window_, director=director_;

-(id) init
{
	if( (self=[super init]) )
    {
		useRetinaDisplay_ = YES;
	}
	
	return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Main Window
	window_ = [[VAWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
	// Director
	director_ = [VEDirector sharedDirector];
	
    UIView *aView = [[UIView alloc] init];
    
    UIView *subView = [[UIView alloc] init];
    [aView addSubview: subView];
	// GL View
    
	director_.wantsFullScreenLayout = YES;
    
	// Retina Display ?
	[director_ enableRetinaDisplay:useRetinaDisplay_];
	
	// Navigation Controller
    [window_ setRootViewController: director_];
    
	[window_ makeKeyAndVisible];
    
	return YES;
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
    [director_ setPaused: YES];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
    [director_ setPaused: NO];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
    [director_ setPaused: YES];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
    [director_ setPaused: NO];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
//	[director_ setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window_ release];
    
	[super dealloc];
}

@end

