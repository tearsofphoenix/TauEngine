//
//  VESoundManager.m
//  TauGame
//
//  Created by Ian Terrell on 7/25/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "VESoundManager.h"

@implementation VESoundManager

- (id)init
{
    self = [super init];
    if (self)
    {
        _sounds = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_sounds release];
    
    [super dealloc];
}

+ (VESoundManager *)sharedManager
{
    static VESoundManager *singleton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, (^
                               {
                                   singleton = [[VESoundManager alloc] init];
                               }));
    return singleton;
}

- (void)load: (NSString *)filename
{
    
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource: filename
                                                              ofType: @"wav"];
    SystemSoundID soundID;
    
    if (AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath: soundFilePath], &soundID) == kAudioServicesNoError)
    {
        [_sounds setObject: [NSNumber numberWithUnsignedInt: soundID]
                    forKey: filename];
    }else
    {
        NSLog(@"Could not load sound '%@.wav'", filename);
    }
}

- (void)play: (NSString *)soundName
{
    NSNumber *soundID = [_sounds objectForKey: soundName];
    
    if (soundID != nil)
    {
        AudioServicesPlaySystemSound([soundID unsignedIntValue]);
        
    }else
    {
        NSLog(@"Sound '%@.wav' has not been loaded.", soundName);
    }
}

@end
