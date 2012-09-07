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

- (void)sendEvent: (UIEvent *)event
{
    NSLog(@"%@", event);
    [super sendEvent: event];
}

@end

@implementation BaseApplicationDelegate

@synthesize window=window_, navController=navController_, director=director_;

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
	director_ = (CCDirectorIOS*)[CCDirector sharedDirector];
	[director_ setDisplayStats:NO];
	[director_ setAnimationInterval:1.0/60];
	
    UIView *aView = [[UIView alloc] init];
    
    UIView *subView = [[UIView alloc] init];
    [aView addSubview: subView];
	// GL View
	VEGLView *__glView = [[VEGLView alloc] initWithFrame: [window_ bounds]];
	
	[director_ setView: __glView];
    
    [__glView release];
    
	[director_ setDelegate: self];
    
	director_.wantsFullScreenLayout = YES;
    
	// Retina Display ?
	[director_ enableRetinaDisplay:useRetinaDisplay_];
	
	// Navigation Controller
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
    
	// AddSubView doesn't work on iOS6
	[window_ addSubview:navController_.view];
    //	[window_ setRootViewController:navController_];
    
	[window_ makeKeyAndVisible];
    
	return YES;
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	[[CCDirector sharedDirector] end];
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[director_ purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[director_ setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window_ release];
	[navController_ release];
    
	[super dealloc];
}

@end

