//
//  Box2DAppDelegate.h
//  Box2D
//
//  Box2D iPhone port by Simon Oliver - http://www.simonoliver.com - http://www.handcircus.com
//

//
// File heavily modified for cocos2d integration
// http://www.cocos2d-iphone.org
//

#import <UIKit/UIKit.h>
#import "BaseApplicationDelegate.h"

@interface Box2DAppDelegate : BaseApplicationDelegate<UITableViewDataSource, UITableViewDelegate>

@end

@interface VELayer : CALayer

@end

@interface VEView : UIView

@end

