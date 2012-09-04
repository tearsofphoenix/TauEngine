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

#import <GLKit/GLKit.h>

@class CCGLProgram;

/** vertex attrib flags */
enum {
	kCCVertexAttribFlag_None		= 0,

	kCCVertexAttribFlag_Position	= 1 << 0,
	kCCVertexAttribFlag_Color		= 1 << 1,
	kCCVertexAttribFlag_TexCoords	= 1 << 2,

	kCCVertexAttribFlag_PosColorTex = ( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color | kCCVertexAttribFlag_TexCoords ),
};

/** GL server side states */
typedef NS_ENUM(NSUInteger, ccGLServerState)
{
	CC_GL_BLEND = 1 << 3,
	CC_GL_ALL = ( CC_GL_BLEND ),

} ;


#ifdef __cplusplus
extern "C" {
#endif

/** @file ccGLStateCache.h
*/

/** Invalidates the GL state cache.
 @since v2.0.0
 */
void CCGLInvalidateStateCache( void );

/** Uses the GL program in case program is different than the current one.
 @since v2.0.0
 */
void CCGLUseProgram( GLuint program );

/** Deletes the GL program. If it is the one that is being used, it invalidates it.
 @since v2.0.0
 */
void CCGLDeleteProgram( GLuint program );

/** Uses a blending function in case it not already used.
 @since v2.0.0
 */
void CCGLBlendFunc(GLenum sfactor, GLenum dfactor);

/** sets the projection matrix as dirty
 @since v2.0.0
 */
void CCSetProjectionMatrixDirty( void );

/** Will enable the vertex attribs that are passed as flags.
 Possible flags:

	* kCCVertexAttribFlag_Position
	* kCCVertexAttribFlag_Color
	* kCCVertexAttribFlag_TexCoords

 These flags can be ORed. The flags that are not present, will be disabled.

 @since v2.0.0
 */
void VEGLEnableVertexAttribs( unsigned int flags );

/** If the active texture is not textureEnum, then it will active it.
 @since v2.0.0
 */
void ccGLActiveTexture(GLenum textureEnum );

/** Returns the active texture.
 @since v2.0.0
 */
GLenum ccGLGetActiveTexture( void );


/** If the texture is not already bound, it binds it.
 @since v2.0.0
 */
void ccGLBindTexture2D(GLuint textureId );

/** It will delete a given texture. If the texture was bound, it will invalidate the cached.
 @since v2.0.0
 */
void VEGLDeleteTexture(GLuint textureId);

/** It will enable / disable the server side GL states.
 @since v2.0.0
 */
void VEGLEnable( ccGLServerState flags );

    void lazyInitialize(void);
    void VEGLFreeAll(void);
    
    void VEGLPushMatrix(void);
    void VEGLPopMatrix(void);
    
    void VEGLMatrixMode(GLenum mode);
    
    void VEGLLoadIdentity(void);
    
    void VECurrentGLMatrixStackLoadMatrix4(GLKMatrix4 pIn);
    void VECurrentGLMatrixStackMultiplyMatrix4(GLKMatrix4 pIn);

    void VEGLTranslatef(float x, float y, float z);
    void VEGLRotatef(float angle, float x, float y, float z);
    void VEGLScalef(float x, float y, float z);
    
    GLKMatrix4 VEGLGetMVPMatrix(void);
    
#ifdef __cplusplus
}
#endif
