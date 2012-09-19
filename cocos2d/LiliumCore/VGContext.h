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

    typedef VGContext  *VGContextRef;

    CF_EXPORT void VGContextRenderLayer(VGContextRef context, VALayer *layer);
    
    CF_EXPORT VGContextRef VGContextGetCurrentContext(void);
    
    CF_EXPORT void VGContextSaveState(VGContextRef context);
    CF_EXPORT void VGContextRestoreState(VGContextRef context);
    
    CF_EXPORT void VGContextMatrixMode(VGContextRef context, GLenum mode);
    
    CF_EXPORT void VGContextLoadIdentity(VGContextRef context);
    
    CF_EXPORT void VGContextSetFillColor(VGContextRef context, GLKVector4 color);
    
    CF_EXPORT void VGContextLoadCTM(VGContextRef context, GLKMatrix4 pIn);
    CF_EXPORT void VGContextConcatCTM(VGContextRef context, GLKMatrix4 pIn);
    
    CF_EXPORT void VGContextTranslateCTM(VGContextRef context, float x, float y, float z);
    CF_EXPORT void VGContextRotateCTM(VGContextRef context, float angle, float x, float y, float z);
    CF_EXPORT void VGContextScaleCTM(VGContextRef context, float x, float y, float z);
    
    CF_EXPORT GLKMatrix4 VGContextGetMVPMatrix(VGContextRef context);

    CF_EXPORT GLKMatrix4 VGContextGetModelviewMatrix(VGContextRef context);
    
    CF_EXPORT GLKMatrix4 VGContextGetProjectionMatrix(VGContextRef context);
    
    //extra
    CF_EXPORT void VGContextDrawVertices(VGContextRef context, GLvoid *vertices, GLsizei vertexCount, GLenum mode);
    
#ifdef __cplusplus
    }
#endif

