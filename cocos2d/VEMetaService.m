//
//  VEMetaService.m
//  cocos2d-ios
//
//  Created by tearsofphoenix on 8/24/12.
//
//

#import "VEMetaService.h"

#import "VEDataSource.h"

@interface VEMetaService ()
{
    NSMutableDictionary *_serviceBlocks;
    dispatch_queue_t _dispatchQueue;
}
@end

@implementation VEMetaService

- (void)initializeBlocks
{
    
}

- (id)init
{
    if ((self = [super init]))
    {
        _serviceBlocks = [[NSMutableDictionary alloc] initWithCapacity: 10];
        _dispatchQueue = dispatch_queue_create([[[self class] identity] UTF8String], DISPATCH_QUEUE_CONCURRENT);
        
        [self initializeBlocks];
    }
    return self;
}

- (void)dealloc
{
    [_serviceBlocks release];
    dispatch_release(_dispatchQueue);
    
    [super dealloc];
}

- (void)callForAction: (NSString *)action
            arguments: (NSArray *)arguments
             callback: (VECallbackBlock)callback
{
    __block VEServiceBlock serviceBlock = [_serviceBlocks objectForKey: action];
    if (serviceBlock)
    {
        dispatch_async(_dispatchQueue, (^
                                        {
                                            serviceBlock(action, arguments, callback);
                                        }));
    }
}

- (void)registerBlock: (VEServiceBlock)serviceBlock
            forAction: (NSString *)action
{
    if (serviceBlock && action)
    {
        serviceBlock = Block_copy(serviceBlock);
        
        [_serviceBlocks setObject: serviceBlock
                           forKey: action];
        
        Block_release(serviceBlock);
    }
}


+ (NSString *)identity
{
    return nil;
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, (^
                               {
                                   [VEDataSource registerServiceByClass: [VEDataSource class]];
                               }));
}

@end
