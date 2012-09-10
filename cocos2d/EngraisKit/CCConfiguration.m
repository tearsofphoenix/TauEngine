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

#import "ccMacros.h"

#import <UIKit/UIKit.h>		// Needed for UIDevice


#import "CCConfiguration.h"
#import "ccMacros.h"
#import "ccConfig.h"
#import "OpenGLInternal.h"

static NSArray *_glExtensions = nil;

@implementation CCConfiguration

@synthesize maxTextureSize = maxTextureSize_, maxTextureUnits=maxTextureUnits_;
@synthesize supportsPVRTC = supportsPVRTC_;
@synthesize maxModelviewStackDepth = maxModelviewStackDepth_;
@synthesize supportsNPOT = supportsNPOT_;
@synthesize supportsBGRA8888 = supportsBGRA8888_;
@synthesize supportsDiscardFramebuffer = supportsDiscardFramebuffer_;
@synthesize supportsShareableVAO = supportsShareableVAO_;
@synthesize OSVersion = OSVersion_;

//
// singleton stuff
//
static CCConfiguration *_sharedConfiguration = nil;

+ (CCConfiguration *)sharedConfiguration
{
	if (!_sharedConfiguration)
		_sharedConfiguration = [[self alloc] init];

	return _sharedConfiguration;
}

+(id)alloc
{
	NSAssert(_sharedConfiguration == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

-(id) init
{
	if( (self=[super init]))
    {

		// Obtain iOS version
		OSVersion_ = 0;

		NSString *OSVer = [[UIDevice currentDevice] systemVersion];

		NSArray *arr = [OSVer componentsSeparatedByString:@"."];
		int idx = 0x01000000;
		for( NSString *str in arr )
        {
			int value = [str intValue];
			OSVersion_ += value * idx;
			idx = idx >> 8;
		}
		
        CCLOG(@"cocos2d: OS version: %@ (0x%08x)", OSVer, OSVersion_);

		CCLOG(@"cocos2d: GL_VENDOR:   %s", glGetString(GL_VENDOR) );
		CCLOG(@"cocos2d: GL_RENDERER: %s", glGetString ( GL_RENDERER   ) );
		CCLOG(@"cocos2d: GL_VERSION:  %s", glGetString ( GL_VERSION    ) );

        _glExtensions = [[[NSString stringWithUTF8String: (char *)glGetString(GL_EXTENSIONS)] componentsSeparatedByString: @" "] retain];

		glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize_);
		glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &maxTextureUnits_ );

        glGetIntegerv(GL_MAX_SAMPLES_APPLE, &maxSamplesAllowed_);

		supportsPVRTC_ = CCConfigurationSupportExtension(@"GL_IMG_texture_compression_pvrtc");

		supportsNPOT_ = YES;

		// It seems that somewhere between firmware iOS 3.0 and 4.2 Apple renamed
		// GL_IMG_... to GL_APPLE.... So we should check both names

		BOOL bgra8a = CCConfigurationSupportExtension(@"GL_IMG_texture_format_BGRA8888");
		BOOL bgra8b = CCConfigurationSupportExtension(@"GL_APPLE_texture_format_BGRA8888");
		supportsBGRA8888_ = bgra8a | bgra8b;
        
		supportsShareableVAO_ = CCConfigurationSupportExtension(@"GL_APPLE_vertex_array_object");

		
		supportsDiscardFramebuffer_ = CCConfigurationSupportExtension(@"GL_EXT_discard_framebuffer");

		CCLOG(@"cocos2d: GL_MAX_TEXTURE_SIZE: %d", maxTextureSize_);
		CCLOG(@"cocos2d: GL_MAX_TEXTURE_UNITS: %d", maxTextureUnits_);
		CCLOG(@"cocos2d: GL_MAX_SAMPLES: %d", maxSamplesAllowed_);
		CCLOG(@"cocos2d: GL supports PVRTC: %s", (supportsPVRTC_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: GL supports BGRA8888 textures: %s", (supportsBGRA8888_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: GL supports NPOT textures: %s", (supportsNPOT_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: GL supports discard_framebuffer: %s", (supportsDiscardFramebuffer_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: GL supports shareable VAO: %s", (supportsShareableVAO_ ? "YES" : "NO") );
		CCLOG(@"cocos2d: compiled with Profiling Support: %s", "NO");

	}

	CHECK_GL_ERROR_DEBUG();

	return self;
}

@end

BOOL CCConfigurationSupportExtension(NSString* extensionName)
{
    return [_glExtensions containsObject: extensionName];
}
