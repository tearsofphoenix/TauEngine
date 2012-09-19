//
//  Box2DAppDelegate.m
//  Box2D
//
//  Box2D iPhone port by Simon Oliver - http://www.simonoliver.com - http://www.handcircus.com
//

//
// File heavily modified for cocos2d integration
// http://www.cocos2d-iphone.org
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Box2DAppDelegate.h"
#import "Box2DView.h"
#import "cocos2d.h"
#import <objc/runtime.h>

@implementation Box2DAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];
    
    [application setStatusBarHidden:true];
    
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
    
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:NO] )
    {
		CCLOG(@"Retina Display Not supported");
    }
    
    VAScene *scene = [VAScene layer];
    [scene setFrame: CGRectMake(0, 0, 1024 / 2, 768 / 2)];
    
    VALayer *layer = [VALayer layer];
    [layer setFrame: [scene bounds]];
    //[layer setTransform: GLKMatrix4MakeScale(1.0, 0.5, 1.0)];
    
    //[layer setBounds: CGRectMake(100, 100, 200, 200)];
    
//    [layer setBackgroundColor: [VGColor redColor]];
    [scene addSublayer: layer];
    
    Box2DView *view = [[Box2DView alloc] initWithEntryID: 1];
    [view setFrame: [scene bounds]];
    
    [layer addSublayer: view];
    
    [view release];
    
//    VALayer *aSubLayer = [VALayer layer];
//    [aSubLayer setFrame: CGRectMake(10, 10, 100, 100)];
//    [aSubLayer setBackgroundColor: [VGColor greenColor]];
    //[aSubLayer setAffineTransform: CGAffineTransformConcat(CGAffineTransformMakeScale(0.5, 0.5), CGAffineTransformMakeRotation(0))];
    //[aSubLayer setAffineTransform: CGAffineTransformMakeScale(0.5, 0.5)];

    //[aSubLayer setCornerRadius: 20];
    
//    [layer addSublayer: aSubLayer];
    
	[director_ pushScene: scene];
    [scene setOpacity: 0];
    
//    [VAScene animateWithDuration: 2.0
//                      animations: (^
//                                   {
//                                       [scene setBackgroundColor: [VGColor greenColor]];
//                                   })
//                      completion: (^(BOOL finished)
//                                   {
//                                       NSLog(@"in func: %s", __FUNCTION__);
//                                   })];
    
    //    UITableView *entriesView = [[UITableView alloc] init];
    //    [entriesView setFrame: CGRectMake(0, 0, 200, 400)];
    //
    ////    [entriesView setDataSource: menuLayer];
    ////    [entriesView setDelegate: menuLayer];
    //
    //    [[director_ view] addSubview: entriesView];
    //    [entriesView setAlpha: 0];
    //
    //    [UIView animateWithDuration: 2.0
    //                     animations: (^
    //                                  {
    //                                      //NSLog(@"f %s %@",  __func__, [NSThread callStackSymbols]);
    //
    //                                      [entriesView setAlpha: 1];
    //                                  })
    //                     completion: (^(BOOL finished)
    //                                  {
    //                                      //NSLog(@"f %s %@",  __func__, [NSThread callStackSymbols]);
    //
    //                                  })];
    //
    //    printf("\t\t\t%f\n", [NSDate timeIntervalSinceReferenceDate]);
    //
    //    [entriesView release];
    //
	return YES;
}

@end

