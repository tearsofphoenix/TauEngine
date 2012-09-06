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

#import <CoreGraphics/CGGeometry.h>	// CGPoint

#import <GLKit/GLKit.h>

static const GLKVector4 ccWHITE = {{1,1,1, 1}};

static const GLKVector4 ccYELLOW = {{1,1,0, 1}};

static const GLKVector4 ccBLUE = {{0,0,1, 1}};

static const GLKVector4 ccGREEN = {{0,1,0, 1}};

static const GLKVector4 ccRED = {{1,0,0, 1}};

static const GLKVector4 ccMAGENTA = {{1,0,1, 1}};

static const GLKVector4 ccBLACK = {{0,0,0, 1}};

static const GLKVector4 ccORANGE = {{1, 0.5,0, 1}};

static const GLKVector4 ccGRAY = {{0.5, 0.5, 0.5, 1}};

/** A texcoord composed of 2 floats: u, y
 @since v0.8
 */
typedef struct _ccTex2F
{
	 GLfloat u;
	 GLfloat v;
} ccTex2F;


//! Point Sprite component
typedef struct _ccPointSprite
{
	GLKVector2	pos;		// 8 bytes
	GLKVector4	color;		// 4 bytes
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
	GLKVector4		colors;
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
	GLKVector4		colors;				// 4 bytes
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

// XXX: If any of these enums are edited and/or reordered, udpate GLKEffectPropertyTexture.m
//! Vertical text alignment type
typedef NS_ENUM(NSUInteger, CCVerticalTextAlignment)
{
    kCCVerticalTextAlignmentTop,
    kCCVerticalTextAlignmentCenter,
    kCCVerticalTextAlignmentBottom,
} ;

