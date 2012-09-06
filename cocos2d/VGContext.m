//
//  VGContext.m
//  VUEngine
//
//  Created by tearsofphoenix on 8/30/12.
//
//

#import "VGContext.h"
#import "ccGLStateCache.h"
#import "VEGLProgram.h"

static VGContext *__currentContext = nil;

@interface VGContext ()
{
@private
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

void VGContextAddLayer(VGContext *context, VALayer *layer)
{
    [context->_renderQueue addObject: layer];
}

void VGContextRender(VGContext *context)
{

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

GLKMatrix4 VGContextGetMVPMatrix(VGContext *context)
{
    return GLKMatrix4Multiply(GLKMatrixStackGetMatrix4(context->_projectionMatrixStack),
                              GLKMatrixStackGetMatrix4(context->_modelViewMatrixStack));
}

VGContext *VGContextGetCurrentContext(void)
{
    return __currentContext;
}

@end
