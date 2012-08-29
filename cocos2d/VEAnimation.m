//
//  VEAnimation.m
//  VUEngine
//
//  Created by LeixSnake on 8/29/12.
//
//
#import <UIKit/UIKit.h>
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

#pragma mark - VEPropertyAnimation

/** Subclass for property-based animations. **/

@implementation VEPropertyAnimation

/* Creates a new animation object with its `keyPath' property set to
 * 'path'. */

+ (id)animationWithKeyPath:(NSString *)path
{
    return nil;
}

@synthesize keyPath;

/* When true the value specified by the animation will be "added" to
 * the current presentation value of the property to produce the new
 * presentation value. The addition function is type-dependent, e.g.
 * for affine transforms the two matrices are concatenated. Defaults to
 * NO. */

@synthesize additive;

/* The `cumulative' property affects how repeating animations produce
 * their result. If true then the current value of the animation is the
 * value at the end of the previous repeat cycle, plus the value of the
 * current repeat cycle. If false, the value is simply the value
 * calculated for the current repeat cycle. Defaults to NO. */

@synthesize cumulative;

/* If non-nil a function that is applied to interpolated values
 * before they are set as the new presentation value of the animation's
 * target property. Defaults to nil. */

@synthesize valueFunction;

@end


/** Subclass for basic (single-keyframe) animations. **/

@implementation VEBasicAnimation

/* The objects defining the property values being interpolated between.
 * All are optional, and no more than two should be non-nil. The object
 * type should match the type of the property being animated (using the
 * standard rules described in VELayer.h). The supported modes of
 * animation are:
 *
 * - both `fromValue' and `toValue' non-nil. Interpolates between
 * `fromValue' and `toValue'.
 *
 * - `fromValue' and `byValue' non-nil. Interpolates between
 * `fromValue' and `fromValue' plus `byValue'.
 *
 * - `byValue' and `toValue' non-nil. Interpolates between `toValue'
 * minus `byValue' and `toValue'.
 *
 * - `fromValue' non-nil. Interpolates between `fromValue' and the
 * current presentation value of the property.
 *
 * - `toValue' non-nil. Interpolates between the layer's current value
 * of the property in the render tree and `toValue'.
 *
 * - `byValue' non-nil. Interpolates between the layer's current value
 * of the property in the render tree and that plus `byValue'. */

@synthesize fromValue;
@synthesize toValue;
@synthesize byValue;

@end


/** General keyframe animation class. **/

@implementation VEKeyframeAnimation

/* An array of objects providing the value of the animation function for
 * each keyframe. */

@synthesize values;

/* An optional path object defining the behavior of the animation
 * function. When non-nil overrides the `values' property. Each point
 * in the path except for `moveto' points defines a single keyframe for
 * the purpose of timing and interpolation. Defaults to nil. For
 * constant velocity animation along the path, `calculationMode' should
 * be set to `paced'. */

@synthesize path;

/* An optional array of `NSNumber' objects defining the pacing of the
 * animation. Each time corresponds to one value in the `values' array,
 * and defines when the value should be used in the animation function.
 * Each value in the array is a floating point number in the range
 * [0,1]. */

@synthesize keyTimes;

/* An optional array of VEMediaTimingFunction objects. If the `values' array
 * defines n keyframes, there should be n-1 objects in the
 * `timingFunctions' array. Each function describes the pacing of one
 * keyframe to keyframe segment. */

@synthesize timingFunctions;

/* The "calculation mode". Possible values are `discrete', `linear',
 * `paced', `cubic' and `cubicPaced'. Defaults to `linear'. When set to
 * `paced' or `cubicPaced' the `keyTimes' and `timingFunctions'
 * properties of the animation are ignored and calculated implicitly. */

@synthesize calculationMode;

/* For animations with the cubic calculation modes, these properties
 * provide control over the interpolation scheme. Each keyframe may
 * have a tension, continuity and bias value associated with it, each
 * in the range [-1, 1] (this defines a Kochanek-Bartels spline, see
 * http://en.wikipedia.org/wiki/Kochanek-Bartels_spline).
 *
 * The tension value controls the "tightness" of the curve (positive
 * values are tighter, negative values are rounder). The continuity
 * value controls how segments are joined (positive values give sharp
 * corners, negative values give inverted corners). The bias value
 * defines where the curve occurs (positive values move the curve before
 * the control point, negative values move it after the control point).
 *
 * The first value in each array defines the behavior of the tangent to
 * the first control point, the second value controls the second
 * point's tangents, and so on. Any unspecified values default to zero
 * (giving a Catmull-Rom spline if all are unspecified). */

@synthesize tensionValues, continuityValues, biasValues;

/* Defines whether or objects animating along paths rotate to match the
 * path tangent. Possible values are `auto' and `autoReverse'. Defaults
 * to nil. The effect of setting this property to a non-nil value when
 * no path object is supplied is undefined. `autoReverse' rotates to
 * match the tangent plus 180 degrees. */

@synthesize rotationMode;

@end

/* `calculationMode' strings. */

 NSString * const kVEAnimationLinear = @"kVEAnimationLinear";

 NSString * const kVEAnimationDiscrete = @"kVEAnimationDiscrete";

 NSString * const kVEAnimationPaced = @"kVEAnimationPaced";

 NSString * const kVEAnimationCubic = @"kVEAnimationCubic";

 NSString * const kVEAnimationCubicPaced = @"kVEAnimationCubicPaced";

/* `rotationMode' strings. */

 NSString * const kVEAnimationRotateAuto = @"kVEAnimationRotateAuto";

 NSString * const kVEAnimationRotateAutoReverse = @"kVEAnimationRotateAutoReverse";

/** Transition animation subclass. **/

@implementation VETransition 

/* The name of the transition. Current legal transition types include
 * `fade', `moveIn', `push' and `reveal'. Defaults to `fade'. */

@synthesize type;

/* An optional subtype for the transition. E.g. used to specify the
 * transition direction for motion-based transitions, in which case
 * the legal values are `fromLeft', `fromRight', `fromTop' and
 * `fromBottom'. */

@synthesize subtype;

/* The amount of progress through to the transition at which to begin
 * and end execution. Legal values are numbers in the range [0,1].
 * `endProgress' must be greater than or equal to `startProgress'.
 * Default values are 0 and 1 respectively. */

@synthesize startProgress, endProgress;

/* An optional filter object implementing the transition. When set the
 * `type' and `subtype' properties are ignored. The filter must
 * implement `inputImage', `inputTargetImage' and `inputTime' input
 * keys, and the `outputImage' output key. Optionally it may support
 * the `inputExtent' key, which will be set to a rectangle describing
 * the region in which the transition should run. Defaults to nil. */

@synthesize filter;

@end

/* Common transition types. */

 NSString * const kVETransitionFade = @"kVETransitionFade"
;
 NSString * const kVETransitionMoveIn = @"kVETransitionMoveIn"
;
 NSString * const kVETransitionPush = @"kVETransitionPush"
;
 NSString * const kVETransitionReveal = @"kVETransitionReveal"
;

/* Common transition subtypes. */

 NSString * const kVETransitionFromRight = @"kVETransitionFromRight"
;
 NSString * const kVETransitionFromLeft = @"kVETransitionFromLeft"
;
 NSString * const kVETransitionFromTop = @"kVETransitionFromTop"
;
 NSString * const kVETransitionFromBottom = @"kVETransitionFromBottom"
;


/** Animation subclass for grouped animations. **/

@implementation VEAnimationGroup

/* An array of VEAnimation objects. Each member of the array will run
 * concurrently in the time space of the parent animation using the
 * normal rules. */

@synthesize animations;

@end


@implementation __VEAnimationConfiguration

@synthesize duration;

@synthesize delay;

@synthesize options;

@synthesize start;

@synthesize animations;

@synthesize completion;

@end
