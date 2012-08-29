//
//  VEValueFunction.m
//  VUEngine
//
//  Created by LeixSnake on 8/29/12.
//
//

#import <GLKit/GLKit.h>
#import "VEValueFunction.h"

typedef GLKMatrix4 (* _VEValueFunctionIMP)(GLfloat f1);

typedef GLKMatrix4 (* _VEValueFunctionIMP3)(GLfloat f1, GLfloat f2, GLfloat f3);

@interface VEValueFunction ()
{
@private
    int _argumentCount;
}
@end

@implementation VEValueFunction

static NSMutableDictionary *__VEValueFunctionPointers = nil;

+ (void)load
{
    __VEValueFunctionPointers = [[NSMutableDictionary alloc] init];
    
#define VEValueFunctionCreate(func, key) [__VEValueFunctionPointers setObject: [NSValue valueWithPointer: func] forKey: key]

    VEValueFunctionCreate(GLKMatrix4MakeXRotation, kVEValueFunctionRotateX);
    VEValueFunctionCreate(GLKMatrix4MakeYRotation, kVEValueFunctionRotateY);
    VEValueFunctionCreate(GLKMatrix4MakeZRotation, kVEValueFunctionRotateZ);

    VEValueFunctionCreate(GLKMatrix4MakeScale, kVEValueFunctionScale);
    VEValueFunctionCreate(GLKMatrix4MakeScale, kVEValueFunctionScaleX);
    VEValueFunctionCreate(GLKMatrix4MakeScale, kVEValueFunctionScaleY);
    VEValueFunctionCreate(GLKMatrix4MakeScale, kVEValueFunctionScaleZ);

    VEValueFunctionCreate(GLKMatrix4MakeTranslation, kVEValueFunctionTranslate);
    VEValueFunctionCreate(GLKMatrix4MakeTranslation, kVEValueFunctionTranslateX);
    VEValueFunctionCreate(GLKMatrix4MakeTranslation, kVEValueFunctionTranslateY);
    VEValueFunctionCreate(GLKMatrix4MakeTranslation, kVEValueFunctionTranslateZ);

#undef VEValueFunctionCreate
}

+ (id)functionWithName: (NSString *)name
{
    VEValueFunction *newValueFunction = [[self alloc] init];
    newValueFunction->_string = [name copy];
    newValueFunction->_impl = [[__VEValueFunctionPointers objectForKey: name] pointerValue];
    
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
