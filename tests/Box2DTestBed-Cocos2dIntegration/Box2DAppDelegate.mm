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
    
    VEView *aView = [[VEView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
    [aView setBackgroundColor: [UIColor redColor]];
    [[director_ view] addSubview: aView];
    //[aView setAlpha: 0];
//    [UIView animateWithDuration: 1.0
//                     animations: (^
//                                  {
//                                      [aView setAlpha: 0];
//                                  })];
    
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"opacity"];
//    [animation setFromValue: [NSNumber numberWithFloat: 1]];
//    [animation setToValue: [NSNumber numberWithFloat: 0]];
//    [animation setDuration: 2];
//    [animation setRemovedOnCompletion: YES];
//    
//    [[aView layer] addAnimation: animation
//                         forKey: @"aci"];
    
    [entriesView release];
    
	return YES;
}


@end

@implementation VELayer

- (id)presentationLayer
{
    id value = [super presentationLayer];
    NSLog(@"in func: %s self: %@ %@ %@", __func__, self, value, [NSThread callStackSymbols]);
    return value;
}

- (id)modelLayer
{
    id value = [super modelLayer];
    NSLog(@"in func: %s self: %@ %@ %@", __FUNCTION__, self, value, [NSThread callStackSymbols]);
    return value;
}

- (id)initWithLayer: (id)layer
{
    if ((self = [super initWithLayer: layer]))
    {
        NSLog(@"in func: %s self: %@ %@ %@", __FUNCTION__, self, layer, [NSThread callStackSymbols]);
    }
    return self;
}


@end

@implementation VEView

+ (Class)layerClass
{
    return [VELayer class];
}

@end
