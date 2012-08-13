//
//  VEAppDelegate.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/16/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "VEAppDelegate.h"
#import "VESceneController.h"
#import "WalkingAnimationScene.h"
#import "BeachBallScene.h"
#import "PrettyAPIMoveScene.h"
#import "AccelerationScene.h"
#import "ColorChangeScene.h"
#import "ComplexAnimationScene.h"
#import "ForestScene.h"
#import "HexagonScene.h"
#import "LandscapeScene.h"
#import "ManuallyMovedTree.h"
#import "OptimizedTree.h"
#import "PrettyAPIMoveScene.h"
#import "RectangleScene.h"
#import "RotatingTreeScene.h"
#import "SierpinskyTriangleScene.h"
#import "SpriteScene.h"
#import "TreeScene.h"
#import "TriangleScene.h"
#import "VelocityScene.h"


@implementation VEAppDelegate

@synthesize window = _window;

NSArray *arrayOfScenes;
int indexOfScene;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext: context];
    [context release];
    
    GLKView *view = [[GLKView alloc] initWithFrame: [[UIScreen mainScreen] bounds]
                                           context: context];
    [view setDelegate: self];
    
    VESceneController *controller = [[VESceneController alloc] init];
    [controller setDelegate: self];
    [controller setView: view];
    
    [view release];
    
    _window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController: controller];
    [_window setRootViewController: nav];

    [controller release];
    [nav release];
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle: @"Next"
                                     style: UIBarButtonItemStyleBordered
                                     target: self
                                     action: @selector(nextScene:)];
    [[controller navigationItem] setRightBarButtonItem: rightBarItem];

    [rightBarItem release];
    
    [_window makeKeyAndVisible];
    
    // setup arrayOfScenes
    indexOfScene = -1;
    
    arrayOfScenes = [[NSArray alloc] initWithObjects: [[[PrettyAPIMoveScene alloc] init] autorelease],
                     [[[BeachBallScene alloc] init] autorelease],
                     [[[WalkingAnimationScene alloc] init] autorelease],
                     [[[AccelerationScene alloc] init] autorelease],
                     [[[ColorChangeScene alloc] init] autorelease],
                     [[[ComplexAnimationScene alloc] init] autorelease],
                     [[[ForestScene alloc] init] autorelease],
                     [[[LandscapeScene alloc] init] autorelease],
                     [[[ManuallyMovedTree alloc] init] autorelease],
                     
                     //[[OptimizedTree alloc] init],
                     
                     [[[RotatingTreeScene alloc] init] autorelease],
                     [[[SierpinskyTriangleScene alloc] init] autorelease],
                     [[[SpriteScene alloc] init] autorelease],
                     [[[TriangleScene alloc] init] autorelease],
                     [[[VelocityScene alloc] init] autorelease],
                     //                     [[HexagonScene alloc] init],
                     //                     [[PrettyAPIMoveScene alloc] init],
                     //                     [[RectangleScene alloc] init],
                     nil];
    
    [self nextScene: self];
    
    return YES;
}

- (void)nextScene:(id) sender
{
    indexOfScene =  (indexOfScene >= [arrayOfScenes count] -1) ? 0 : indexOfScene + 1;
    VEScene *newScene = [arrayOfScenes objectAtIndex:indexOfScene];
    ((UINavigationController *)self.window.rootViewController).topViewController.title = NSStringFromClass([newScene class]);
    
    scene = newScene;
    scene.clearColor = GLKVector4Make(1,1,1,1);
    [scene setEdgeInsets: UIEdgeInsetsMake(2, -3, -2, 3)];
}

- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    //  NSLog(@"in glkViewControllerUpdate");
    [scene update:controller.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //  NSLog(@"in glkView:drawInRect:");
    [scene render];
}
@end
