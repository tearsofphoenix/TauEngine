//
//  VAMediaTimingFunction.h
//  VUEngine
//
//  Created by LeixSnake on 8/29/12.
//
//

#import <Foundation/Foundation.h>
#import "VAMediaTiming.h"

@interface VAMediaTimingFunction : NSObject <NSCoding>
{
@private
    struct VAMediaTimingFunctionPrivate *_priv;
}

/* A convenience method for creating common timing functions. The
 * currently supported names are `linear', `easeIn', `easeOut' and
 * `easeInEaseOut' and `default' (the curve used by implicit animations
 * created by Core Animation). */

+ (id)functionWithName:(NSString *)name;

/* Creates a timing function modelled on a cubic Bezier curve. The end
 * points of the curve are at (0,0) and (1,1), the two points 'c1' and
 * 'c2' defined by the class instance are the control points. Thus the
 * points defining the Bezier curve are: '[(0,0), c1, c2, (1,1)]' */

+ (id)functionWithControlPoints: (float)c1x
                               : (float)c1y
                               : (float)c2x
                               : (float)c2y;

- (id)initWithControlPoints: (float)c1x
                           : (float)c1y
                           : (float)c2x
                           : (float)c2y;

/* 'idx' is a value from 0 to 3 inclusive. */

- (void)getControlPointAtIndex: (size_t)idx
                        values: (float[2])ptr;

@end

/** Timing function names. **/

CF_EXPORT NSString * const kVEMediaTimingFunctionLinear;

CF_EXPORT NSString * const kVEMediaTimingFunctionEaseIn;

CF_EXPORT NSString * const kVEMediaTimingFunctionEaseOut;

CF_EXPORT NSString * const kVEMediaTimingFunctionEaseInEaseOut;

CF_EXPORT NSString * const kVEMediaTimingFunctionDefault;
