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
//#import <GLKit/GLKit.h>
#import "ccTypes.h"

@class GLKEffectPropertyTexture;
#pragma mark - CCRGBAProtocol

@protocol CCRGBAProtocol <NSObject>

@property (nonatomic) GLKVector4 color;

@property (nonatomic) GLfloat opacity;

@optional

@property (nonatomic, getter = isOpacityModifyRGB) BOOL opacityModifyRGB;

@end

#pragma mark -
#pragma mark CCBlendProtocol

@protocol CCBlendProtocol <NSObject>

@property (nonatomic) ccBlendFunc blendFunc;

@end


#pragma mark -
#pragma mark CCTextureProtocol

/** CCNode objects that uses a Texture2D to render the images.
 The texture can have a blending function.
 If the texture has alpha premultiplied the default blending function is:
    src=GL_ONE dst= GL_ONE_MINUS_SRC_ALPHA
 else
	src=GL_SRC_ALPHA dst= GL_ONE_MINUS_SRC_ALPHA
 But you can change the blending funtion at any time.
 @since v0.8.0
 */
@protocol CCTextureProtocol <CCBlendProtocol>

@property (nonatomic, retain) GLKEffectPropertyTexture *texture;

@end

#pragma mark - CCLabelProtocol

@protocol CCLabelProtocol <NSObject>

@property (nonatomic, copy) NSString *string;

@end


#pragma mark -  CCDirectorDelegate

@protocol CCDirectorDelegate <NSObject>

@optional
/** Called by CCDirector when the porjection is updated, and "custom" projection is used */
-(void) updateProjection;

#ifdef __CC_PLATFORM_IOS
/** Returns a Boolean value indicating whether the CCDirector supports the specified orientation. Default value is YES (supports all possible orientations) */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

#endif // __CC_PLATFORM_IOS

@end
