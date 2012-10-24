//
//  VGContext.m
//  VUEngine
//
//  Created by tearsofphoenix on 8/30/12.
//
//

#import "VGContext.h"
#import "VALayer+Private.h"
#import "VGColor.h"

#define VGContextMatrix(context, name) ((context)->_matrixStacks[(name) - GL_MODELVIEW_MATRIX])

static VGContextRef __currentContext = nil;

@interface VGContext : NSObject

@end

@interface VGContext ()
{
@private
    GLKBaseEffect *_effect;
    
    GLKMatrixStackRef _matrixStacks[3];
    
    GLKMatrixStackRef _currentStack;
    NSMutableArray *_renderQueue;
}
@end

@implementation VGContext

- (id)init
{
    if ((self = [super init]))
    {
        _effect = [[GLKBaseEffect alloc] init];
        VGContextMatrix(self, GL_MODELVIEW_MATRIX) = _currentStack =  GLKMatrixStackCreate(CFAllocatorGetDefault());
        VGContextMatrix(self, GL_PROJECTION_MATRIX) = GLKMatrixStackCreate(CFAllocatorGetDefault());
        VGContextMatrix(self, GL_TEXTURE_MATRIX) = GLKMatrixStackCreate(CFAllocatorGetDefault());
        
        _renderQueue = [[NSMutableArray alloc] init];
        
        __currentContext = self;        
    }
    
    return self;
}

- (void)dealloc
{
    CFRelease(VGContextMatrix(self, GL_MODELVIEW_MATRIX));
    CFRelease(VGContextMatrix(self, GL_PROJECTION_MATRIX));
    CFRelease(VGContextMatrix(self, GL_TEXTURE_MATRIX));
    
    _currentStack = NULL;
    
    [_renderQueue release];
    
    [super dealloc];
}

void VGContextRenderLayer(VGContextRef context, VALayer *layer)
{
    GLKBaseEffect *effect = context->_effect;

    [layer _commitLayerInContextt: context];

    GLKTextureInfo *textureInfo = layer->_textureInfo;

    if (textureInfo)
    {
        GLKEffectPropertyTexture *texture2d0 = [effect texture2d0];
        [texture2d0 setEnvMode: GLKTextureEnvModeReplace];
        [texture2d0 setName: [textureInfo name]];
    }

    bool layerUseTextureColor = VALayer_attribute_useTextureColor(layer);
    if (!layerUseTextureColor)
    {
        [effect setConstantColor: [layer->_backgroundColor CCColor]];
    }

    VGContextDrawVertices(context, layer->_vertices, layer->_verticeCount, GL_TRIANGLE_FAN);
    
    // If we're using vertex coloring, tell OpenGL that we'll be using vertex color data
    if (layerUseTextureColor)
    {
        glEnableVertexAttribArray(GLKVertexAttribColor);
        glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, layer->_vertexColors);
    }
    
    // If we have a texture, tell OpenGL that we'll be using texture coordinate data
    
    if (textureInfo)
    {
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, layer->_textureCoordinates);
    }
    
    // Draw our primitives!
//    glDrawArrays(GL_TRIANGLE_FAN, 0, layer->_verticeCount);
    
    // Cleanup: Done with position data
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    
    // Cleanup: Done with color data (only if we used it)
    if (layerUseTextureColor)
    {
        glDisableVertexAttribArray(GLKVertexAttribColor);
    }
    
    // Cleanup: Done with texture data (only if we used it)
    if (textureInfo)
    {
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    }
    
    // Cleanup: Done with the current blend function
    glDisable(GL_BLEND);
    
    [layer render];
    
    for (VALayer *layerLooper in [layer sublayers])
    {
        VGContextRenderLayer(context, layerLooper);
    }
}

void VGContextSaveState(VGContextRef context)
{
    GLKMatrixStackPush( VGContextMatrix(context, GL_MODELVIEW_MATRIX) );
    GLKMatrixStackPush( VGContextMatrix(context, GL_PROJECTION_MATRIX) );
}

void VGContextRestoreState(VGContextRef context)
{
    GLKMatrixStackPop(VGContextMatrix(context, GL_MODELVIEW_MATRIX) );
    GLKMatrixStackPop(VGContextMatrix(context, GL_PROJECTION_MATRIX) );
}

void VGContextMatrixMode(VGContextRef context, GLenum mode)
{
    context->_currentStack = VGContextMatrix(context, mode);
}

void VGContextLoadIdentity(VGContextRef context)
{
    GLKMatrixStackLoadMatrix4(context->_currentStack, GLKMatrix4Identity);
}

void VGContextLoadCTM(VGContextRef context, GLKMatrix4 pIn)
{
    GLKMatrixStackLoadMatrix4(context->_currentStack, pIn);
}

void VGContextConcatCTM(VGContextRef context, GLKMatrix4 pIn)
{
    GLKMatrixStackMultiplyMatrix4(context->_currentStack, pIn);
}

void VGContextTranslateCTM(VGContextRef context, float tx, float ty, float tz)
{
    GLKMatrixStackTranslate(context->_currentStack, tx, ty, tz);
}

void VGContextRotateCTM(VGContextRef context, float angle, float x, float y, float z)
{
    GLKMatrixStackRotate(context->_currentStack, angle, x, y, z);
}

void VGContextScaleCTM(VGContextRef context, float sx, float sy, float sz)
{
    GLKMatrixStackScale(context->_currentStack, sx, sy, sz);
}

void VGContextSetFillColor(VGContextRef context, GLKVector4 color)
{
    [context->_effect setConstantColor: color];
}

GLKMatrix4 VGContextGetModelviewMatrix(VGContextRef context)
{
    return GLKMatrixStackGetMatrix4( VGContextMatrix(context, GL_MODELVIEW_MATRIX) );
}

GLKMatrix4 VGContextGetProjectionMatrix(VGContextRef context)
{
    return GLKMatrixStackGetMatrix4( VGContextMatrix(context, GL_PROJECTION_MATRIX) );
}


GLKMatrix4 VGContextGetMVPMatrix(VGContextRef context)
{
    return GLKMatrix4Multiply(GLKMatrixStackGetMatrix4( VGContextMatrix(context, GL_PROJECTION_MATRIX) ),
                              GLKMatrixStackGetMatrix4( VGContextMatrix(context, GL_MODELVIEW_MATRIX) ));
}

VGContextRef VGContextGetCurrentContext(void)
{
    if (!__currentContext)
    {
        __currentContext = [[VGContext alloc] init];
    }
    
    return __currentContext;
}

void VGContextDrawVertices(VGContextRef context, GLvoid *vertices, GLsizei vertexCount, GLenum mode)
{
    GLKBaseEffect *effect = context->_effect;
    [[effect transform] setModelviewMatrix: GLKMatrixStackGetMatrix4( VGContextMatrix(context, GL_MODELVIEW_MATRIX) )];
    [[effect transform] setProjectionMatrix: GLKMatrixStackGetMatrix4( VGContextMatrix(context, GL_PROJECTION_MATRIX) )];
    
    [effect prepareToDraw];
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);

    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glDrawArrays(mode, 0, vertexCount);

    glDisableVertexAttribArray(GLKVertexAttribPosition);
}

@end
