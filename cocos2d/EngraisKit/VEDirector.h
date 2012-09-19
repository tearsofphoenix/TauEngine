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

#import <GLKit/GLKit.h>
#import "ccMacros.h"


#pragma mark -  CCDirectorDelegate

@class VGContext;

/** @typedef ccDirectorProjection
 Possible OpenGL projections used by director
 */
typedef NS_ENUM(NSUInteger, ccDirectorProjection)
{
	/// sets a 2D projection (orthogonal projection).
	kCCDirectorProjection2D,

	/// sets a 3D projection with a fovy=60, znear=0.5f and zfar=1500.
	kCCDirectorProjection3D,

	/// it calls "updateProjection" on the projection delegate.
	kCCDirectorProjectionCustom,

	/// Detault projection is 3D projection
	kCCDirectorProjectionDefault = kCCDirectorProjection3D,

} ;

@class VAScene;
@class VIView;

/**Class that creates and handle the main Window and manages how
and when to execute the Scenes.

 The CCDirector is also resposible for:
  - initializing the OpenGL ES context
  - setting the OpenGL pixel format (default on is RGB565)
  - setting the OpenGL buffer depth (default one is 0-bit)
  - setting the projection (default one is 3D)

 Since the CCDirector is a singleton, the standard way to use it is by calling:
  - [[VEDirector sharedDirector] methodName];

 The CCDirector also sets the default OpenGL context:
  - GL_TEXTURE_2D is enabled
  - GL_VERTEX_ARRAY is enabled
  - GL_COLOR_ARRAY is enabled
  - GL_TEXTURE_COORD_ARRAY is enabled
*/
@interface VEDirector : GLKViewController
{
    VGContext *_renderContext;
    
	/* projection used */
	ccDirectorProjection projection_;

	/* window size in points */
	CGSize	winSizeInPoints_;

	/* window size in pixels */
	CGSize	winSizeInPixels_;
        
	/*  OpenGLView. On iOS it is a copy of self.view */
	VIView		*view_;
}

/** Sets an OpenGL projection */
@property (nonatomic) ccDirectorProjection projection;

-(BOOL) enableRetinaDisplay:(BOOL)enabled;

/** returns a shared instance of the director */
+ (VEDirector *)sharedDirector;


#pragma mark Director - Stats

#pragma mark Director - Win Size
/** returns the size of the OpenGL view in points */
- (CGSize) winSize;

/** returns the size of the OpenGL view in pixels.
 On Mac winSize and winSizeInPixels return the same value.
 */
- (CGSize) winSizeInPixels;

/** changes the projection size */
-(void) reshapeProjection:(CGSize)newWindowSize;

/// XXX: missing description
-(float) getZEye;

#pragma mark Director - Memory Helper
/** enables/disables OpenGL depth test */
- (void) setDepthTest: (BOOL) on;

- (void)pushScene: (VAScene *)scene;

@end

// optimization. Should only be used to read it. Never to write it.
extern NSUInteger __ccNumberOfDraws;

extern NSTimeInterval CCDirectorCalculateMPF(struct timeval lastUpdate_);

