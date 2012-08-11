//
//  TEAccelerometer.m
//  TauGame
//
//  Created by Ian Terrell on 7/20/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEAccelerometer.h"

static CGFloat s_previousHorizontal = 0.0;

static CGFloat kFilterFactor = 0.05;

static CMAcceleration s_calibration;

@implementation TEAccelerometer;

+ (void)zero
{
    s_calibration = [[[TauEngine motionManager] accelerometerData] acceleration];
}

+ (float)horizontalForOrientation: (UIInterfaceOrientation)orientation
{
    CMAcceleration accel = [[[TauEngine motionManager] accelerometerData] acceleration];
    
    float horizontal;
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        {
            horizontal = (accel.x - s_calibration.x);
            break;
        }
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            horizontal = -1*(accel.x - s_calibration.x);
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:
        {
            horizontal = (accel.y - s_calibration.y);
            break;
        }
        case UIInterfaceOrientationLandscapeRight:
        {
            horizontal = -1*(accel.y - s_calibration.y);
            break;
        }
        default:
        {
            horizontal = (accel.x - s_calibration.x);
            break;
        }
    }
    
    horizontal = horizontal * kFilterFactor + (1 - kFilterFactor) * s_previousHorizontal;
    
    s_previousHorizontal = horizontal;
    
    return horizontal;
}

@end
