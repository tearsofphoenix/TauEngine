//
//  AppDelegate.m
//  TauExample
//
//  Created by LeixSnake on 8/11/12.
//  Copyright (c) 2012 Ian Terrell. All rights reserved.
//

#import "AppDelegate.h"
#import "TauEngine.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (id)foo
{
    
    id block = (^
                {
                    printf("in func: %s\n", __func__);
                });
    
    @autoreleasepool
    {
        block = [block copy];
    }
    
    return block;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [_window setBackgroundColor: [UIColor grayColor]];
    [_window makeKeyAndVisible];
    
    TESceneController *sceneController = [[TESceneController alloc] init];
    [_window setRootViewController: sceneController];
    [sceneController release];
    
    TEScene *scene = [[TEScene alloc] initWithFrame: [_window bounds]];
    [sceneController addScene: scene
                        named: @"com.veritas.mainscene"];

    [scene render];
    
    TETriangle *triangle = [[TETriangle alloc] init];
    [triangle setColor: GLKVector4Make(1.0, 0, 0, 1.0)];
    TENode *node = [TENode nodeWithDrawable: triangle];
    
    [scene addCharacterAfterUpdate: node];
    
    
    return YES;
}

@end