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


#import "CCGLProgram.h"
#import "ccGLStateCache.h"
#import "ccMacros.h"
#import "Support/CCFileUtils.h"

#import "Support/OpenGL_Internal.h"


#pragma mark - Function Pointer Definitions

typedef void (*GLInfoFunction)(GLuint program, GLenum pname, GLint* params);

typedef void (*GLLogFunction) (GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog);

#pragma mark -

@interface CCGLProgram ()
{
    CFMutableDictionaryRef	_hashForUniforms;
    
    GLuint          _program;
    GLuint          _vertexShader;
    GLuint          _fragmentShader;
    
    GLint			_uniforms[kCCUniform_MAX];
    
}

@end

@implementation CCGLProgram

- (id)initWithVertexShaderSource: (const GLchar*)vShaderSource
            fragmentShaderSource: (const GLchar*)fShaderSource
{
    if ((self = [super init]) )
    {
        _program = glCreateProgram();
		
		_vertexShader = _fragmentShader = 0;
		
        if(!CCGLProgramCompileShader(self, &_vertexShader, GL_VERTEX_SHADER, vShaderSource))
        {
            CCLOG(@"cocos2d: ERROR: Failed to compile vertex shader");
		}
		
        // Create and compile fragment shader
        if(!CCGLProgramCompileShader(self, &_fragmentShader, GL_FRAGMENT_SHADER, fShaderSource))
        {
            CCLOG(@"cocos2d: ERROR: Failed to compile fragment shader");
		}
		
		if( _vertexShader )
			glAttachShader(_program, _vertexShader);
		
		if( _fragmentShader )
			glAttachShader(_program, _fragmentShader);
		
		_hashForUniforms = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 10, NULL, NULL);
    }
	
    return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Program = %i, VertexShader = %i, FragmentShader = %i>", [self class], self, _program, _vertexShader, _fragmentShader];
}

static BOOL CCGLProgramCompileShader(CCGLProgram *self, GLuint *shader, GLenum type, const GLchar *source)
{
    GLint status;
    
    if (!source)
        return NO;
	
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
	
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
	
	if( ! status )
    {
        CCLOG(@"cocos2d: %@", CCGLProgramShaderLogInfo(self, type));
	}
    
    return ( status == GL_TRUE );
}

static NSString *CCGLProgramLogForOpenGLObject(GLuint object, GLInfoFunction infoFunc, GLLogFunction logFunc)
{
    GLint logLength = 0, charsWritten = 0;
    
    infoFunc(object, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength < 1)
        return nil;
    
    char *logBytes = malloc(logLength);
    logFunc(object, logLength, &charsWritten, logBytes);
    
    NSString *log = [[[NSString alloc] initWithBytes: logBytes
                                              length: logLength
                                            encoding: NSUTF8StringEncoding]
                     autorelease];
    free(logBytes);
    
    return log;
}

#pragma mark - Uniform cache

static BOOL CCGLProgramUpdateUniform(CFMutableDictionaryRef	_hashForUniforms,
                                     NSUInteger location,
                                     GLvoid* data,
                                     NSUInteger bytes)
{
	BOOL updated = YES;
    
	tHashUniformEntry *element = (void *)CFDictionaryGetValue(_hashForUniforms, (const void *)location);
    
	if( ! element )
    {
        
		element = malloc( sizeof(*element) );
        
		// key
		element->location = location;
        
		// value
		element->value = malloc( bytes );
		memcpy(element->value, data, bytes );
		
        CFDictionarySetValue(_hashForUniforms, (const void *)location, element);
        
	}else
	{
		if( memcmp( element->value, data, bytes) == 0 )
			updated = NO;
		else
			memcpy( element->value, data, bytes );
	}
	
	return updated;
}

#pragma mark -

static void __CFDictionaryApplierFunction(const void *key, const void *value, void *context)
{
    tHashUniformEntry *element = (void *)value;
    free(element->value);
    free(element);
}

void CCGLProgramUse(CCGLProgram *program)
{
    CCGLUseProgram(program->_program);
}

void CCGLProgramUniformForModelViewProjectionMatrix(CCGLProgram *program)
{
    CCGLProgramUniformMatrix4fv(program, program->_uniforms[kCCUniformMVPMatrix], VEGLGetMVPMatrix().m, 1);
}

void CCGLProgramUniformf(CCGLProgram *program, GLint location, GLfloat *floats, GLsizei count)
{
    BOOL updated = CCGLProgramUpdateUniform(program->_hashForUniforms, location, floats, sizeof(GLfloat) * count);
    if (updated)
    {
        switch (count)
        {
            case 1:
            {
                glUniform1f(location, floats[0]);
                break;
            }
            case 2:
            {
                glUniform2f(location, floats[0], floats[1]);
                break;
            }
            case 3:
            {
                glUniform3f(location, floats[0], floats[1], floats[2]);
                break;
            }
            case 4:
            {
                glUniform4f(location, floats[0], floats[1], floats[2], floats[3]);
                break;
            }
            default:
            {
                break;
            }
        }
    }
    
}


void CCGLProgramUniformfv(CCGLProgram *program, GLint location, GLvoid *floats, GLsizei numberOfArrays, CCGLUniformType type)
{
    BOOL updated = CCGLProgramUpdateUniform(program->_hashForUniforms, location, floats, sizeof(float) * type * numberOfArrays);
    if (updated)
    {
        switch (type)
        {
            case CCGLUniform1fv:
            {
                glUniform1fv( location, numberOfArrays, floats);
                break;
            }
            case CCGLUniform2fv:
            {
                glUniform2fv( location, numberOfArrays, floats);
                break;
            }
            case CCGLUniform3fv:
            {
                glUniform3fv( location, numberOfArrays, floats);
                break;
            }
            case CCGLUniform4fv:
            {
                glUniform4fv( location, numberOfArrays, floats);
                break;
            }
            default:
            {
                break;
            }
        }
    }
    
}

void CCGLProgramUniformMatrix4fv(CCGLProgram *program, GLint location, GLvoid *matrix, GLsizei numberOfMatrices)
{
    BOOL updated = CCGLProgramUpdateUniform(program->_hashForUniforms, location, matrix, sizeof(float) * 16 * numberOfMatrices);
    
	if( updated )
    {
		glUniformMatrix4fv(location, numberOfMatrices, GL_FALSE, matrix);
    }
}

void CCGLProgramAddAttribute(CCGLProgram *program, const char *attributeName, GLuint index)
{
	glBindAttribLocation(program->_program, index, attributeName);
}

void CCGLProgramUpdateUniforms(CCGLProgram *program)
{
    // Since sample most probably won't change, set it to 0 now.
    
	program->_uniforms[kCCUniformMVPMatrix] = glGetUniformLocation(program->_program, kCCUniformMVPMatrix_s);
    
	program->_uniforms[kCCUniformSampler] = glGetUniformLocation(program->_program, kCCUniformSampler_s);
    
    CCGLProgramUse(program);
	
    GLint i1 = 0;
    GLint location = program->_uniforms[kCCUniformSampler];
    BOOL updated = CCGLProgramUpdateUniform(program->_hashForUniforms, location, &i1, sizeof(i1));
	
	if( updated )
    {
		glUniform1i(location, i1);
    }
}

#pragma mark -

BOOL CCGLProgramLink(CCGLProgram *program)
{
    GLuint _program = program->_program;
    GLuint vertexShader = program->_vertexShader;
    GLuint fragmentShader = program->_fragmentShader;
    
    glLinkProgram(_program);
    
#if DEBUG
	GLint status;
    
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE)
    {
		CCLOG(@"cocos2d: ERROR: Failed to link program: %i", _program);
		if( vertexShader )
			glDeleteShader( vertexShader );
		if( fragmentShader )
			glDeleteShader( fragmentShader );
		CCGLDeleteProgram( _program );
        
        program->_vertexShader = 0;
        program->_fragmentShader = 0;
        program->_program = 0;
        
        return NO;
	}
#endif
    
    if( vertexShader )
        glDeleteShader( vertexShader );
    if( fragmentShader )
        glDeleteShader( fragmentShader );
    
    program->_vertexShader = 0;
    program->_fragmentShader = 0;
    
    return YES;
}


NSString *CCGLProgramShaderLogInfo(CCGLProgram *program, GLenum shaderType)
{
    switch (shaderType)
    {
        case GL_VERTEX_SHADER:
        {
            return CCGLProgramLogForOpenGLObject(program->_vertexShader, glGetShaderiv, glGetShaderInfoLog);
        }
        case GL_FRAGMENT_SHADER:
        {
            return CCGLProgramLogForOpenGLObject(program->_fragmentShader, glGetShaderiv, glGetShaderInfoLog);
        }
        default:
        {
            return nil;
        }
    }
}

NSString *CCGLProgramLogInfo(CCGLProgram *program)
{
    return CCGLProgramLogForOpenGLObject(program->_program, glGetProgramiv, glGetProgramInfoLog);
}

GLint CCGLProgramGetUniformLocation(CCGLProgram *program, const GLchar *name)
{
    return glGetUniformLocation(program->_program, name);
}

- (void)dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);
    
	// there is no need to delete the shaders. They should have been already deleted.
	NSAssert( _vertexShader == 0, @"Vertex Shaders should have been already deleted");
	NSAssert( _fragmentShader == 0, @"Vertex Shaders should have been already deleted");
    
    if (_program)
    {
        CCGLDeleteProgram(_program);
    }
    
    CFDictionaryApplyFunction(_hashForUniforms,  __CFDictionaryApplierFunction, NULL);
    
    CFDictionaryRemoveAllValues(_hashForUniforms);
    
    [super dealloc];
}

@end


