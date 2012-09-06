//
//  VAMediaTiming.h
//  VUEngine
//
//  Created by LeixSnake on 8/29/12.
//
//
#import <Foundation/Foundation.h>
#import <objc/objc.h>



/* The VAMediaTiming protocol is implemented by layers and animations, it
 * models a hierarchical timing system, with each object describing the
 * mapping from time values in the object's parent to local time.
 *
 * Absolute time is defined as mach time converted to seconds. The
 * VECurrentMediaTime function is provided as a convenience for querying the
 * current absolute time.
 *
 * The conversion from parent time to local time has two stages:
 *
 * 1. conversion to "active local time". This includes the point at
 * which the object appears in the parent's timeline, and how fast it
 * plays relative to the parent.
 *
 * 2. conversion from active to "basic local time". The timing model
 * allows for objects to repeat their basic duration multiple times,
 * and optionally to play backwards before repeating. */

@class NSString;

@protocol VAMediaTiming

/* The begin time of the object, in relation to its parent object, if
 * applicable. Defaults to 0. */

@property (atomic) CFTimeInterval beginTime;

/* The basic duration of the object. Defaults to 0. */

@property (atomic) CFTimeInterval duration;

/* The rate of the layer. Used to scale parent time to local time, e.g.
 * if rate is 2, local time progresses twice as fast as parent time.
 * Defaults to 1. */

@property (atomic) float speed;

/* Additional offset in active local time. i.e. to convert from parent
 * time tp to active local time t: t = (tp - begin) * speed + offset.
 * One use of this is to "pause" a layer by setting `speed' to zero and
 * `offset' to a suitable value. Defaults to 0. */

@property (atomic) CFTimeInterval timeOffset;

/* The repeat count of the object. May be fractional. Defaults to 0. */

@property (atomic) float repeatCount;

/* The repeat duration of the object. Defaults to 0. */

@property (atomic) CFTimeInterval repeatDuration;

/* When true, the object plays backwards after playing forwards. Defaults
 * to NO. */

@property (atomic) BOOL autoreverses;

/* Defines how the timed object behaves outside its active duration.
 * Local time may be clamped to either end of the active duration, or
 * the element may be removed from the presentation. The legal values
 * are `backwards', `forwards', `both' and `removed'. Defaults to
 * `removed'. */

@property(atomic, copy) NSString *fillMode;

@end

/* `fillMode' options. */

CF_EXPORT NSString * const kVEFillModeForwards;

CF_EXPORT NSString * const kVEFillModeBackwards;

CF_EXPORT NSString * const kVEFillModeBoth;

CF_EXPORT NSString * const kVEFillModeRemoved;
