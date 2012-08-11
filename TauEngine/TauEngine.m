//
//  TauEngine.m
//  TauGame
//
//  Created by Ian Terrell on 7/20/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TauEngine.h"


static CMMotionManager *s_motionManager = nil;

@implementation TauEngine

+ (CMMotionManager *)motionManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, (^
                               {
                                   s_motionManager = [[CMMotionManager alloc] init];
                               }));
    
    return s_motionManager;
}

@end
