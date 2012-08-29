//
//  VEValueFunction.h
//  VUEngine
//
//  Created by LeixSnake on 8/29/12.
//
//

#import <Foundation/Foundation.h>

@interface VEValueFunction : NSObject<NSCoding>
{
@protected
    NSString *_string;
    void *_impl;
}

+ (id)functionWithName:(NSString *)name;

@property (atomic, readonly) NSString *name;

@end

/** Value function names. **/

/* The `rotateX', `rotateY', `rotateZ' functions take a single input
 * value in radians, and construct a 4x4 matrix representing the
 * corresponding rotation matrix. */

CF_EXPORT NSString * const kVEValueFunctionRotateX
;
CF_EXPORT NSString * const kVEValueFunctionRotateY
;
CF_EXPORT NSString * const kVEValueFunctionRotateZ
;

/* The `scale' function takes three input values and constructs a
 * 4x4 matrix representing the corresponding scale matrix. */

CF_EXPORT NSString * const kVEValueFunctionScale
;

/* The `scaleX', `scaleY', `scaleZ' functions take a single input value
 * and construct a 4x4 matrix representing the corresponding scaling
 * matrix. */

CF_EXPORT NSString * const kVEValueFunctionScaleX
;
CF_EXPORT NSString * const kVEValueFunctionScaleY
;
CF_EXPORT NSString * const kVEValueFunctionScaleZ
;

/* The `translate' function takes three input values and constructs a
 * 4x4 matrix representing the corresponding scale matrix. */

CF_EXPORT NSString * const kVEValueFunctionTranslate
;

/* The `translateX', `translateY', `translateZ' functions take a single
 * input value and construct a 4x4 matrix representing the corresponding
 * translation matrix. */

CF_EXPORT NSString * const kVEValueFunctionTranslateX
;
CF_EXPORT NSString * const kVEValueFunctionTranslateY
;
CF_EXPORT NSString * const kVEValueFunctionTranslateZ
;


