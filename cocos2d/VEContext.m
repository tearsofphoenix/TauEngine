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
    }
    
    return self;
}

- (void)dealloc
{
    [_renderQueue release];
    [super dealloc];
}

void VEContextAddLayer(VEContext *context, CCLayer *layer)
{
    [context->_renderQueue addObject: layer];
}

void VEContextRender(VEContext *context)
{
    for (CCLayer *layer in context->_renderQueue)
    {
        /*
        CC_NODE_DRAW_SETUP();
        
        VEGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );
        
        //
        // Attributes
        //
        glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, squareVertices_);
        glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, 0, squareColors_);
        
        CCGLBlendFunc( _blendFunc.src, _blendFunc.dst );
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        */
        CC_INCREMENT_GL_DRAWS(1);
    }
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
