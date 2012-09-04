//
//  VEContext.m
//  VUEngine
//
//  Created by tearsofphoenix on 8/30/12.
//
//

#import "VEContext.h"
#import "ccGLStateCache.h"
#import "CCGLProgram.h"

static VEContext *__currentContext = nil;

@interface VEContext ()
{
@private
    GLKMatrixStackRef _modelViewMatrixStack;
    GLKMatrixStackRef _projectionMatrixStack;
    GLKMatrixStackRef _textureMatrixStack;
    
    GLKMatrixStackRef _currentStack;
    dispatch_queue_t _dispatchQueue;
    NSMutableArray *_renderQueue;
}
@end

@implementation VEContext

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
        
        _dispatchQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
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

void VEContextAddLayer(VEContext *context, CCLayer *layer)
{
    [context->_renderQueue addObject: layer];
}

void VEContextRender(VEContext *context)
{

}

void VEContextSaveState(VEContext *context)
{
    GLKMatrixStackPush(context->_currentStack);
}

void VEContextRestoreState(VEContext *context)
{
    GLKMatrixStackPop(context->_currentStack);
}

void VEContextMatrixMode(VEContext *context, GLenum mode)
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

void VEContextLoadIdentity(VEContext *context)
{
    GLKMatrixStackLoadMatrix4(context->_currentStack, GLKMatrix4Identity);
}

void VEContextLoadCTM(VEContext *context, GLKMatrix4 pIn)
{
    GLKMatrixStackLoadMatrix4(context->_currentStack, pIn);
}

void VEContextConcatCTM(VEContext *context, GLKMatrix4 pIn)
{
    GLKMatrixStackMultiplyMatrix4(context->_currentStack, pIn);
}

void VEContextTranslateCTM(VEContext *context, float tx, float ty, float tz)
{
    GLKMatrixStackTranslate(context->_currentStack, tx, ty, tz);
}

void VEContextRotateCTM(VEContext *context, float angle, float x, float y, float z)
{
    GLKMatrixStackRotate(context->_currentStack, angle, x, y, z);
}

void VEContextScaleCTM(VEContext *context, float sx, float sy, float sz)
{
    GLKMatrixStackScale(context->_currentStack, sx, sy, sz);
}

GLKMatrix4 VEContextGetMVPMatrix(VEContext *context)
{
    return GLKMatrix4Multiply(GLKMatrixStackGetMatrix4(context->_projectionMatrixStack),
                              GLKMatrixStackGetMatrix4(context->_modelViewMatrixStack));
}

VEContext *VEContextGetCurrentContext(void)
{
    return __currentContext;
}

@end
