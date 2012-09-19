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

static VGContext *__currentContext = nil;

@interface VGContext : NSObject

@end

@interface VGContext ()
{
@private
    GLKBaseEffect *_effect;
    
    GLKMatrixStackRef _modelViewMatrixStack;
    GLKMatrixStackRef _projectionMatrixStack;
    GLKMatrixStackRef _textureMatrixStack;
    
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
        
        _modelViewMatrixStack = GLKMatrixStackCreate(CFAllocatorGetDefault());
        
        _projectionMatrixStack = GLKMatrixStackCreate(CFAllocatorGetDefault());

        _textureMatrixStack = GLKMatrixStackCreate(CFAllocatorGetDefault());
        
		_currentStack = _modelViewMatrixStack;

        _renderQueue = [[NSMutableArray alloc] init];
        
        __currentContext = self;        
    }
    
    return self;
}

- (void)dealloc
{
    CFRelease(_modelViewMatrixStack);
    CFRelease(_projectionMatrixStack);
    CFRelease(_textureMatrixStack);
    _currentStack = NULL;
    
    [_renderQueue release];
    
    [super dealloc];
}

void VGContextRenderLayer(VGContext *context, VALayer *layer)
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

    [[effect transform] setModelviewMatrix: layer->_cachedFullModelviewMatrix];
    [[effect transform] setProjectionMatrix: [layer->_scene projectionMatrix]];

    bool layerUseTextureColor = VALayer_attribute_useTextureColor(layer);
    if (!layerUseTextureColor)
    {
        [effect setConstantColor: [layer->_backgroundColor CCColor]];
    }
    // Tell OpenGL that we're going to use this effect for our upcoming drawing
    [effect prepareToDraw];
    
    // Tell OpenGL that we'll be using vertex position data
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, layer->_vertices);
    
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
    glDrawArrays(GL_TRIANGLE_FAN, 0, layer->_verticeCount);
    
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
    
    for (VALayer *layerLooper in [layer sublayers])
    {
        VGContextRenderLayer(context, layerLooper);
    }
}

void VGContextSaveState(VGContext *context)
{
    GLKMatrixStackPush(context->_currentStack);
}

void VGContextRestoreState(VGContext *context)
{
    GLKMatrixStackPop(context->_currentStack);
}

void VGContextMatrixMode(VGContext *context, GLenum mode)
{
    switch(mode)
	{
		case GL_MODELVIEW_MATRIX:
        {
			context->_currentStack = context->_modelViewMatrixStack;
            break;
        }
		case GL_PROJECTION_MATRIX:
        {
			context->_currentStack = context->_projectionMatrixStack;
            break;
        }
		case GL_TEXTURE_MATRIX:
        {
			context->_currentStack = context->_textureMatrixStack;
            break;
        }
		default:
        {
			assert(0 && "Invalid matrix mode specified");
            break;
        }
	}
}

void VGContextLoadIdentity(VGContext *context)
{
    GLKMatrixStackLoadMatrix4(context->_currentStack, GLKMatrix4Identity);
}

void VGContextLoadCTM(VGContext *context, GLKMatrix4 pIn)
{
    GLKMatrixStackLoadMatrix4(context->_currentStack, pIn);
}

void VGContextConcatCTM(VGContext *context, GLKMatrix4 pIn)
{
    GLKMatrixStackMultiplyMatrix4(context->_currentStack, pIn);
}

void VGContextTranslateCTM(VGContext *context, float tx, float ty, float tz)
{
    GLKMatrixStackTranslate(context->_currentStack, tx, ty, tz);
}

void VGContextRotateCTM(VGContext *context, float angle, float x, float y, float z)
{
    GLKMatrixStackRotate(context->_currentStack, angle, x, y, z);
}

void VGContextScaleCTM(VGContext *context, float sx, float sy, float sz)
{
    GLKMatrixStackScale(context->_currentStack, sx, sy, sz);
}

GLKMatrix4 VGContextGetModelviewMatrix(VGContext *context)
{
    return GLKMatrixStackGetMatrix4(context->_modelViewMatrixStack);
}

GLKMatrix4 VGContextGetProjectionMatrix(VGContext *context)
{
    return GLKMatrixStackGetMatrix4(context->_projectionMatrixStack);
}


GLKMatrix4 VGContextGetMVPMatrix(VGContext *context)
{
    return GLKMatrix4Multiply(GLKMatrixStackGetMatrix4(context->_projectionMatrixStack),
                              GLKMatrixStackGetMatrix4(context->_modelViewMatrixStack));
}

VGContext *VGContextGetCurrentContext(void)
{
    if (!__currentContext)
    {
        __currentContext = [[VGContext alloc] init];
    }
    
    return __currentContext;
}

@end
