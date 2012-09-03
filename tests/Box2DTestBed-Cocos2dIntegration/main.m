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

@interface UIViewAnimationBlockDelegate : NSObject

- (BOOL)_allowsUserInteraction;

- (void)_willBeginBlockAnimation: (id)anim
                         context: (void *)context;
- (void)_didEndBlockAnimation: (id)anim finished: (id)finished context: (void *)context;

- (void)_sendDeferredCompletion: (id)comp;

@end

static IMP _allowInterIMP = NULL;
static BOOL _aIMP(id obj, SEL selector)
{
    NSLog(@"in func: %s", __func__);
    return (BOOL)_allowInterIMP(obj, selector);
}

static IMP _willBeginIMP = NULL;
static void _wIMP(id obj, SEL selector, id anim, void *context)
{
    NSLog(@"in func: %s %@ %p", __func__, anim, context);
    _willBeginIMP(obj, selector, anim, context);
}

static IMP _didEndIMP = NULL;
static void _dIMP(id obj, SEL selector, id anim, id finished, void *context)
{
    NSLog(@"in func: %ss %@ %@ %p", __func__, anim, finished, context);
    _didEndIMP(obj, selector, anim, finished, context);
}

static IMP _sendCompIMP = NULL;
static void _sIMP(id obj, SEL selector, id comp)
{
    NSLog(@"in func: %s %@", __func__, comp);
    _sendCompIMP(obj, selector, comp);
}

int main(int argc, char *argv[])
{
    @autoreleasepool
    {
        Class blockDelegateClass = objc_getClass("UIViewAnimationBlockDelegate");
        _allowInterIMP = class_getMethodImplementation(blockDelegateClass, @selector(_allowsUserInteraction));
        class_replaceMethod(blockDelegateClass, @selector(_allowsUserInteraction), (IMP)_aIMP, "c8@0:4");
        
        _willBeginIMP = class_getMethodImplementation(blockDelegateClass, @selector(_willBeginBlockAnimation:context:));
        class_replaceMethod(blockDelegateClass, @selector(_willBeginBlockAnimation:context:), (IMP)_wIMP, "v16@0:4@8^v12");
        
        _didEndIMP = class_getMethodImplementation(blockDelegateClass, @selector(_didEndBlockAnimation:finished:context:));
        class_replaceMethod(blockDelegateClass, @selector(_didEndBlockAnimation:finished:context:), (IMP)_dIMP, "v20@0:4@8@12^v16");
        
        _sendCompIMP = class_getMethodImplementation(blockDelegateClass, @selector(_sendDeferredCompletion:));
        class_replaceMethod(blockDelegateClass, @selector(_sendDeferredCompletion:), (IMP)_sIMP, "v12@0:4@8");
        
        objc_dumpClass(objc_getClass("UIViewAnimationState"));
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([Box2DAppDelegate class]));
    }
}
