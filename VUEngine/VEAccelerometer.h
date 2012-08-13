//
//  VEAccelerometer.h
//  TauGame
//
//  Created by Ian Terrell on 7/20/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VUEngine.h"

@interface VEAccelerometer : NSObject <UIAccelerometerDelegate>

+ (void)zero;

+ (float)horizontalForOrientation: (UIInterfaceOrientation)orientation;

@end
