//
//  main.m
//  Box2D
//
//  Created by Simon Oliver on 14/01/2009.
//  Copyright HandCircus 2009. All rights reserved.
//

//
// File modified for cocos2d integration
// http://www.cocos2d-iphone.org
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Box2DAppDelegate.h"

#import <objc/runtime.h>

static void objc_dumpClass(Class theClass)
{
    if (theClass)
    {
        printf("class:%s\n", class_getName(theClass));
        
        unsigned int classIvarCount = 0;
        Ivar *classIvarList = class_copyIvarList(theClass, &classIvarCount);
        printf("\tIvars:\n");
        for (int i=0; i<classIvarCount; ++i)
        {
            printf("\t\tname:%s encoding:%s\n", ivar_getName(classIvarList[i]), ivar_getTypeEncoding(classIvarList[i]));
        }
        
        free(classIvarList);
        
        unsigned int classMethodCount = 0;
        Method *methodList = class_copyMethodList(theClass, &classMethodCount);
        printf("\tMethods:\n");
        for (int i=0; i<classMethodCount; ++i)
        {
            printf("\t\tname:%s encoding:%s\n", (const char*)method_getName(methodList[i]), method_getTypeEncoding(methodList[i]));
        }
        
        free(methodList);
        
        unsigned int classPropertyCount = 0;
        objc_property_t *properties = class_copyPropertyList(theClass, &classPropertyCount);
        printf("\tProperties:\n");
        for (int i=0; i<classPropertyCount; ++i)
        {
            printf("\t\tname:%s attributes:%s\n", property_getName(properties[i]), property_getAttributes(properties[i]));
        }
        
        free(properties);
    }
}

typedef void (* AnimationIMPType)(id, SEL, NSTimeInterval, NSTimeInterval, UIView *, UIViewAnimationOptions, dispatch_block_t, dispatch_block_t, void(^completion)(BOOL finished));

AnimationIMPType _imp = NULL;

static void _setupAnimationWithDuration_delay_view_options_animations_start_completion_(Class theClass, SEL selector, NSTimeInterval duration,
                                                                                        NSTimeInterval delay, UIView *view, UIViewAnimationOptions options,
                                                                                        dispatch_block_t animations, dispatch_block_t start, void(^completion)(BOOL finished))
{
    _imp(theClass, selector, duration, delay, view, options, animations, start, completion);
}

int main(int argc, char *argv[])
{
    @autoreleasepool
    {
        Class theClass = objc_getMetaClass("UIView");
        SEL selector = @selector(_setupAnimationWithDuration:delay:view:options:animations:start:completion:);
        _imp = (AnimationIMPType)class_getMethodImplementation(theClass, selector);
        class_replaceMethod(theClass, selector, (IMP)_setupAnimationWithDuration_delay_view_options_animations_start_completion_, "v44@0:4d8d16@24I28@?32@?36@?40");
        
        //objc_dumpClass(objc_getMetaClass("UIView"));
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([Box2DAppDelegate class]));
    }
}
