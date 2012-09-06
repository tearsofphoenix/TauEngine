//
//  VAMediaTimingFunction.m
//  VUEngine
//
//  Created by LeixSnake on 8/29/12.
//
//

#import "VAMediaTimingFunction.h"

@interface VAMediaTimingFunction ()
{
@private
    float _controlPoints[8];
}
@end

@implementation VAMediaTimingFunction

static NSMutableDictionary *__VEMediaTimingFunctions = nil;

static float __VELinearControlPoints[4] = {0, 0, 1, 1};

//static float __VEEaseControlPoints[4] = {0.25, 0.1, 0.25, 1};

static float __VEEaseInControlPoints[4] = {0.42, 0, 1, 1};

static float __VEEaseOutControlPoints[4] = {0, 0, 0.58, 1};

static float __VEEaseInOutControlPoints[4] = {0.42, 0, 0.58, 1};


+ (void)load
{
    __VEMediaTimingFunctions = [[NSMutableDictionary alloc] initWithCapacity: 5];
    
#define _VEMediaTimineFunctionStore(address, name) [__VEMediaTimingFunctions setObject: [NSValue valueWithPointer: address] forKey: name]
    
    _VEMediaTimineFunctionStore(__VELinearControlPoints, kVEMediaTimingFunctionLinear);
    _VEMediaTimineFunctionStore(__VEEaseInControlPoints, kVEMediaTimingFunctionEaseIn);
    _VEMediaTimineFunctionStore(__VEEaseOutControlPoints, kVEMediaTimingFunctionEaseOut);
    _VEMediaTimineFunctionStore(__VEEaseInOutControlPoints, kVEMediaTimingFunctionEaseInEaseOut);
    _VEMediaTimineFunctionStore(__VELinearControlPoints, kVEMediaTimingFunctionDefault);
    
#undef _VEMediaTimineFunctionStore
    
}
/* A convenience method for creating common timing functions. The
 * currently supported names are `linear', `easeIn', `easeOut' and
 * `easeInEaseOut' and `default' (the curve used by implicit animations
 * created by Core Animation). */

+ (id)functionWithName: (NSString *)name
{
    float *address = [[__VEMediaTimingFunctions objectForKey: name] pointerValue];
    VAMediaTimingFunction *newFunction = nil;
    if (address)
    {
        newFunction = [[self alloc] initWithControlPoints: address[0]
                                                         : address[1]
                                                         : address[2]
                                                         : address[3]];
    }
    
    return [newFunction autorelease];
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
        NSUInteger length = 0;
        float *address = [aDecoder decodeBytesWithReturnedLength: &length];
        memcpy(_controlPoints, address, length);
    }
    return self;
}

- (void)encodeWithCoder: (NSCoder *)aCoder
{
    [aCoder encodeBytes: _controlPoints
                 length: sizeof(float) * 8];
}



@end

NSString * const kVEMediaTimingFunctionLinear = @"kVEMediaTimingFunctionLinear";

NSString * const kVEMediaTimingFunctionEaseIn = @"kVEMediaTimingFunctionEaseIn";

NSString * const kVEMediaTimingFunctionEaseOut = @"kVEMediaTimingFunctionEaseOut";

NSString * const kVEMediaTimingFunctionEaseInEaseOut = @"kVEMediaTimingFunctionEaseInEaseOut";

NSString * const kVEMediaTimingFunctionDefault = @"kVEMediaTimingFunctionDefault";

