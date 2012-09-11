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
 *
 */

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import "ccMacros.h"
#ifdef __CC_PLATFORM_IOS

#import <unistd.h>

#import <sys/time.h>
// cocos2d imports
#import "CCDirectorIOS.h"
#import "CCScheduler.h"


#import "ccMacros.h"
#import "VAScene.h"
#import "VEGLProgram.h"
#import "ccGLStateCache.h"
#import "VALayer.h"

// support imports
#import "OpenGLInternal.h"
#import "CGPointExtension.h"
#import "TransformUtils.h"

#import "VGContext.h"

#import "VEDataSource.h"

#import <QuartzCore/QuartzCore.h>

@interface VEDisplayDirector ()
{
    CFTimeInterval	lastDisplayTime_;
    CADisplayLink *_displayLink;
}
@end

@implementation VEDisplayDirector

- (void)setAnimationInterval: (NSTimeInterval)interval
{
    if (animationInterval_ != interval)
    {
        animationInterval_ = interval;
        
        [self stopAnimation];
        [self startAnimation];
    }
}

- (void) startAnimation
{
    if(!isAnimating_)
    {
        gettimeofday( &lastUpdate_, NULL);
                
        if (!_displayLink)
        {
            _displayLink = [CADisplayLink displayLinkWithTarget: self
                                                       selector: @selector(drawScene)];
            [_displayLink setFrameInterval: 1];
            [_displayLink addToRunLoop: [NSRunLoop currentRunLoop]
                               forMode: NSDefaultRunLoopMode];
        }
        
        isAnimating_ = YES;
    }
}

- (void) stopAnimation
{
    if(isAnimating_)
    {
        CCLOG(@"cocos2d: animation stopped");
        //dispatch_suspend(_timer);
        [_displayLink setPaused: YES];
        isAnimating_ = NO;
    }
}

-(void) dealloc
{
    [self stopAnimation];
    
	[super dealloc];
}


@end

const char * CCDirectorIOSDispatchQueue = "com.veritas.cocos2d.dispatch-queue.director";

const char * CCDirectorIOSRunningQueue = "com.veritas.cocos2d.running-queue.director";

#endif // __CC_PLATFORM_IOS

