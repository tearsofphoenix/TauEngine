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
    [scene setBounds: CGRectMake(0, 0, 10, 10)];
    [scene setBackgroundColor: [VGColor redColor]];
    
	[director_ pushScene: scene];
    
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

static IMP _fIMP = NULL;

static void fire(id timer, SEL selector)
{
    NSLog(@"f %s %@",  __func__, [NSThread callStackSymbols]);
    _fIMP(timer, selector);
}

static IMP _allocIMP = NULL;

static id _allocF(id className, SEL selector)
{
    NSLog(@"f %s %@",  __func__, [NSThread callStackSymbols]);
    return _allocIMP(className, selector);
}

static IMP _allocZoneIMP = NULL;
static id allocWithZone(id className, SEL selector, NSZone *zone)
{
    NSLog(@"f %s %@",  __func__, [NSThread callStackSymbols]);
    return _allocZoneIMP(className, selector, zone);
}

static IMP _addTimerIMP = NULL;
static void addTimer(id t, SEL selector, void *timer)
{
    NSLog(@"f %s %@",  __func__, [NSThread callStackSymbols]);
    
    _addTimerIMP(t, selector, timer);
}

static IMP _initIMP = NULL;
static id init(id e, SEL selector)
{
    NSLog(@"f %s %@",  __func__, [NSThread callStackSymbols]);
    return _initIMP(e, selector);
}

static IMP _renderIMP = NULL;
static id render(id obj, SEL selector, id context, id options)
{
    NSLog(@"f %s %@",  __func__, [NSThread callStackSymbols]);
    return _renderIMP(obj, selector, context, options);
}

static IMP _kvoIMP = NULL;
static void kvo(id obj, SEL selector, NSString *string, id value, id change, void *context)
{
    NSLog(@"in func: %s %@", __FUNCTION__, [NSThread callStackSymbols]);
    
    _kvoIMP(obj, selector, string, value, change, context);
}

static IMP _innerDisplay = NULL;
static void _display(id obj, SEL selector)
{
    NSLog(@"in func: %s %@", __FUNCTION__, [NSThread callStackSymbols]);
    
    _innerDisplay(obj, selector);
}

+ (void)load
{
    /*
    Class timerClass = objc_getClass("NSTimer");
    _fIMP = class_getMethodImplementation(timerClass, @selector(fire));
    class_replaceMethod(timerClass, @selector(fire), (IMP)fire, "v@:");
    
    Class metaClass = objc_getMetaClass("NSTimer");
    _allocIMP = class_getMethodImplementation(metaClass, @selector(alloc));
    class_replaceMethod(metaClass, @selector(alloc), (IMP)_allocF, "@@:");
    
    _allocZoneIMP = class_getMethodImplementation(metaClass, @selector(allocWithZone:));
    class_replaceMethod(metaClass, @selector(allocWithZone:), (IMP)allocWithZone, "@@:@");
    
    Class transaction = objc_getClass("CATransaction");
    _initIMP = class_getMethodImplementation(transaction, @selector(init));
    class_replaceMethod(transaction, @selector(init), (IMP)init, "@@:");
    
    Class render = objc_getMetaClass("CARenderer");
    _renderIMP = class_getMethodImplementation(render, @selector(rendererWithEAGLContext:options:));
    class_replaceMethod(render, @selector(rendererWithEAGLContext:options:), (IMP)render, "@16@0:4@8@12");
     */
    
//    Class layerClass = objc_getClass("CALayer");
//    _kvoIMP = class_getMethodImplementation(layerClass, @selector(observeValueForKeyPath:ofObject:change:context:));
//    class_replaceMethod(layerClass, @selector(observeValueForKeyPath:ofObject:change:context:), (IMP)kvo, "v@:@@@@");
    
//    _innerDisplay = class_getMethodImplementation(layerClass, @selector(_display));
//    class_replaceMethod(layerClass, @selector(_display), (IMP)_display, "v@:");
}

@end

