//
//  VEDataSource.h
//  cocos2d-ios
//
//  Created by tearsofphoenix on 8/24/12.
//
//

#import <Foundation/Foundation.h>

#import "VEMetaService.h"

@interface VEDataSource : VEMetaService

+ (void)registerServiceByClass: (Class)serviceClass;

+ (id)serviceByIdentity: (NSString *)identity;

+ (void)unloadServiceByIdentity: (NSString *)identity;

+ (void)unloadAllService;

@end

static inline void VSC(NSString *serviceID, NSString *action,
                       NSArray *arguments, VECallbackBlock callback)
{
    [[VEDataSource serviceByIdentity: serviceID] callForAction: action
                                                     arguments: arguments
                                                      callback: callback];
}
