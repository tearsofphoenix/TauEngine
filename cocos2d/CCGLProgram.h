//
// Copyright 2011 Jeff Lamarche
//
// Copyright 2012 Goffredo Marocchi
//
// Copyright 2012 Ricardo Quesada
//
//
// Redistribution and use in source and binary forms, with or without modification, are permitted provided
// that the following conditions are met:
//	1. Redistributions of source code must retain the above copyright notice, this list of conditions and
//		the following disclaimer.
//
//	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions
//		and the following disclaimer in the documentation and/or other materials provided with the
//		distribution.
//
//	THIS SOFTWARE IS PROVIDED BY THE FREEBSD PROJECT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE FREEBSD PROJECT
//	OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
//	OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
//	AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ccMacros.h"


typedef struct _hashUniformEntry
{
	GLvoid			*value;		// value
	NSUInteger		location;	// Key
} tHashUniformEntry;

enum
{
	kCCVertexAttrib_Position,
	kCCVertexAttrib_Color,
	kCCVertexAttrib_TexCoords,

	kCCVertexAttrib_MAX,
};

enum
{
	kCCUniformMVPMatrix,
	kCCUniformSampler,

	kCCUniform_MAX,
};

#define kCCShader_PositionTextureColor			@"ShaderPositionTextureColor"
#define kCCShader_PositionTextureColorAlphaTest	@"ShaderPositionTextureColorAlphaTest"
#define CCShaderPositionColorProgram					@"ShaderPositionColor"
#define kCCShader_PositionTexture				@"ShaderPositionTexture"
#define kCCShader_PositionTexture_uColor		@"ShaderPositionTexture_uColor"
#define kCCShader_PositionTextureA8Color		@"ShaderPositionTextureA8Color"
#define kCCShader_Position_uColor				@"ShaderPosition_uColor"

// uniform names
#define kCCUniformMVPMatrix_s			"u_MVPMatrix"
#define kCCUniformSampler_s				"u_texture"
#define kCCUniformAlphaTestValue		"u_alpha_value"

// Attribute names
#define	kCCAttributeNameColor			"a_color"
#define	kCCAttributeNamePosition		"a_position"
#define	kCCAttributeNameTexCoord		"a_texCoord"


struct _hashUniformEntry;

/** CCGLProgram
 Class that implements a glProgram
 
 
 @since v2.0.0
 */
@interface CCGLProgram : NSObject

/** Initializes the CCGLProgram with a vertex and fragment with bytes array */
- (id)initWithVertexShaderSource: (const GLchar*)vShaderSource
            fragmentShaderSource: (const GLchar*)fShaderSource;

@end

#ifdef __cplusplus
extern "C" {
#endif
    
    typedef NS_ENUM(NSUInteger, CCGLUniformType)
    {
        CCGLUniform1fv = 1,
        CCGLUniform2fv = 2,
        CCGLUniform3fv = 3,
        CCGLUniform4fv = 4,
    };

    CF_EXPORT void CCGLProgramUse(CCGLProgram *program);

    CF_EXPORT void CCGLProgramUniformForMVPMatrix(CCGLProgram *program);

    CF_EXPORT void CCGLProgramUniformf(CCGLProgram *program, GLint location, GLfloat *floats, GLsizei count);

    CF_EXPORT void CCGLProgramUniformfv(CCGLProgram *program, GLint location, GLvoid *floats, GLsizei numberOfArrays, CCGLUniformType type);
    
    CF_EXPORT void CCGLProgramUniformMatrix4fv(CCGLProgram *program, GLint location, GLvoid *matrix, GLsizei numberOfMatrix);

    CF_EXPORT void CCGLProgramAddAttribute(CCGLProgram *program, const char *attributeName, GLuint index);

    /** It will create 3 uniforms:
     - kCCUniformPMatrix
     - kCCUniformMVMatrix
     - kCCUniformSampler
     
     And it will bind "kCCUniformSampler" to 0
     */
    CF_EXPORT void CCGLProgramUpdateUniforms(CCGLProgram *program);

    /** links the glProgram */
    CF_EXPORT BOOL CCGLProgramLink(CCGLProgram *program);

    CF_EXPORT GLint CCGLProgramGetUniformLocation(CCGLProgram *program, const GLchar *name);
    
#pragma mark - debug
    /** returns the Shader error log */
    CF_EXPORT NSString *CCGLProgramShaderLogInfo(CCGLProgram *program, GLenum shaderType);
    
    /** returns the program error log */
    CF_EXPORT NSString *CCGLProgramLogInfo(CCGLProgram *program);

#ifdef __cplusplus
    }
#endif
