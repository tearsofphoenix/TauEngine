/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ccGLStateCache.h"
#import "CCGLProgram.h"
#import "CCDirector.h"
#import "ccConfig.h"
#import "ccGLStateCache.h"


static GLuint	_ccCurrentProjectionMatrix = -1;
static BOOL		_vertexAttribPosition = NO;
static BOOL		_vertexAttribColor = NO;
static BOOL		_vertexAttribTexCoords = NO;

#if CC_ENABLE_GL_STATE_CACHE
#define kCCMaxActiveTexture 16

static GLuint	_ccCurrentShaderProgram = -1;

static GLuint	_ccCurrentBoundTexture[kCCMaxActiveTexture] =  {-1,-1,-1,-1,
                                                                -1,-1,-1,-1,
                                                                -1,-1,-1,-1,
                                                                -1,-1,-1,-1,};

static GLenum	_ccCurrentActiveTexture = (GL_TEXTURE0 - GL_TEXTURE0);
static GLenum	_ccBlendingSource = -1;
static GLenum	_ccBlendingDest = -1;
static ccGLServerState _ccGLServerState = 0;
#endif // CC_ENABLE_GL_STATE_CACHE

#pragma mark - GL State Cache functions

void CCGLInvalidateStateCache( void )
{
	VEGLFreeAll();

	_ccCurrentProjectionMatrix = -1;
	_vertexAttribPosition = NO;
	_vertexAttribColor = NO;
	_vertexAttribTexCoords = NO;

#if CC_ENABLE_GL_STATE_CACHE
	_ccCurrentShaderProgram = -1;
	for( NSInteger i=0; i < kCCMaxActiveTexture; i++ )
		_ccCurrentBoundTexture[i] = -1;
	_ccCurrentActiveTexture = (GL_TEXTURE0 - GL_TEXTURE0);
	_ccBlendingSource = -1;
	_ccBlendingDest = -1;
	_ccGLServerState = 0;
#endif
}

void CCGLDeleteProgram( GLuint program )
{
#if CC_ENABLE_GL_STATE_CACHE
	if( program == _ccCurrentShaderProgram )
		_ccCurrentShaderProgram = -1;
#endif // CC_ENABLE_GL_STATE_CACHE

	glDeleteProgram( program );
}

void CCGLUseProgram( GLuint program )
{
#if CC_ENABLE_GL_STATE_CACHE
	if( program != _ccCurrentShaderProgram ) {
		_ccCurrentShaderProgram = program;
		glUseProgram(program);
	}
#else
	glUseProgram(program);
#endif // CC_ENABLE_GL_STATE_CACHE
}


void CCGLBlendFunc(GLenum sfactor, GLenum dfactor)
{
#if CC_ENABLE_GL_STATE_CACHE
	if( sfactor != _ccBlendingSource || dfactor != _ccBlendingDest )
    {
		_ccBlendingSource = sfactor;
		_ccBlendingDest = dfactor;
		glBlendFunc( sfactor, dfactor );
	}
#else
	glBlendFunc( sfactor, dfactor );
#endif // CC_ENABLE_GL_STATE_CACHE
}

GLenum ccGLGetActiveTexture( void )
{
#if CC_ENABLE_GL_STATE_CACHE
	return _ccCurrentActiveTexture + GL_TEXTURE0;
#else
	GLenum activeTexture;
	glGetIntegerv(GL_ACTIVE_TEXTURE, (GLint*)&activeTexture);
	return activeTexture;
#endif
}

void ccGLActiveTexture( GLenum textureEnum )
{
#if CC_ENABLE_GL_STATE_CACHE
	NSCAssert1( (textureEnum - GL_TEXTURE0) < kCCMaxActiveTexture, @"cocos2d ERROR: Increase kCCMaxActiveTexture to %d!", (textureEnum-GL_TEXTURE0) );
	if( (textureEnum - GL_TEXTURE0) != _ccCurrentActiveTexture ) {
		_ccCurrentActiveTexture = (textureEnum - GL_TEXTURE0);
		glActiveTexture( textureEnum );
	}
#else
	glActiveTexture( textureEnum );
#endif
}
	

void ccGLBindTexture2D( GLuint textureId )
{
#if CC_ENABLE_GL_STATE_CACHE
	if( _ccCurrentBoundTexture[ _ccCurrentActiveTexture ] != textureId )
	{
		_ccCurrentBoundTexture[ _ccCurrentActiveTexture ] = textureId;
		glBindTexture(GL_TEXTURE_2D, textureId );
	}
#else
	glBindTexture(GL_TEXTURE_2D, textureId );
#endif
}


void VEGLDeleteTexture( GLuint textureId )
{
#if CC_ENABLE_GL_STATE_CACHE
	if( textureId == _ccCurrentBoundTexture[ _ccCurrentActiveTexture ] )
	   _ccCurrentBoundTexture[ _ccCurrentActiveTexture ] = -1;
#endif
	glDeleteTextures(1, &textureId );
}

void VEGLEnable( ccGLServerState flags )
{
#if CC_ENABLE_GL_STATE_CACHE

	BOOL enabled = NO;

	/* GL_BLEND */
	if( (enabled=(flags & CC_GL_BLEND)) != (_ccGLServerState & CC_GL_BLEND) )
    {
		if( enabled )
        {
			glEnable( GL_BLEND );
			_ccGLServerState |= CC_GL_BLEND;
		} else {
			glDisable( GL_BLEND );
			_ccGLServerState &=  ~CC_GL_BLEND;
		}
	}

#else
	if( flags & CC_GL_BLEND )
		glEnable( GL_BLEND );
	else
		glDisable( GL_BLEND );
#endif
}

#pragma mark - GL Vertex Attrib functions

void VEGLEnableVertexAttribs( unsigned int flags )
{
	/* Position */
	BOOL enablePosition = flags & kCCVertexAttribFlag_Position;

	if( enablePosition != _vertexAttribPosition )
    {
		if( enablePosition )
			glEnableVertexAttribArray( kCCVertexAttrib_Position );
		else
			glDisableVertexAttribArray( kCCVertexAttrib_Position );

		_vertexAttribPosition = enablePosition;
	}

	/* Color */
	BOOL enableColor = flags & kCCVertexAttribFlag_Color;

	if( enableColor != _vertexAttribColor )
    {
		if( enableColor )
			glEnableVertexAttribArray( kCCVertexAttrib_Color );
		else
			glDisableVertexAttribArray( kCCVertexAttrib_Color );

		_vertexAttribColor = enableColor;
	}

	/* Tex Coords */
	BOOL enableTexCoords = flags & kCCVertexAttribFlag_TexCoords;

	if( enableTexCoords != _vertexAttribTexCoords )
    {
		if( enableTexCoords )
			glEnableVertexAttribArray( kCCVertexAttrib_TexCoords );
		else
			glDisableVertexAttribArray( kCCVertexAttrib_TexCoords );

		_vertexAttribTexCoords = enableTexCoords;
	}
}

#pragma mark - GL Uniforms functions

void CCSetProjectionMatrixDirty( void )
{
	_ccCurrentProjectionMatrix = -1;
}


#pragma mark - GLKMatrixStack

GLKMatrixStackRef modelview_matrix_stack;
GLKMatrixStackRef projection_matrix_stack;
GLKMatrixStackRef texture_matrix_stack;

GLKMatrixStackRef current_stack = NULL;

static unsigned char initialized = 0;

void lazyInitialize(void)
{
    
	if (!initialized)
    {
        
		//Initialize all 3 stacks
        modelview_matrix_stack = GLKMatrixStackCreate(CFAllocatorGetDefault());
        
		//projection_matrix_stack = (GLKMatrixStackRef*) malloc(sizeof(GLKMatrixStackRef));
        projection_matrix_stack = GLKMatrixStackCreate(CFAllocatorGetDefault());
        
		//texture_matrix_stack = (GLKMatrixStackRef*) malloc(sizeof(GLKMatrixStackRef));
        texture_matrix_stack = GLKMatrixStackCreate(CFAllocatorGetDefault());
        
		current_stack = modelview_matrix_stack;
		initialized = 1;
	}
}

void VEGLMatrixMode(GLenum mode)
{
	
    
	switch(mode)
	{
		case GL_MODELVIEW_MATRIX:
			current_stack = modelview_matrix_stack;
            break;
		case GL_PROJECTION_MATRIX:
			current_stack = projection_matrix_stack;
            break;
		case GL_TEXTURE_MATRIX:
			current_stack = texture_matrix_stack;
            break;
		default:
			assert(0 && "Invalid matrix mode specified"); //TODO: Proper error handling
            break;
	}
}

void VEGLPushMatrix(void)
{
    
    GLKMatrixStackPush(current_stack);
}

void VEGLPopMatrix(void)
{
    assert(initialized && "Cannot Pop empty matrix stack");
    GLKMatrixStackPop(current_stack);
}

void VEGLLoadIdentity()
{
	
    
    GLKMatrixStackLoadMatrix4(current_stack, GLKMatrix4Identity);
}

void VEGLFreeAll()
{
	//Clear the matrix stacks
	CFRelease(modelview_matrix_stack);
	CFRelease(projection_matrix_stack);
	CFRelease(texture_matrix_stack);
    
	//Delete the matrices
	initialized = 0; //Set to uninitialized
    
	current_stack = NULL; //Set the current stack to point nowhere
}

void VECurrentGLMatrixStackMultiplyMatrix4(const GLKMatrix4 pIn)
{
	
    GLKMatrixStackMultiplyMatrix4(current_stack, pIn);
}

void VECurrentGLMatrixStackLoadMatrix4(const GLKMatrix4 pIn)
{
	
    GLKMatrixStackLoadMatrix4(current_stack, pIn);
}

GLKMatrix4 VEGLGetMVPMatrix(void)
{
    return GLKMatrix4Multiply(GLKMatrixStackGetMatrix4(projection_matrix_stack), GLKMatrixStackGetMatrix4(modelview_matrix_stack));
}

void VEGLTranslatef(float x, float y, float z)
{
    GLKMatrixStackTranslate(current_stack, x, y, z);
}

void VEGLRotatef(float angle, float x, float y, float z)
{
    GLKMatrixStackRotate(current_stack, angle, x, y, z);
}

void VEGLScalef(float x, float y, float z)
{
    GLKMatrixStackScale(current_stack, x, y, z);
}
