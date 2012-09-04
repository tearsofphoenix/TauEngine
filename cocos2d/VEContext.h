//
//  VEContext.h
//  VUEngine
//
//  Created by tearsofphoenix on 8/30/12.
//
//

#import <GLKit/GLKit.h>

@class CCLayer;

@interface VEContext : NSObject

@end

#ifdef __cplusplus
extern "C" {
#endif

    
    CF_EXPORT void VEContextAddLayer(VEContext *context, CCLayer *layer);
    
    CF_EXPORT void VEContextRender(VEContext *context);
    
    CF_EXPORT VEContext *VEContextGetCurrentContext(void);
    
    CF_EXPORT void VEContextSaveState(VEContext *context);
    CF_EXPORT void VEContextRestoreState(VEContext *context);
    
    CF_EXPORT void VEContextMatrixMode(VEContext *context, GLenum mode);
    
    CF_EXPORT void VEContextLoadIdentity(VEContext *context);
    
    CF_EXPORT void VEContextLoadCTM(VEContext *context, GLKMatrix4 pIn);
    CF_EXPORT void VEContextConcatCTM(VEContext *context, GLKMatrix4 pIn);
    
    CF_EXPORT void VEContextTranslateCTM(VEContext *context, float x, float y, float z);
    CF_EXPORT void VEContextRotateCTM(VEContext *context, float angle, float x, float y, float z);
    CF_EXPORT void VEContextScaleCTM(VEContext *context, float x, float y, float z);
    
    CF_EXPORT GLKMatrix4 VEContextGetMVPMatrix(VEContext *context);

#ifdef __cplusplus
    }
#endif

