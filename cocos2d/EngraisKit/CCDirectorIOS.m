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
#import "CCTouchDelegateProtocol.h"
#import "CCTouchDispatcher.h"
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

#pragma mark -
#pragma mark Director - global variables (optimization)

CGFloat	__ccContentScaleFactor = 1;

#pragma mark -
#pragma mark Director

@interface CCDirector ()

- (void) setNextScene;
- (void) showStats;
- (void) calculateDeltaTime;

@end

@implementation CCDirector (iOSExtensionClassMethods)

-(CCTouchDispatcher*) touchDispatcher
{
	return nil;
}

-(void) setTouchDispatcher:(CCTouchDispatcher*)touchDispatcher
{
	//
}
@end



#pragma mark -
#pragma mark CCDirectorIOS

@interface CCDirectorIOS ()
{
@private
    CCScheduler *_scheduler;
}

@end

@implementation CCDirectorIOS

- (id) init
{
	if( (self=[super init]) )
    {
		__ccContentScaleFactor = 1;
		touchDispatcher_ = [[CCTouchDispatcher alloc] init];
        
		_dispatchQueue = dispatch_queue_create(CCDirectorIOSDispatchQueue, DISPATCH_QUEUE_CONCURRENT);
        _scheduler = [VEDataSource serviceByIdentity: CCScheduleServiceID];
	}
    
	return self;
}

- (void) dealloc
{
	[touchDispatcher_ release];
    
	[super dealloc];
}

//
// Draw the Scene
//
- (void) drawScene
{
	/* calculate "global" dt */
	[self calculateDeltaTime];
    
	VEGLView *openGLview = (VEGLView*)[self view];
    
	[EAGLContext setCurrentContext: [openGLview context]];
    
	/* tick before glClear: issue #533 */
	if( ! isPaused_ )
    {
        [_scheduler update: dt];
    }
    
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
	/* to avoid flickr, nextScene MUST be here: after tick and before draw.
	 XXX: Which bug is this one. It seems that it can't be reproduced with v0.9 */
	if( nextScene_ )
    {
		[self setNextScene];
    }
    
	VGContextSaveState(_renderContext);
    
	[runningScene_ visitWithContext: _renderContext];
        
    [self showStats];
    
	VGContextRestoreState(_renderContext);
    
	totalFrames_++;
    
	[openGLview swapBuffers];
    
    secondsPerFrame_ = CCDirectorCalculateMPF(lastUpdate_);
}

-(void) setProjection:(ccDirectorProjection)projection
{
	CGSize size = winSizeInPixels_;
	CGSize sizePoint = winSizeInPoints_;
    
	glViewport(0, 0, size.width, size.height );
    
    VGContext *currentContext = VGContextGetCurrentContext();
    
	switch (projection)
    {
		case kCCDirectorProjection2D:
        {
			VGContextMatrixMode(currentContext, GL_PROJECTION_MATRIX);
			VGContextLoadIdentity(currentContext);
            
			GLKMatrix4 orthoMatrix = GLKMatrix4MakeOrtho(0, size.width / CC_CONTENT_SCALE_FACTOR(), 0,
                                                         size.height / CC_CONTENT_SCALE_FACTOR(), -1024, 1024 );
			VGContextConcatCTM(currentContext, orthoMatrix );
            
			VGContextMatrixMode(currentContext, GL_MODELVIEW_MATRIX);
			VGContextLoadIdentity(currentContext);
			break;
        }
		case kCCDirectorProjection3D:
		{
			float zeye = [self getZEye];
            
			GLKMatrix4 matrixPerspective, matrixLookup;
            
			VGContextMatrixMode(currentContext, GL_PROJECTION_MATRIX);
			VGContextLoadIdentity(currentContext);
            
			// issue #1334
            matrixPerspective = GLKMatrix4MakePerspective(60, (GLfloat)size.width/size.height, 0.1f, zeye*2);
            
			VGContextConcatCTM(currentContext, matrixPerspective);
            
			VGContextMatrixMode(currentContext, GL_MODELVIEW_MATRIX);
			VGContextLoadIdentity(currentContext);
            
            matrixLookup = GLKMatrix4MakeLookAt(sizePoint.width/2, sizePoint.height/2, zeye,
                                                sizePoint.width/2, sizePoint.height/2, 0,
                                                0, 1, 0);
			VGContextConcatCTM(currentContext, matrixLookup);
            
			break;
		}
            
		case kCCDirectorProjectionCustom:
        {
			if( [delegate_ respondsToSelector:@selector(updateProjection)] )
				[delegate_ updateProjection];
			break;
        }
		default:
			CCLOG(@"cocos2d: Director: unrecognized projection");
			break;
	}
    
	projection_ = projection;
    
	CCSetProjectionMatrixDirty();
}

#pragma mark Director - TouchDispatcher

-(CCTouchDispatcher*) touchDispatcher
{
	return touchDispatcher_;
}

-(void) setTouchDispatcher:(CCTouchDispatcher*)touchDispatcher
{
	if( touchDispatcher != touchDispatcher_ )
    {
		[touchDispatcher_ release];
		touchDispatcher_ = [touchDispatcher retain];
	}
}

#pragma mark Director - Retina Display

-(CGFloat) contentScaleFactor
{
	return __ccContentScaleFactor;
}

-(void) setContentScaleFactor:(CGFloat)scaleFactor
{
	if( scaleFactor != __ccContentScaleFactor )
    {
		__ccContentScaleFactor = scaleFactor;
		winSizeInPixels_ = CGSizeMake( winSizeInPoints_.width * scaleFactor, winSizeInPoints_.height * scaleFactor );
        
        [view_ setContentScaleFactor: __ccContentScaleFactor];
        
		// update projection
		[self setProjection: projection_];
	}
}

-(BOOL) enableRetinaDisplay:(BOOL)enabled
{
	// Already enabled ?
	if( enabled && __ccContentScaleFactor == 2 )
		return YES;
    
	// Already disabled
	if( ! enabled && __ccContentScaleFactor == 1 )
		return YES;
    
	// SD device
	if ([[UIScreen mainScreen] scale] == 1.0)
		return NO;
    
	float newScale = enabled ? 2 : 1;
    
	[self setContentScaleFactor:newScale];
    
	// Load Hi-Res FPS label
	[self createStatsLabel];
    
	return YES;
}

// overriden, don't call super
-(void) reshapeProjection:(CGSize)size
{
	winSizeInPoints_ = [view_ bounds].size;
	winSizeInPixels_ = CGSizeMake(winSizeInPoints_.width * __ccContentScaleFactor, winSizeInPoints_.height *__ccContentScaleFactor);
    
	[self setProjection:projection_];
}

#pragma mark Director Point Convertion

-(CGPoint)convertToGL:(CGPoint)uiPoint
{
	CGSize s = winSizeInPoints_;
	float newY = s.height - uiPoint.y;
    
	return ccp( uiPoint.x, newY );
}

-(CGPoint)convertToUI:(CGPoint)glPoint
{
	CGSize winSize = winSizeInPoints_;
	int oppositeY = winSize.height - glPoint.y;
    
	return ccp(glPoint.x, oppositeY);
}

-(void) end
{
	// don't release the event handlers
	// They are needed in case the director is run again
	[touchDispatcher_ removeAllDelegates];
    
	[super end];
}

#pragma mark Director - UIViewController delegate


-(void) setView:(VEGLView *)view
{
	if( view != view_)
    {
		[super setView:view];
        
		if( view )
        {
			// set size
			winSizeInPixels_ = CGSizeMake(winSizeInPoints_.width * __ccContentScaleFactor, winSizeInPoints_.height *__ccContentScaleFactor);
            
			if( __ccContentScaleFactor != 1 )
            {
                [view_ setContentScaleFactor: __ccContentScaleFactor];
            }
            
			[view setTouchDelegate: touchDispatcher_];
			[touchDispatcher_ setCanDispatchEvents: YES];
		}
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	BOOL ret =YES;
	if( [delegate_ respondsToSelector: _cmd] )
    {
		ret = [delegate_ shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
    
	return ret;
}

-(void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                               duration: (NSTimeInterval)duration
{
	// do something ?
}


-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self startAnimation];
}

-(void) viewDidDisappear:(BOOL)animated
{
	[self stopAnimation];
    
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
	// Release any cached data, images, etc that aren't in use.
	[super purgeCachedData];
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
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
