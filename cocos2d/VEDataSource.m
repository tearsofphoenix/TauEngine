//
//  VEDataSource.m
//  cocos2d-ios
//
//  Created by tearsofphoenix on 8/24/12.
//
//

#import "VEDataSource.h"

NSString * const VEDataSourceServiceID = @"com.veritas.cocos2d.service.datasource";


static NSMutableDictionary *_registeredServices = nil;

@implementation VEDataSource

- (id)init
{
    if ((self = [super init]))
    {
        _registeredServices = [[NSMutableDictionary alloc] initWithCapacity: 10];
    }
    return self;
}

+ (void)registerServiceByClass: (Class)serviceClass
{
    NSLog(@"in func: %s service: %@\n", __func__, serviceClass);
    
    id<VEService> service = [[serviceClass alloc] init];
    [(NSMutableDictionary *)_registeredServices setObject: service
                                                   forKey: [serviceClass identity]];
    [service release];
}

+ (id)serviceByIdentity: (NSString *)identity
{
    return [_registeredServices objectForKey: identity];
}

+ (void)unloadServiceByIdentity: (NSString *)identity
{
    [_registeredServices removeObjectForKey: identity];
}

+ (void)unloadAllService
{
    [_registeredServices removeAllObjects];
}

+ (NSString *)identity
{
    return VEDataSourceServiceID;
}

@end
