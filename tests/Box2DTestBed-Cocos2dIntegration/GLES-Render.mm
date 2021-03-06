/*
 * Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
 *
 * iPhone port by Simon Oliver - http://www.simonoliver.com - http://www.handcircus.com
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

//
// File modified for cocos2d integration
// http://www.cocos2d-iphone.org
//

#import "cocos2d.h"

#include "GLES-Render.h"

#include <cstdio>
#include <cstdarg>

#include <cstring>

GLESDebugDraw::GLESDebugDraw( float32 ratio )
: mRatio( ratio )
{
}

void GLESDebugDraw::DrawPolygon(const b2Vec2* old_vertices, int32 vertexCount, const b2Color& color)
{
    VGContext *context = VGContextGetCurrentContext();
    
	GLKVector2 vertices[vertexCount];
    
	for( int i=0;i<vertexCount;i++)
    {
		b2Vec2 tmp = old_vertices[i];
		tmp *= mRatio;
		vertices[i].x = tmp.x;
		vertices[i].y = tmp.y;
	}
    
    VGContextSaveState(context);
    
    VGContextMatrixMode(context, GL_MODELVIEW_MATRIX);
    VGContextScaleCTM(context, 10, 10, 1);
    
    VGContextSetFillColor(context, GLKVector4Make(color.r, color.g, color.b, 1));
    VGContextDrawVertices(context, vertices, vertexCount, GL_LINE_LOOP);
    
    VGContextRestoreState(context);
    
	CC_INCREMENT_GL_DRAWS(1);
    
	CHECK_GL_ERROR_DEBUG();
}

void GLESDebugDraw::DrawSolidPolygon(const b2Vec2* old_vertices, int32 vertexCount, const b2Color& color)
{
    
    VGContext *context = VGContextGetCurrentContext();
    
	GLKVector2 vertices[vertexCount];
    
	for( int i=0;i<vertexCount;i++)
    {
		b2Vec2 tmp = old_vertices[i];
		tmp = old_vertices[i];
		tmp *= mRatio;
		vertices[i].x = tmp.x;
		vertices[i].y = tmp.y;
	}
    
    VGContextSaveState(context);
    
    VGContextMatrixMode(context, GL_MODELVIEW_MATRIX);
    VGContextScaleCTM(context, 10, 10, 1);

    VGContextSetFillColor(context, GLKVector4Make(color.r * 0.5, color.g * 0.5, color.b * 0.5, 0.5));
    VGContextDrawVertices(context, vertices, vertexCount, GL_TRIANGLE_FAN);
    
    VGContextSetFillColor(context, GLKVector4Make(color.r, color.g, color.b, 1.0));
    VGContextDrawVertices(context, vertices, vertexCount, GL_LINE_LOOP);

    VGContextRestoreState(context);
    
	CC_INCREMENT_GL_DRAWS(2);
    
	CHECK_GL_ERROR_DEBUG();
}

void GLESDebugDraw::DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color)
{
    VGContext *context = VGContextGetCurrentContext();
    
	const float32 k_segments = 16.0f;
	int vertexCount=16;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
    
	GLfloat				glVertices[vertexCount*2];
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		glVertices[i*2]=v.x * mRatio;
		glVertices[i*2+1]=v.y * mRatio;
		theta += k_increment;
	}
    
    VGContextSaveState(context);
    
    VGContextMatrixMode(context, GL_MODELVIEW_MATRIX);
    VGContextScaleCTM(context, 10, 10, 1);

    VGContextSetFillColor(context, GLKVector4Make(color.r, color.g, color.b, 1.0));
    
    VGContextDrawVertices(context, glVertices, vertexCount, GL_LINE_LOOP);

    VGContextRestoreState(context);
    
	CC_INCREMENT_GL_DRAWS(1);
    
	CHECK_GL_ERROR_DEBUG();
}

void GLESDebugDraw::DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color)
{
    VGContext *context = VGContextGetCurrentContext();
    
	const float32 k_segments = 16.0f;
	int vertexCount=16;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
    
	GLfloat				glVertices[vertexCount*2];
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		glVertices[i*2]=v.x * mRatio;
		glVertices[i*2+1]=v.y * mRatio;
		theta += k_increment;
	}
    
    VGContextSaveState(context);
    
    VGContextMatrixMode(context, GL_MODELVIEW_MATRIX);
    VGContextScaleCTM(context, 10, 10, 1);

    VGContextSetFillColor(context, GLKVector4Make(color.r * 0.5, color.g * 0.5, color.b * 0.5, 0.5));
    VGContextDrawVertices(context, glVertices, vertexCount, GL_TRIANGLE_FAN);
    
    VGContextSetFillColor(context, GLKVector4Make(color.r, color.g, color.b, 1.0));
    VGContextDrawVertices(context, glVertices, vertexCount, GL_LINE_LOOP);
    
    VGContextRestoreState(context);
    
	// Draw the axis line
	DrawSegment(center,center+radius*axis,color);

    
	CC_INCREMENT_GL_DRAWS(2);
    
	CHECK_GL_ERROR_DEBUG();
}

void GLESDebugDraw::DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color)
{
    VGContext *context = VGContextGetCurrentContext();

    VGContextSaveState(context);
    
    VGContextMatrixMode(context, GL_MODELVIEW_MATRIX);
    VGContextScaleCTM(context, 10, 10, 1);
    
    VGContextSetFillColor(context, GLKVector4Make(color.r, color.g, color.b, 1.0));
    
	GLfloat				glVertices[] =
    {
		p1.x * mRatio, p1.y * mRatio,
		p2.x * mRatio, p2.y * mRatio
	};
    
    VGContextDrawVertices(context, glVertices, 2, GL_LINES);
	
    VGContextRestoreState(context);
    
	CC_INCREMENT_GL_DRAWS(1);
    
	CHECK_GL_ERROR_DEBUG();
}

void GLESDebugDraw::DrawTransform(const b2Transform& xf)
{
	b2Vec2 p1 = xf.p, p2;
	const float32 k_axisScale = 0.4f;
	p2 = p1 + k_axisScale * xf.q.GetXAxis();
	DrawSegment(p1, p2, b2Color(1,0,0));
    
	p2 = p1 + k_axisScale * xf.q.GetYAxis();
	DrawSegment(p1,p2,b2Color(0,1,0));
}

void GLESDebugDraw::DrawPoint(const b2Vec2& p, float32 size, const b2Color& color)
{
    VGContext *context = VGContextGetCurrentContext();
    
    VGContextSaveState(context);
    
    VGContextMatrixMode(context, GL_MODELVIEW_MATRIX);
    VGContextScaleCTM(context, 10, 10, 1);

    VGContextSetFillColor(context, GLKVector4Make(color.r, color.g, color.b, 1.0));
    
	GLfloat				glVertices[] =
    {
		p.x * mRatio, p.y * mRatio
	};
    
    VGContextDrawVertices(context, glVertices, 1, GL_POINTS);
    VGContextRestoreState(context);
    
	CC_INCREMENT_GL_DRAWS(1);
    
	CHECK_GL_ERROR_DEBUG();
}

void GLESDebugDraw::DrawString(int x, int y, const char *string, ...)
{
	//	NSLog(@"DrawString: unsupported: %s", string);
	//printf(string);
	/* Unsupported as yet. Could replace with bitmap font renderer at a later date */
}

void GLESDebugDraw::DrawAABB(b2AABB* aabb, const b2Color& color)
{
    VGContext *context = VGContextGetCurrentContext();

    VGContextSaveState(context);
    
    VGContextMatrixMode(context, GL_MODELVIEW_MATRIX);
    VGContextScaleCTM(context, 10, 10, 1);

    VGContextSetFillColor(context, GLKVector4Make(color.r, color.g, color.b, 1.0));
    
    
	GLfloat				glVertices[] = {
		aabb->lowerBound.x * mRatio, aabb->lowerBound.y * mRatio,
		aabb->upperBound.x * mRatio, aabb->lowerBound.y * mRatio,
		aabb->upperBound.x * mRatio, aabb->upperBound.y * mRatio,
		aabb->lowerBound.x * mRatio, aabb->upperBound.y * mRatio
	};
    
    VGContextDrawVertices(context, glVertices, 8, GL_LINE_LOOP);
    
    VGContextRestoreState(context);
    
	CC_INCREMENT_GL_DRAWS(1);
    
	CHECK_GL_ERROR_DEBUG();
}
