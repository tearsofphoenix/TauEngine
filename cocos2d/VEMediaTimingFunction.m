//
//  VEMediaTimingFunction.m
//  VUEngine
//
//  Created by LeixSnake on 8/29/12.
//
//

#import "VEMediaTimingFunction.h"

@interface VEMediaTimingFunction ()
{
@private
    float _controlPoints[8];
}
@end

@implementation VEMediaTimingFunction

/* A convenience method for creating common timing functions. The
 * currently supported names are `linear', `easeIn', `easeOut' and
 * `easeInEaseOut' and `default' (the curve used by implicit animations
 * created by Core Animation). */

+ (id)functionWithName:(NSString *)name
{
    return nil;
}

/* Creates a timing function modelled on a cubic Bezier curve. The end
 * points of the curve are at (0,0) and (1,1), the two points 'c1' and
 * 'c2' defined by the class instance are the control points. Thus the
 * points defining the Bezier curve are: '[(0,0), c1, c2, (1,1)]' */

+ (id)functionWithControlPoints: (float)c1x
                               : (float)c1y
                               : (float)c2x
                               : (float)c2y
{
    return [[[self alloc] initWithControlPoints: c1x
                                               : c1y
                                               : c2x
                                               : c2y] autorelease];
}

- (id)initWithControlPoints: (float)c1x
                           : (float)c1y
                           : (float)c2x
                           : (float)c2y
{
    if ((self = [super init]))
    {
        _controlPoints[0] = 0;
        _controlPoints[1] = 0;
        
        _controlPoints[2] = c1x;
        _controlPoints[3] = c1y;
        
        _controlPoints[4] = c2x;
        _controlPoints[5] = c2y;
        
        _controlPoints[6] = 1;
        _controlPoints[7] = 1;
    }
    return self;
}


/* 'idx' is a value from 0 to 3 inclusive. */

- (void)getControlPointAtIndex: (size_t)idx
                        values: (float[2])ptr
{
    switch (idx)
    {
        case 0:
        case 1:
        case 2:
        case 3:
        {
            if (ptr)
            {
                ptr[0] = _controlPoints[2 * idx];
                ptr[1] = _controlPoints[2 * idx + 1];                
            }
            break;
        }
        default:
        {
            NSLog(@"in func: %s invalid idx: %zd", __func__, idx);
            break;
        }
    }
}

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



@end

 NSString * const kVEMediaTimingFunctionLinear = @"kVEMediaTimingFunctionLinear";

 NSString * const kVEMediaTimingFunctionEaseIn = @"kVEMediaTimingFunctionEaseIn";

 NSString * const kVEMediaTimingFunctionEaseOut = @"kVEMediaTimingFunctionEaseOut";

 NSString * const kVEMediaTimingFunctionEaseInEaseOut = @"kVEMediaTimingFunctionEaseInEaseOut";

 NSString * const kVEMediaTimingFunctionDefault = @"kVEMediaTimingFunctionDefault";

