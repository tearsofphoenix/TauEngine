//
//  VEValueFunction.m
//  VUEngine
//
//  Created by LeixSnake on 8/29/12.
//
//

#import <GLKit/GLKit.h>
#import "VEValueFunction.h"

typedef GLKMatrix4 (* _VEValueFunctionIMP)(GLfloat *data);

@implementation VEValueFunction

static NSMutableDictionary *__VEValueFunctionPointers = nil;

+ (void)load
{
    __VEValueFunctionPointers = [[NSMutableDictionary alloc] init];
    
    [__VEValueFunctionPointers setObject: kVEValueFunctionRotateX
                                  forKey: [NSValue valueWithPointer: GLKMatrix4MakeXRotation]];

    [__VEValueFunctionPointers setObject: kVEValueFunctionRotateY
                                  forKey: [NSValue valueWithPointer: GLKMatrix4MakeYRotation]];

    [__VEValueFunctionPointers setObject: kVEValueFunctionRotateZ
                                  forKey: [NSValue valueWithPointer: GLKMatrix4MakeZRotation]];

    
}

+ (id)functionWithName: (NSString *)name
{
    VEValueFunction *newValueFunction = [[self alloc] init];
    newValueFunction->_string = [name copy];
    return [newValueFunction autorelease];
}

@synthesize name = _string;

#pragma mark - NSCoding

- (id)initWithCoder: (NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        _string = [[aDecoder decodeObjectForKey: @"name"] copy];
    }
    
    return self;
}

- (void)encodeWithCoder: (NSCoder *)aCoder
{
    [aCoder encodeObject: _string
                  forKey: @"name"];
}

@end

/** Value function names. **/

/* The `rotateX', `rotateY', `rotateZ' functions take a single input
 * value in radians, and construct a 4x4 matrix representing the
 * corresponding rotation matrix. */

 NSString * const kVEValueFunctionRotateX = @"kVEValueFunctionRotateX"
;
 NSString * const kVEValueFunctionRotateY = @"kVEValueFunctionRotateY"
;
 NSString * const kVEValueFunctionRotateZ = @"kVEValueFunctionRotateZ"
;

/* The `scale' function takes three input values and constructs a
 * 4x4 matrix representing the corresponding scale matrix. */

 NSString * const kVEValueFunctionScale = @"kVEValueFunctionScale"
;

/* The `scaleX', `scaleY', `scaleZ' functions take a single input value
 * and construct a 4x4 matrix representing the corresponding scaling
 * matrix. */

 NSString * const kVEValueFunctionScaleX = @"kVEValueFunctionScaleX"
;
 NSString * const kVEValueFunctionScaleY = @"kVEValueFunctionScaleY"
;
 NSString * const kVEValueFunctionScaleZ = @"kVEValueFunctionScaleZ"
;

/* The `translate' function takes three input values and constructs a
 * 4x4 matrix representing the corresponding scale matrix. */

 NSString * const kVEValueFunctionTranslate = @"kVEValueFunctionTranslate"
;

/* The `translateX', `translateY', `translateZ' functions take a single
 * input value and construct a 4x4 matrix representing the corresponding
 * translation matrix. */

 NSString * const kVEValueFunctionTranslateX = @"kVEValueFunctionTranslateX"
;
 NSString * const kVEValueFunctionTranslateY = @"kVEValueFunctionTranslateY"
;
 NSString * const kVEValueFunctionTranslateZ = @"kVEValueFunctionTranslateZ"
;
