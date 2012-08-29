//
//  VEAnimation.h
//  VUEngine
//
//  Created by LeixSnake on 8/29/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "VEMediaTiming.h"

@class VEMediaTimingFunction;
@class VEValueFunction;

@interface VEAnimation : NSObject<NSCoding, NSCopying, VEMediaTiming>


/* Creates a new animation object. */

+ (id)animation;

/* Animations implement the same property model as defined by VELayer.
 * See VELayer.h for more details. */

+ (id)defaultValueForKey: (NSString *)key;
- (BOOL)shouldArchiveValueForKey: (NSString *)key;

/* A timing function defining the pacing of the animation. Defaults to
 * nil indicating linear pacing. */

@property (atomic, retain) VEMediaTimingFunction *timingFunction;

/* The delegate of the animation. This object is retained for the
 * lifetime of the animation object. Defaults to nil. See below for the
 * supported delegate methods. */

@property (atomic, retain) id delegate;

/* When true, the animation is removed from the render tree once its
 * active duration has passed. Defaults to YES. */

@property(atomic, getter=isRemovedOnCompletion) BOOL removedOnCompletion;

@end

/* Delegate methods for VEAnimation. */

@interface NSObject (VEAnimationDelegate)

/* Called when the animation begins its active duration. */

- (void)animationDidStart:(VEAnimation *)anim;

/* Called when the animation either completes its active duration or
 * is removed from the object it is attached to (i.e. the layer). 'flag'
 * is true if the animation reached the end of its active duration
 * without being removed. */

- (void)animationDidStop:(VEAnimation *)anim finished:(BOOL)flag;

@end

/** Subclass for property-based animations. **/

@interface VEPropertyAnimation : VEAnimation

/* Creates a new animation object with its `keyPath' property set to
 * 'path'. */

+ (id)animationWithKeyPath:(NSString *)path;

/* The key-path describing the property to be animated. */

@property(copy) NSString *keyPath;

/* When true the value specified by the animation will be "added" to
 * the current presentation value of the property to produce the new
 * presentation value. The addition function is type-dependent, e.g.
 * for affine transforms the two matrices are concatenated. Defaults to
 * NO. */

@property(getter=isAdditive) BOOL additive;

/* The `cumulative' property affects how repeating animations produce
 * their result. If true then the current value of the animation is the
 * value at the end of the previous repeat cycle, plus the value of the
 * current repeat cycle. If false, the value is simply the value
 * calculated for the current repeat cycle. Defaults to NO. */

@property(getter=isCumulative) BOOL cumulative;

/* If non-nil a function that is applied to interpolated values
 * before they are set as the new presentation value of the animation's
 * target property. Defaults to nil. */

@property(retain) VEValueFunction *valueFunction;

@end


/** Subclass for basic (single-keyframe) animations. **/

@interface VEBasicAnimation : VEPropertyAnimation

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

@property(retain) id fromValue, toValue, byValue;

@end


/** General keyframe animation class. **/

@interface VEKeyframeAnimation : VEPropertyAnimation

/* An array of objects providing the value of the animation function for
 * each keyframe. */

@property(copy) NSArray *values;

/* An optional path object defining the behavior of the animation
 * function. When non-nil overrides the `values' property. Each point
 * in the path except for `moveto' points defines a single keyframe for
 * the purpose of timing and interpolation. Defaults to nil. For
 * constant velocity animation along the path, `calculationMode' should
 * be set to `paced'. */

@property CGPathRef path;

/* An optional array of `NSNumber' objects defining the pacing of the
 * animation. Each time corresponds to one value in the `values' array,
 * and defines when the value should be used in the animation function.
 * Each value in the array is a floating point number in the range
 * [0,1]. */

@property(copy) NSArray *keyTimes;

/* An optional array of VEMediaTimingFunction objects. If the `values' array
 * defines n keyframes, there should be n-1 objects in the
 * `timingFunctions' array. Each function describes the pacing of one
 * keyframe to keyframe segment. */

@property(copy) NSArray *timingFunctions;

/* The "calculation mode". Possible values are `discrete', `linear',
 * `paced', `cubic' and `cubicPaced'. Defaults to `linear'. When set to
 * `paced' or `cubicPaced' the `keyTimes' and `timingFunctions'
 * properties of the animation are ignored and calculated implicitly. */

@property(copy) NSString *calculationMode;

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

@property(copy) NSArray *tensionValues, *continuityValues, *biasValues;

/* Defines whether or objects animating along paths rotate to match the
 * path tangent. Possible values are `auto' and `autoReverse'. Defaults
 * to nil. The effect of setting this property to a non-nil value when
 * no path object is supplied is undefined. `autoReverse' rotates to
 * match the tangent plus 180 degrees. */

@property(copy) NSString *rotationMode;

@end

/* `calculationMode' strings. */

CF_EXPORT NSString * const kCAAnimationLinear;

CF_EXPORT NSString * const kCAAnimationDiscrete;

CF_EXPORT NSString * const kCAAnimationPaced;

CF_EXPORT NSString * const kCAAnimationCubic;

CF_EXPORT NSString * const kCAAnimationCubicPaced;

/* `rotationMode' strings. */

CF_EXPORT NSString * const kCAAnimationRotateAuto;

CF_EXPORT NSString * const kCAAnimationRotateAutoReverse;

/** Transition animation subclass. **/

@interface VETransition : VEAnimation

/* The name of the transition. Current legal transition types include
 * `fade', `moveIn', `push' and `reveal'. Defaults to `fade'. */

@property(copy) NSString *type;

/* An optional subtype for the transition. E.g. used to specify the
 * transition direction for motion-based transitions, in which case
 * the legal values are `fromLeft', `fromRight', `fromTop' and
 * `fromBottom'. */

@property(copy) NSString *subtype;

/* The amount of progress through to the transition at which to begin
 * and end execution. Legal values are numbers in the range [0,1].
 * `endProgress' must be greater than or equal to `startProgress'.
 * Default values are 0 and 1 respectively. */

@property float startProgress, endProgress;

/* An optional filter object implementing the transition. When set the
 * `type' and `subtype' properties are ignored. The filter must
 * implement `inputImage', `inputTargetImage' and `inputTime' input
 * keys, and the `outputImage' output key. Optionally it may support
 * the `inputExtent' key, which will be set to a rectangle describing
 * the region in which the transition should run. Defaults to nil. */

@property(retain) id filter;

@end

/* Common transition types. */

CF_EXPORT NSString * const kCATransitionFade
;
CF_EXPORT NSString * const kCATransitionMoveIn
;
CF_EXPORT NSString * const kCATransitionPush
;
CF_EXPORT NSString * const kCATransitionReveal
;

/* Common transition subtypes. */

CF_EXPORT NSString * const kCATransitionFromRight
;
CF_EXPORT NSString * const kCATransitionFromLeft
;
CF_EXPORT NSString * const kCATransitionFromTop
;
CF_EXPORT NSString * const kCATransitionFromBottom
;


/** Animation subclass for grouped animations. **/

@interface VEAnimationGroup : VEAnimation

/* An array of VEAnimation objects. Each member of the array will run
 * concurrently in the time space of the parent animation using the
 * normal rules. */

@property(copy) NSArray *animations;

@end
