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

@implementation Box2DAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];
    
    [application setStatusBarHidden:true];
    
	// Turn on display FPS
	[director_ setDisplayStats:YES];
    
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
    
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:NO] )
    {
		CCLOG(@"Retina Display Not supported");
    }
    
	CCScene *scene = [CCScene node];
    MenuLayer *menuLayer = [MenuLayer menuWithEntryID: 0];
	[scene addChild: menuLayer];
    
	[director_ pushScene: scene];
    
    
    UITableView *entriesView = [[UITableView alloc] init];
    [entriesView setFrame: CGRectMake(0, 0, 200, 400)];
    
    [entriesView setDataSource: menuLayer];
    [entriesView setDelegate: menuLayer];
    
    [[director_ view] addSubview: entriesView];
    //    [entriesView setAlpha: 0];
    
    printf("\t\t\t%f\n", [NSDate timeIntervalSinceReferenceDate]);
        
    [entriesView release];
    
	return YES;
}


@end

