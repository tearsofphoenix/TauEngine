//
//  VEMetaService.h
//  cocos2d-ios
//
//  Created by tearsofphoenix on 8/24/12.
//
//

#import <Foundation/Foundation.h>

typedef void (^VECallbackBlock) (NSString *action, id arguments);
typedef void (^VEServiceBlock) (NSString *action, NSArray *arguments, VECallbackBlock callback);

@protocol VEService <NSObject>

@required

+ (NSString *)identity;

+ (void)load;

- (void)callForAction: (NSString *)action
            arguments: (NSArray *)arguments
             callback: (VECallbackBlock)callback;

@optional

- (void)initializeBlocks;

- (id)identity;

@end

@interface VEMetaService : NSObject<VEService>


- (void)registerBlock: (VEServiceBlock)serviceBlock
            forAction: (NSString *)action;


@end

