//
//  VESoundManager.h
//  TauGame
//
//  Created by Ian Terrell on 7/25/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>

@interface VESoundManager : NSObject
{
    NSMutableDictionary *_sounds;
}

+ (VESoundManager *)sharedManager;

- (void)load: (NSString *)filename;

- (void)play: (NSString *)sound;

@end
