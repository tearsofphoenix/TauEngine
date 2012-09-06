/*
 
 ===== IMPORTANT =====
 
 This is sample code demonstrating API, technology or techniques in development.
 Although this sample code has been reviewed for technical accuracy, it is not
 final. Apple is supplying this information to help you plan for the adoption of
 the technologies and programming interfaces described herein. This information
 is subject to change, and software implemented based on this sample code should
 be tested with final operating system software and final documentation. Newer
 versions of this sample code may be provided with future seeds of the API or
 technology. For information about updates to this and other developer
 documentation, view the New & Updated sidebars in subsequent documentation
 seeds.
 
 =====================
 
 File: VEGLView.m
 Abstract: Convenience class that wraps the CAEAGLLayer from CoreAnimation into a
 UIView subclass.
 
 Version: 1.3
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2008 Apple Inc. All Rights Reserved.
 
 */

/*
 Modified for cocos2d project
 */

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.

#import "VEGLView.h"
#import "VAES2Renderer.h"

#import "OpenGLInternal.h"

@interface VEGLView (Private)

- (BOOL) setupSurfaceWithSharegroup:(EAGLSharegroup*)sharegroup;

@end

@implementation VEGLView

@synthesize surfaceSize = size_;

@synthesize touchDelegate = touchDelegate_;

- (id) initWithFrame: (CGRect)frame
{
	if((self = [super initWithFrame:frame]))
	{
		if( ! [self setupSurfaceWithSharegroup: nil] )
        {
			[self release];
			return nil;
		}
        
		CHECK_GL_ERROR_DEBUG();
        
	}
    
	return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	if( (self = [super initWithCoder:aDecoder]) )
    {
		size_ = [self bounds].size;
        
		if( ! [self setupSurfaceWithSharegroup: nil] )
        {
			[self release];
			return nil;
		}
        
		CHECK_GL_ERROR_DEBUG();
        
    }
    
    return self;
}

- (BOOL)setupSurfaceWithSharegroup: (EAGLSharegroup*)sharegroup
{
	renderer_ = [[VAES2Renderer alloc] initWithSharegroup: sharegroup
                                         withMultiSampling: NO
                                       withNumberOfSamples: 0];
    
    [self setContext: [renderer_ context]];
    
	CHECK_GL_ERROR_DEBUG();
    
	return YES;
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
    
	[renderer_ release];
	[super dealloc];
}

- (void) layoutSubviews
{
	[renderer_ resizeFromLayer: (CAEAGLLayer*)self.layer];
    
	size_ = [renderer_ backingSize];
}

- (void) swapBuffers
{
	// IMPORTANT:
	// - preconditions
	//	-> context_ MUST be the OpenGL context
	//	-> renderbuffer_ must be the the RENDER BUFFER
    BOOL multiSampling_ = NO;
    
	if (multiSampling_)
	{
		/* Resolve from msaaFramebuffer to resolveFramebuffer */
		//glDisable(GL_SCISSOR_TEST);
		glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, [renderer_ msaaFrameBuffer]);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, [renderer_ defaultFrameBuffer]);
		glResolveMultisampleFramebufferAPPLE();
	}
    
    BOOL depthFormat_ = NO;
    
    if (multiSampling_)
    {
        if (depthFormat_)
        {
            GLenum attachments[] = {GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT};
            glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, attachments);
        }
        else
        {
            GLenum attachments[] = {GL_COLOR_ATTACHMENT0};
            glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 1, attachments);
        }
        
        glBindRenderbuffer(GL_RENDERBUFFER, [renderer_ colorRenderBuffer]);
        
    }else if (depthFormat_ )
    {
        GLenum attachments[] = { GL_DEPTH_ATTACHMENT};
        glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, attachments);
    }
    
	if(![[self context] presentRenderbuffer:GL_RENDERBUFFER])
		CCLOG(@"cocos2d: Failed to swap renderbuffer in %s\n", __FUNCTION__);
    
	// We can safely re-bind the framebuffer here, since this will be the
	// 1st instruction of the new main loop
	if( multiSampling_ )
    {
		glBindFramebuffer(GL_FRAMEBUFFER, [renderer_ msaaFrameBuffer]);
    }
    
	CHECK_GL_ERROR_DEBUG();
}

#pragma mark VEGLView - Point conversion

- (CGPoint) convertPointFromViewToSurface:(CGPoint)point
{
	CGRect bounds = [self bounds];
    
	return CGPointMake((point.x - bounds.origin.x) / bounds.size.width * size_.width,
                       (point.y - bounds.origin.y) / bounds.size.height * size_.height);
}

- (CGRect) convertRectFromViewToSurface:(CGRect)rect
{
	CGRect bounds = [self bounds];
    
	return CGRectMake((rect.origin.x - bounds.origin.x) / bounds.size.width * size_.width,
                      (rect.origin.y - bounds.origin.y) / bounds.size.height * size_.height,
                      rect.size.width / bounds.size.width * size_.width,
                      rect.size.height / bounds.size.height * size_.height);
}

// Pass the touches to the superview
#pragma mark VEGLView - Touch Delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(touchDelegate_)
	{
		[touchDelegate_ touchesBegan: touches
                           withEvent: event];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(touchDelegate_)
	{
		[touchDelegate_ touchesMoved: touches
                           withEvent: event];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(touchDelegate_)
	{
		[touchDelegate_ touchesEnded: touches
                           withEvent: event];
	}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(touchDelegate_)
	{
		[touchDelegate_ touchesCancelled: touches
                               withEvent: event];
	}
}

@end
