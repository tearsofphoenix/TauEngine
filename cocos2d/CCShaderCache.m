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

#include "CCShaderCache.h"
#include "ccShaders.h"
#include "CCGLProgram.h"
#include "ccMacros.h"
#include "Support/OpenGL_Internal.h"

static NSMutableDictionary	*_programs = nil;

static void CCShaderCacheLoadDefaultShaders(NSMutableDictionary *programDictionary)
{
	// Position Texture Color shader
	CCGLProgram *p = [[CCGLProgram alloc] initWithVertexShaderSource: ccPositionTextureColor_vert
												fragmentShaderSource: ccPositionTextureColor_frag];
    
    CCGLProgramAddAttribute(p, kCCAttributeNamePosition, kCCVertexAttrib_Position);
	CCGLProgramAddAttribute(p, kCCAttributeNameColor, kCCVertexAttrib_Color);
	CCGLProgramAddAttribute(p, kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
    
	CCGLProgramLink(p);
	CCGLProgramUpdateUniforms(p);;
    
	[programDictionary setObject: p
                          forKey: kCCShader_PositionTextureColor];
	[p release];
    
	CHECK_GL_ERROR_DEBUG();
    
	// Position Texture Color alpha test
	p = [[CCGLProgram alloc] initWithVertexShaderSource: ccPositionTextureColor_vert
								   fragmentShaderSource: ccPositionTextureColorAlphaTest_frag];
    
    CCGLProgramAddAttribute(p, kCCAttributeNamePosition, kCCVertexAttrib_Position);
	CCGLProgramAddAttribute(p, kCCAttributeNameColor, kCCVertexAttrib_Color);
	CCGLProgramAddAttribute(p, kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
    
	CCGLProgramLink(p);
	CCGLProgramUpdateUniforms(p);;
    
	[programDictionary setObject: p
                          forKey: kCCShader_PositionTextureColorAlphaTest];
	[p release];
    
	CHECK_GL_ERROR_DEBUG();
    
	//
	// Position, Color shader
	//
	p = [[CCGLProgram alloc] initWithVertexShaderSource: ccPositionColor_vert
								   fragmentShaderSource: ccPositionColor_frag];
    
    CCGLProgramAddAttribute(p, kCCAttributeNamePosition, kCCVertexAttrib_Position);
	CCGLProgramAddAttribute(p, kCCAttributeNameColor, kCCVertexAttrib_Color);
    
	CCGLProgramLink(p);
	CCGLProgramUpdateUniforms(p);;
    
	[programDictionary setObject: p
                          forKey: CCShaderPositionColorProgram];
	[p release];
    
	CHECK_GL_ERROR_DEBUG();
    
	//
	// Position Texture shader
	//
	p = [[CCGLProgram alloc] initWithVertexShaderSource: ccPositionTexture_vert
								   fragmentShaderSource: ccPositionTexture_frag];
    
    CCGLProgramAddAttribute(p, kCCAttributeNamePosition, kCCVertexAttrib_Position);
	CCGLProgramAddAttribute(p, kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
    
	CCGLProgramLink(p);
	CCGLProgramUpdateUniforms(p);;
    
	[programDictionary setObject: p
                          forKey: kCCShader_PositionTexture];
	[p release];
    
	CHECK_GL_ERROR_DEBUG();
    
	//
	// Position, Texture attribs, 1 Color as uniform shader
	//
	p = [[CCGLProgram alloc] initWithVertexShaderSource: ccPositionTexture_uColor_vert
								   fragmentShaderSource: ccPositionTexture_uColor_frag];
    
    CCGLProgramAddAttribute(p, kCCAttributeNamePosition, kCCVertexAttrib_Position);
	CCGLProgramAddAttribute(p, kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
    
	CCGLProgramLink(p);
	CCGLProgramUpdateUniforms(p);;
    
	[programDictionary setObject: p
                          forKey: kCCShader_PositionTexture_uColor];
	[p release];
	
	CHECK_GL_ERROR_DEBUG();
    
	//
	// Position Texture A8 Color shader
	//
	p = [[CCGLProgram alloc] initWithVertexShaderSource: ccPositionTextureA8Color_vert
								   fragmentShaderSource: ccPositionTextureA8Color_frag];
    
    CCGLProgramAddAttribute(p, kCCAttributeNamePosition, kCCVertexAttrib_Position);
	CCGLProgramAddAttribute(p, kCCAttributeNameColor, kCCVertexAttrib_Color);
	CCGLProgramAddAttribute(p, kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
    
	CCGLProgramLink(p);
	CCGLProgramUpdateUniforms(p);;
    
	[programDictionary setObject: p
                          forKey: kCCShader_PositionTextureA8Color];
	[p release];
    
	CHECK_GL_ERROR_DEBUG();
	
	//
	// Position and 1 color passed as a uniform (to similate glColor4ub )
	//
	p = [[CCGLProgram alloc] initWithVertexShaderSource: ccPosition_uColor_vert
								   fragmentShaderSource: ccPosition_uColor_frag];
	
    CCGLProgramAddAttribute(p, "aVertex", kCCVertexAttrib_Position);
	
	CCGLProgramLink(p);
	CCGLProgramUpdateUniforms(p);;
    
	[programDictionary setObject: p
                          forKey: kCCShader_Position_uColor];
	[p release];
    
	CHECK_GL_ERROR_DEBUG();
}


void CCShaderCacheInitialize(void)
{
    if (!_programs)
    {
        _programs = [[NSMutableDictionary alloc] initWithCapacity: 10];

        glEnable(GL_LINE_SMOOTH);
        
        CCShaderCacheLoadDefaultShaders(_programs);
    };
}

void CCShaderCacheFinalize(void)
{
    [_programs release];
    _programs = nil;
}

void CCShaderCacheAddProgram(CCGLProgram *program, NSString *key)
{
    [_programs setObject: program
                  forKey: key];
}

CCGLProgram *CCShaderCacheGetProgramByName(NSString *key)
{
    return [_programs objectForKey:key];
}

