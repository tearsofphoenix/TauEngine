/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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


/**
 @file
 cocos2d (cc) types
*/

#import <Foundation/Foundation.h>
#import "ccMacros.h"

#ifdef __CC_PLATFORM_IOS
#import <CoreGraphics/CGGeometry.h>	// CGPoint
#endif

#import "Platforms/CCGL.h"

/** RGB color composed of bytes 3 bytes
@since v0.8
 */
typedef struct _ccColor3B
{
	GLubyte	r;
	GLubyte	g;
	GLubyte b;
} ccColor3B;

//! helper macro that creates an ccColor3B type
static inline ccColor3B
ccc3(const GLubyte r, const GLubyte g, const GLubyte b)
{
	ccColor3B c = {r, g, b};
	return c;
}

/** RGBA color composed of 4 bytes
@since v0.8
*/
typedef struct _ccColor4B
{
	GLubyte	r;
	GLubyte	g;
	GLubyte	b;
	GLubyte a;
} ccColor4B;
//! helper macro that creates an ccColor4B type
static inline ccColor4B
ccc4(const GLubyte r, const GLubyte g, const GLubyte b, const GLubyte o)
{
	ccColor4B c = {r, g, b, o};
	return c;
}

static inline bool CCColor4BEqualToColor(ccColor4B c1, ccColor4B c2)
{
    if(c1.r == c2.r && c1.g == c2.g && c1.b == c2.b && c1.a == c2.a)
    {
        return true;
    }
    
    return false;
}

//! White color (255,255,255)
static const ccColor4B ccWHITE = {255,255,255, 255};
//! Yellow color (255,255,0)
static const ccColor4B ccYELLOW = {255,255,0, 255};
//! Blue color (0,0,255)
static const ccColor4B ccBLUE = {0,0,255, 255};
//! Green Color (0,255,0)
static const ccColor4B ccGREEN = {0,255,0, 255};
//! Red Color (255,0,0,)
static const ccColor4B ccRED = {255,0,0, 255};
//! Magenta Color (255,0,255)
static const ccColor4B ccMAGENTA = {255,0,255, 255};
//! Black Color (0,0,0)
static const ccColor4B ccBLACK = {0,0,0, 255};
//! Orange Color (255,127,0)
static const ccColor4B ccORANGE = {255,127,0, 255};
//! Gray Color (166,166,166)
static const ccColor4B ccGRAY = {166,166,166, 255};

/** Returns a GLKVector4 from a ccColor3B. Alpha will be 1.
 @since v0.99.1
 */
static inline GLKVector4 ccc4FFromccc3B(ccColor3B c)
{
	return GLKVector4Make(c.r/255.f, c.g/255.f, c.b/255.f, 1.f);
}

/** Returns a GLKVector4 from a ccColor4B.
 @since v0.99.1
 */
static inline GLKVector4 ccc4FFromccc4B(ccColor4B c)
{
	return GLKVector4Make(c.r/255.f, c.g/255.f, c.b/255.f, c.a/255.f);
}

/** A texcoord composed of 2 floats: u, y
 @since v0.8
 */
typedef struct _ccTex2F {
	 GLfloat u;
	 GLfloat v;
} ccTex2F;


//! Point Sprite component
typedef struct _ccPointSprite
{
	GLKVector2	pos;		// 8 bytes
	ccColor4B	color;		// 4 bytes
	GLfloat		size;		// 4 bytes
} ccPointSprite;

//!	A 2D Quad. 4 * 2 floats
typedef struct _ccQuad2 {
	GLKVector2		tl;
	GLKVector2		tr;
	GLKVector2		bl;
	GLKVector2		br;
} ccQuad2;


//!	A 3D Quad. 4 * 3 floats
typedef struct _ccQuad3 {
	GLKVector3		bl;
	GLKVector3		br;
	GLKVector3		tl;
	GLKVector3		tr;
} ccQuad3;

//! A 2D grid size
typedef struct _ccGridSize
{
	NSInteger	x;
	NSInteger	y;
} ccGridSize;

//! helper function to create a ccGridSize
static inline ccGridSize
ccg(const NSInteger x, const NSInteger y)
{
	ccGridSize v = {x, y};
	return v;
}

//! a Point with a vertex point, a tex coord point and a color 4B
typedef struct _ccV2F_C4B_T2F
{
	//! vertices (2F)
	GLKVector2		vertices;
	//! colors (4B)
	ccColor4B		colors;
	//! tex coords (2F)
	ccTex2F			texCoords;
} ccV2F_C4B_T2F;

//! a Point with a vertex point, a tex coord point and a color 4F
typedef struct _ccV2F_C4F_T2F
{
	//! vertices (2F)
	GLKVector2		vertices;
	//! colors (4F)
	GLKVector4		colors;
	//! tex coords (2F)
	ccTex2F			texCoords;
} ccV2F_C4F_T2F;

//! a Point with a vertex point, a tex coord point and a color 4F
typedef struct _ccV3F_C4F_T2F
{
	//! vertices (3F)
	GLKVector3		vertices;
	//! colors (4F)
	GLKVector4		colors;
	//! tex coords (2F)
	ccTex2F			texCoords;
} ccV3F_C4F_T2F;

//! 4 ccV3F_C4F_T2F
typedef struct _ccV3F_C4F_T2F_Quad
{
	//! top left
	ccV3F_C4F_T2F	tl;
	//! bottom left
	ccV3F_C4F_T2F	bl;
	//! top right
	ccV3F_C4F_T2F	tr;
	//! bottom right
	ccV3F_C4F_T2F	br;
} ccV3F_C4F_T2F_Quad;

//! a Point with a vertex point, a tex coord point and a color 4B
typedef struct _ccV3F_C4B_T2F
{
	//! vertices (3F)
	GLKVector3		vertices;			// 12 bytes
//	char __padding__[4];

	//! colors (4B)
	ccColor4B		colors;				// 4 bytes
//	char __padding2__[4];

	// tex coords (2F)
	ccTex2F			texCoords;			// 8 byts
} ccV3F_C4B_T2F;

//! 4 ccVertex2FTex2FColor4B Quad
typedef struct _ccV2F_C4B_T2F_Quad
{
	//! bottom left
	ccV2F_C4B_T2F	bl;
	//! bottom right
	ccV2F_C4B_T2F	br;
	//! top left
	ccV2F_C4B_T2F	tl;
	//! top right
	ccV2F_C4B_T2F	tr;
} ccV2F_C4B_T2F_Quad;

//! 4 ccVertex3FTex2FColor4B
typedef struct _ccV3F_C4B_T2F_Quad
{
	//! top left
	ccV3F_C4B_T2F	tl;
	//! bottom left
	ccV3F_C4B_T2F	bl;
	//! top right
	ccV3F_C4B_T2F	tr;
	//! bottom right
	ccV3F_C4B_T2F	br;
} ccV3F_C4B_T2F_Quad;

//! 4 ccVertex2FTex2FColor4F Quad
typedef struct _ccV2F_C4F_T2F_Quad
{
	//! bottom left
	ccV2F_C4F_T2F	bl;
	//! bottom right
	ccV2F_C4F_T2F	br;
	//! top left
	ccV2F_C4F_T2F	tl;
	//! top right
	ccV2F_C4F_T2F	tr;
} ccV2F_C4F_T2F_Quad;

//! Blend Function used for textures
typedef struct _ccBlendFunc
{
	//! source blend function
	GLenum src;
	//! destination blend function
	GLenum dst;
} ccBlendFunc;

//! ccResolutionType
typedef NS_ENUM(NSUInteger, ccResolutionType)
{
	//! Unknonw resolution type
	kCCResolutionUnknown,

	//! iPhone resolution type
	kCCResolutioniPhone,
	//! RetinaDisplay resolution type
	kCCResolutioniPhoneRetinaDisplay,
	//! iPad resolution type
	kCCResolutioniPad,
	//! iPad Retina Display resolution type
	kCCResolutioniPadRetinaDisplay,

} ;

// XXX: If any of these enums are edited and/or reordered, udpate CCTexture2D.m
//! Vertical text alignment type
typedef NS_ENUM(NSUInteger, CCVerticalTextAlignment)
{
    kCCVerticalTextAlignmentTop,
    kCCVerticalTextAlignmentCenter,
    kCCVerticalTextAlignmentBottom,
} ;

