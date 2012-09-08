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
        
        if (!_timer)
        {
            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _dispatchQueue);
            NSTimeInterval interval = animationInterval_ * NSEC_PER_SEC;
            dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, interval), interval, 0);
            __block id fakeSelf = self;
            dispatch_source_set_event_handler(_timer, (^
                                                       {
                                                           [fakeSelf drawScene];
                                                       }));
        }
        
        dispatch_resume(_timer);
        isAnimating_ = YES;
    }
}

- (void) stopAnimation
{
    if(isAnimating_)
    {
        CCLOG(@"cocos2d: animation stopped");
        dispatch_suspend(_timer);
        
        isAnimating_ = NO;
    }
}

// Overriden in order to use a more stable delta time
- (void)calculateDeltaTime
{
    // New delta time. Re-fixed issue #1277
    if( nextDeltaTimeZero_ || lastDisplayTime_==0 )
    {
        dt = 0;
        nextDeltaTimeZero_ = NO;
    } else
    {
        dt = [NSDate timeIntervalSinceReferenceDate] - lastDisplayTime_;
        dt = MAX(0,dt);
    }
    // Store this timestamp for next time
    lastDisplayTime_ = [NSDate timeIntervalSinceReferenceDate];
    
	// needed for SPF
    gettimeofday( &lastUpdate_, NULL);
    
#ifdef DEBUG
	// If we are debugging our code, prevent big delta time
	if( dt > 0.2f )
    {
		dt = 1/60.0f;
    }
#endif
}

-(void) dealloc
{
    [self stopAnimation];
    dispatch_release(_timer);
    _timer = NULL;
    
	[super dealloc];
}


@end

const char * CCDirectorIOSDispatchQueue = "com.veritas.cocos2d.dispatch-queue.director";

const char * CCDirectorIOSRunningQueue = "com.veritas.cocos2d.running-queue.director";

#endif // __CC_PLATFORM_IOS

