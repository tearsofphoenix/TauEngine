//
//  VAValueFunction.m
//  VUEngine
//
//  Created by LeixSnake on 8/29/12.
//
//

#import <GLKit/GLKit.h>
#import "VAValueFunction.h"

typedef GLKMatrix4 (* _VEValueFunctionIMP)(GLfloat f1);

typedef GLKMatrix4 (* _VEValueFunctionIMP3)(GLfloat f1, GLfloat f2, GLfloat f3);

struct value_function_info_s
{
    void *ptr;
    NSUInteger inputCount;
    NSUInteger outputCount;
    NSString * name;
};

typedef struct value_function_info_s value_function_info_t;

static value_function_info_t __VEValueFunctions[] =
{
    {GLKMatrix4MakeXRotation, 1, 1, nil},
    {GLKMatrix4MakeYRotation, 1, 1, nil},
    {GLKMatrix4MakeZRotation, 1, 1, nil},

    {GLKMatrix4MakeScale, 3, 1, nil},
    {GLKMatrix4MakeScale, 3, 1, nil},
    {GLKMatrix4MakeScale, 3, 1, nil},
    {GLKMatrix4MakeScale, 3, 1, nil},

    {GLKMatrix4MakeTranslation, 3, 1, nil},
    {GLKMatrix4MakeTranslation, 3, 1, nil},
    {GLKMatrix4MakeTranslation, 3, 1, nil},
    {GLKMatrix4MakeTranslation, 3, 1, nil},

};


@interface VAValueFunction ()
{
@private
    int _argumentCount;
}
@end

@implementation VAValueFunction

static NSMutableDictionary *__VEValueFunctionPointers = nil;

+ (void)load
{
    __VEValueFunctionPointers = [[NSMutableDictionary alloc] init];
    
#define VAValueFunctionCreate(func, key) [__VEValueFunctionPointers setObject: [NSValue valueWithPointer: func] forKey: key]

    VAValueFunctionCreate(&__VEValueFunctions[0], kVEValueFunctionRotateX);
    VAValueFunctionCreate(&__VEValueFunctions[1], kVEValueFunctionRotateY);
    VAValueFunctionCreate(&__VEValueFunctions[2], kVEValueFunctionRotateZ);

    VAValueFunctionCreate(&__VEValueFunctions[3], kVEValueFunctionScale);
    VAValueFunctionCreate(&__VEValueFunctions[4], kVEValueFunctionScaleX);
    VAValueFunctionCreate(&__VEValueFunctions[5], kVEValueFunctionScaleY);
    VAValueFunctionCreate(&__VEValueFunctions[6], kVEValueFunctionScaleZ);

    VAValueFunctionCreate(&__VEValueFunctions[7], kVEValueFunctionTranslate);
    VAValueFunctionCreate(&__VEValueFunctions[8], kVEValueFunctionTranslateX);
    VAValueFunctionCreate(&__VEValueFunctions[9], kVEValueFunctionTranslateY);
    VAValueFunctionCreate(&__VEValueFunctions[10], kVEValueFunctionTranslateZ);

#undef VAValueFunctionCreate
}

+ (id)functionWithName: (NSString *)name
{
    VAValueFunction *newValueFunction = [[self alloc] init];
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

#pragma mark - Private Methods

- (void *)CA_copyRenderValue //encoding:^{Object=^^?{Atomic={?=i}}}8@0:4
{
    return NULL;
}

- (BOOL)apply: (const double *)value
       result: (double *)result
parameterFunction: (void *)function
      context: (void *)context
{
    return YES;
}

- (NSUInteger)outputCount
{
   return ((value_function_info_t *)_impl)->outputCount;
}

- (NSUInteger)inputCount
{
    return ((value_function_info_t *)_impl)->inputCount;
}

- (BOOL)apply: (const double *)value
       result: (double *)result
{
    switch ([self inputCount])
    {
        case 1:
        {
            _VEValueFunctionIMP imp = ((value_function_info_t *)_impl)->ptr;
            GLKMatrix4 matrix = imp(value[0]);
            memcpy(result, &matrix, sizeof(matrix));
            return YES;
        }
        case 3:
        {
            _VEValueFunctionIMP3 imp = ((value_function_info_t *)_impl)->ptr;
            GLKMatrix4 matrix = imp(value[0], value[1], value[2]);
            memcpy(result, &matrix, sizeof(matrix));
            return YES;
        }
        default:
        {
            break;
        }
    }
    
    return NO;
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
