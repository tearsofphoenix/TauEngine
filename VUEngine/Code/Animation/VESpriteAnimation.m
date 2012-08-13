//
//  VESpriteAnimation.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/22/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "VESpriteAnimation.h"

@implementation VESpriteAnimation

- (id)initWithTimePerFrame: (NSTimeInterval)time
              framesNamed: (NSArray *)frameNames
{
    self = [super init];
    if (self)
    {
        _elapsedTime = 0;
        _timePerFrame = time;
        _frames = [[NSMutableArray alloc] initWithCapacity: [frameNames count]];
        for (NSString *name in frameNames)
        {
            GLKTextureInfo *texture = [GLKTextureLoader textureWithCGImage: [[UIImage imageNamed:name] CGImage]
                                                                   options: [NSDictionary dictionaryWithObject: [NSNumber numberWithBool:YES]
                                                                                                        forKey: GLKTextureLoaderOriginBottomLeft]
                                                                     error: NULL];
            [_frames addObject: texture];
        }
    }
    return self;
}

- (void)dealloc
{
    [_frames release];
    
    [super dealloc];
}

- (void)update: (NSTimeInterval)dt
{
    _elapsedTime += dt;
}

- (GLKTextureInfo *)currentFrame
{
    return [_frames objectAtIndex:((int)(_elapsedTime / _timePerFrame)) % [_frames count]];
}

@end
