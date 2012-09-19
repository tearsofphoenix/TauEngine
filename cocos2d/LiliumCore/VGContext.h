//
//  VGContext.h
//  VUEngine
//
//  Created by tearsofphoenix on 8/30/12.
//
//

#import <GLKit/GLKit.h>

@class VALayer;

@class VGContext;

#ifdef __cplusplus
extern "C" {
#endif
    
    CF_EXPORT void VGContextRenderLayer(VGContext *context, VALayer *layer);
    
    CF_EXPORT VGContext *VGContextGetCurrentContext(void);
    
    CF_EXPORT void VGContextSaveState(VGContext *context);
    CF_EXPORT void VGContextRestoreState(VGContext *context);
    
    CF_EXPORT void VGContextMatrixMode(VGContext *context, GLenum mode);
    
    CF_EXPORT void VGContextLoadIdentity(VGContext *context);
    
    CF_EXPORT void VGContextLoadCTM(VGContext *context, GLKMatrix4 pIn);
    CF_EXPORT void VGContextConcatCTM(VGContext *context, GLKMatrix4 pIn);
    
    CF_EXPORT void VGContextTranslateCTM(VGContext *context, float x, float y, float z);
    CF_EXPORT void VGContextRotateCTM(VGContext *context, float angle, float x, float y, float z);
    CF_EXPORT void VGContextScaleCTM(VGContext *context, float x, float y, float z);
    
    CF_EXPORT GLKMatrix4 VGContextGetMVPMatrix(VGContext *context);

    CF_EXPORT GLKMatrix4 VGContextGetModelviewMatrix(VGContext *context);
    
    CF_EXPORT GLKMatrix4 VGContextGetProjectionMatrix(VGContext *context);
    
#ifdef __cplusplus
    }
#endif

