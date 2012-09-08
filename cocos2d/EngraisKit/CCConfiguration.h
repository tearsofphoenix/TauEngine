/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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

#import <Foundation/Foundation.h>

/**
 CCConfiguration contains some openGL variables
 @since v0.99.0
 */
@interface CCConfiguration : NSObject
{
	GLint			maxTextureSize_;
	GLint			maxModelviewStackDepth_;
	BOOL			supportsPVRTC_;
	BOOL			supportsNPOT_;
	BOOL			supportsBGRA8888_;
	BOOL			supportsDiscardFramebuffer_;
	BOOL			supportsShareableVAO_;
	unsigned int	OSVersion_;
	GLint			maxSamplesAllowed_;
	GLint			maxTextureUnits_;
}

/** OpenGL Max texture size. */
@property (nonatomic, readonly) GLint maxTextureSize;

/** OpenGL Max Modelview Stack Depth. */
@property (nonatomic, readonly) GLint maxModelviewStackDepth;

/** returns the maximum texture units
 @since v2.0.0
 */
@property (nonatomic, readonly) GLint maxTextureUnits;

/** Whether or not the GPU supports NPOT (Non Power Of Two) textures.
 OpenGL ES 2.0 already supports NPOT (iOS).

 @since v0.99.2
 */
@property (nonatomic, readonly) BOOL supportsNPOT;

/** Whether or not PVR Texture Compressed is supported */
@property (nonatomic, readonly) BOOL supportsPVRTC;

/** Whether or not BGRA8888 textures are supported.

 @since v0.99.2
 */
@property (nonatomic, readonly) BOOL supportsBGRA8888;

/** Whether or not glDiscardFramebufferEXT is supported

 @since v0.99.2
 */
@property (nonatomic, readonly) BOOL supportsDiscardFramebuffer;

/** Whether or not shareable VAOs are supported.
 @since v2.0.0
 */
@property (nonatomic, readonly) BOOL supportsShareableVAO;

/** returns the OS version.
	- On iOS devices it returns the firmware version.
	- On Mac returns the OS version

 @since v0.99.5
 */
@property (nonatomic, readonly) unsigned int OSVersion;

/** returns a shared instance of the CCConfiguration */
+ (CCConfiguration *)sharedConfiguration;

@end

CF_EXPORT BOOL CCConfigurationSupportExtension(NSString* extensionName);

