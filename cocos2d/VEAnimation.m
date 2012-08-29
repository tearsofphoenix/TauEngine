//
//  VEAnimation.m
//  VUEngine
//
//  Created by LeixSnake on 8/29/12.
//
//

#import "VEAnimation.h"

@implementation VEAnimation

static NSMutableDictionary *__VEAnimationDefaultKeyValues = nil;

+ (void)load
{
    __VEAnimationDefaultKeyValues = [[NSMutableDictionary alloc] init];
    [__VEAnimationDefaultKeyValues setObject: kVEFillModeRemoved
                                      forKey: @"fillMode"];
    [__VEAnimationDefaultKeyValues setObject: [NSNumber numberWithFloat: 1]
                                      forKey: @"speed"];
}

+ (id)animation
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    if ((self = [super init]))
    {
        _timingFunction = nil;
        _delegate = nil;
        _removedOnCompletion = YES;
    }
    return self;
}

+ (id)defaultValueForKey: (NSString *)key
{
    return [__VEAnimationDefaultKeyValues objectForKey: key];
}

- (BOOL)shouldArchiveValueForKey:(NSString *)key
{
    return YES;
}

@synthesize timingFunction = _timingFunction;

@synthesize delegate = _delegate;

@synthesize removedOnCompletion = _removedOnCompletion;

#pragma mark - NSCoding

- (id)initWithCoder: (NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        
    }
    return self;
}

- (void)encodeWithCoder: (NSCoder *)aCoder
{
    
}

#pragma mark - NSCoping

- (id)copyWithZone: (NSZone *)zone
{
    id copy = [[[self class] allocWithZone: zone] init];
    return copy;
}

#pragma mark - VEMediaTiming

/* The begin time of the object, in relation to its parent object, if
 * applicable. Defaults to 0. */

@synthesize beginTime = _beginTime;

/* The basic duration of the object. Defaults to 0. */

@synthesize duration = _duration;

/* The rate of the layer. Used to scale parent time to local time, e.g.
 * if rate is 2, local time progresses twice as fast as parent time.
 * Defaults to 1. */

@synthesize speed = _speed;

/* Additional offset in active local time. i.e. to convert from parent
 * time tp to active local time t: t = (tp - begin) * speed + offset.
 * One use of this is to "pause" a layer by setting `speed' to zero and
 * `offset' to a suitable value. Defaults to 0. */

@synthesize timeOffset = _timeOffset;

/* The repeat count of the object. May be fractional. Defaults to 0. */

@synthesize repeatCount = _repeatCount;

/* The repeat duration of the object. Defaults to 0. */

@synthesize repeatDuration = _repeatDuration;

/* When true, the object plays backwards after playing forwards. Defaults
 * to NO. */

@synthesize autoreverses = _autoreverses;

/* Defines how the timed object behaves outside its active duration.
 * Local time may be clamped to either end of the active duration, or
 * the element may be removed from the presentation. The legal values
 * are `backwards', `forwards', `both' and `removed'. Defaults to
 * `removed'. */

@synthesize fillMode = _fillMode;

@end
