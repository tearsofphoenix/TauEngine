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
#import <dlfcn.h>

static void objc_dumpClass(const char *className)
{
    typedef void (^classDumper) (Class theClass);
    classDumper dumper = (^(Class theClass)
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
                                  
                                  unsigned int classProtocolCount = 0;
                                  Protocol **protocolList = class_copyProtocolList(theClass, &classProtocolCount);
                                  printf("\tProtocols:\n");
                                  for (int i=0; i < classProtocolCount; ++i)
                                  {
                                      printf("\t\tname: %s\n", protocol_getName(protocolList[i]));
                                  }
                                  
                                  free(protocolList);
                              }
                          });
    
    Class metaClass = objc_getMetaClass(className);
    printf("Meta Class Dump:\n");
    dumper(metaClass);
    
    Class theClass = objc_getClass(className);
    printf("Class Dump:\n");
    dumper(theClass);
}

#include <iostream>
#include <vector>
#include <algorithm>

void test(void)
{
	using namespace std;
    
	//Populate myvec with the data set 10, 5, -8, 5, 1, 4
	vector<int> myvec;
	myvec.push_back(10);
	myvec.push_back(5);
	myvec.push_back(-8);
	myvec.push_back(5);
	myvec.push_back(1);
	myvec.push_back(4);
    
	cout << "\n\n Initial data set:	  ";
	for(size_t i(0); i!=myvec.size(); ++i)
		cout << myvec.at(i) << ' ';
    
	//Remove the data elements matching '5'
	vector<int>::iterator invalid;
	invalid = remove( myvec.begin(), myvec.end(), 5 );
    
	cout << "\n\n Data set after remove: ";
	for(size_t i(0); i!=myvec.size(); ++i)
		cout << myvec.at(i) << ' ';
    
	//Destroy the remaining invalid elements
	myvec.erase( invalid, myvec.end() );
    
	cout << "\n\n Data set after erase:  ";
	for(size_t i(0); i!=myvec.size(); ++i)
		cout << myvec.at(i) << ' ';
}

int main(int argc, char *argv[])
{
    @autoreleasepool
    {
        //objc_dumpClass("CARenderer");
        //objc_dumpClass("UIView");
        //test();
//        void *func = dlsym(RTLD_DEFAULT, "_CASGetDisplayInfo");
//        printf("in func: %s %p", __FUNCTION__, func);
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([Box2DAppDelegate class]));
    }
}
