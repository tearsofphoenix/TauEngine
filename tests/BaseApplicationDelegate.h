//
//  AppController.h
//  cocos2d-ios
//
//  Created by Ricardo Quesada on 12/17/11.
//  Copyright (c) 2011 Sapus Media. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

@interface VAWindow : UIWindow

@end

@class UIWindow;

@interface BaseApplicationDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;

	BOOL			useRetinaDisplay_;
	VEDirector	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) VEDirector *director;

@end

