//
//  VEContext.h
//  VUEngine
//
//  Created by tearsofphoenix on 8/30/12.
//
//

#import <Foundation/Foundation.h>

@class CCLayer;

@interface VEContext : NSObject

@end

#ifdef __cplusplus
extern "C" {
#endif

    CF_EXPORT void VEContextAddLayer(VEContext *context, CCLayer *layer);
    
    CF_EXPORT void VEContextRender(VEContext *context);
    
#ifdef __cplusplus
    }
#endif

