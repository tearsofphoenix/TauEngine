//
//  VUEngine.h
//  TauGame
//
//  Created by Ian Terrell on 7/11/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>

#import "VEAccelerometer.h"

//Animation
#import "VEAnimation.h"
#import "VESpriteAnimation.h"

//Scene
#import "VEScene.h"
#import "VESceneController.h"

//Shapes
#import "VEEllipse.h"
#import "VERectangle.h"
#import "VERegularPolygon.h"
#import "VEShape.h"
#import "VESprite.h"
#import "VETriangle.h"

#import "VESoundManager.h"

#import "VERandom.h"

@interface VUEngine : NSObject

+ (CMMotionManager *)motionManager;

@end

