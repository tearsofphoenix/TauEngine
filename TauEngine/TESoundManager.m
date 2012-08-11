//
//  TESoundManager.m
//  TauGame
//
//  Created by Ian Terrell on 7/25/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TESoundManager.h"

@implementation TESoundManager

- (id)init
{
    self = [super init];
    if (self)
    {
        sounds = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

+ (TESoundManager *)sharedManager
{
    static TESoundManager *singleton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, (^
                               {
                                   singleton = [[TESoundManager alloc] init];
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
        [sounds setObject: [NSNumber numberWithUnsignedInt: soundID]
                   forKey: filename];
    }else
    {
        NSLog(@"Could not load sound '%@.wav'", filename);
    }
}

- (void)play: (NSString *)sound
{
    NSNumber *soundID = (NSNumber *)[sounds objectForKey:sound];
    
    if (soundID != nil)
    {
        AudioServicesPlaySystemSound([soundID unsignedIntValue]);
        
    }else
    {
        NSLog(@"Sound '%@.wav' has not been loaded.", sound);
    }
}

@end
