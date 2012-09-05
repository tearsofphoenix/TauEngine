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


/* Idea of decoupling Window from Director taken from OC3D project: http://code.google.com/p/oc3d/
 */

#import <unistd.h>
#import <sys/time.h>

#import "CCDirector.h"
#import "VEContext.h"

#import "ccMacros.h"

#import "CCScene.h"

#import "CCLayer.h"
#import "ccGLStateCache.h"
#import "CCShaderCache.h"

// support imports

#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"

#import "Platforms/iOS/CCDirectorIOS.h"
#import "CCGLView.h"


#pragma mark -
#pragma mark Director - global variables (optimization)

// XXX it shoul be a Director ivar. Move it there once support for multiple directors is added
NSUInteger	__ccNumberOfDraws = 0;

#define kDefaultFPS		60.0	// 60 frames per second

@interface CCDirector (Private)
-(void) setNextScene;
// shows the statistics
-(void) showStats;
// calculates delta time since last time it was called
-(void) calculateDeltaTime;

@end

@implementation CCDirector

@synthesize animationInterval = animationInterval_;
@synthesize runningScene = runningScene_;
@synthesize displayStats = displayStats_;
@synthesize nextDeltaTimeZero = nextDeltaTimeZero_;
@synthesize isPaused = isPaused_;
@synthesize isAnimating = isAnimating_;
@synthesize sendCleanupToScene = sendCleanupToScene_;
@synthesize notificationNode = notificationNode_;
@synthesize delegate = delegate_;
@synthesize totalFrames = totalFrames_;
@synthesize secondsPerFrame = secondsPerFrame_;

@synthesize dispatchQueue = _dispatchQueue;
@synthesize runningQueue = _runningQueue;
//
// singleton stuff
//
static CCDirector *_sharedDirector = nil;

+ (CCDirector *)sharedDirector
{
	if (!_sharedDirector)
    {

		//
		// Default Director is DisplayLink
		//
		if( [CCDirector class] == [self class] )
        {
			_sharedDirector = [[VEDisplayDirector alloc] init];
            
        }else
        {
			_sharedDirector = [[self alloc] init];
        }
	}

	return _sharedDirector;
}

+ (id)alloc
{
	NSAssert(_sharedDirector == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

- (id) init
{
	if( (self=[super init] ) )
    {

		CCLOG(@"cocos2d: Using Director Type:%@", [self class]);

		// scenes
		runningScene_ = nil;
		nextScene_ = nil;

		notificationNode_ = nil;

		oldAnimationInterval_ = animationInterval_ = 1.0 / kDefaultFPS;
		scenesStack_ = [[NSMutableArray alloc] initWithCapacity:10];

		// Set default projection (3D)
		projection_ = kCCDirectorProjectionDefault;

		// projection delegate if "Custom" projection is used
		delegate_ = nil;

		// FPS
		displayStats_ = NO;
		totalFrames_ = frames_ = 0;

		// paused ?
		isPaused_ = NO;        

		winSizeInPixels_ = winSizeInPoints_ = CGSizeZero;
        
        _renderContext = [[VEContext alloc] init];
	}

	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Size: %0.f x %0.f, view = %@>", [self class], self, winSizeInPoints_.width, winSizeInPoints_.height, view_];
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

	[runningScene_ release];
	[notificationNode_ release];
	[scenesStack_ release];

	[delegate_ release];

	_sharedDirector = nil;

	[super dealloc];
}

-(void) setGLDefaultValues
{
	// This method SHOULD be called only after view_ was initialized
	NSAssert( view_, @"view_ must be initialized");

    CCGLBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);

	[self setDepthTest: view_.depthFormat];
	[self setProjection: projection_];

	// set other opengl default values
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
}

//
// Draw the Scene
//
- (void) drawScene
{
	// Override me
}

-(void) calculateDeltaTime
{
	struct timeval now;

	if( gettimeofday( &now, NULL) != 0 ) {
		CCLOG(@"cocos2d: error in gettimeofday");
		dt = 0;
		return;
	}

	// new delta time
	if( nextDeltaTimeZero_ ) {
		dt = 0;
		nextDeltaTimeZero_ = NO;
	} else {
		dt = (now.tv_sec - lastUpdate_.tv_sec) + (now.tv_usec - lastUpdate_.tv_usec) / 1000000.0f;
		dt = MAX(0,dt);
	}

#ifdef DEBUG
	// If we are debugging our code, prevent big delta time
	if( dt > 0.2f )
		dt = 1/60.0f;
#endif

	lastUpdate_ = now;
}

#pragma mark Director - Memory Helper

-(void) purgeCachedData
{

}

#pragma mark Director - Scene OpenGL Helper

-(ccDirectorProjection) projection
{
	return projection_;
}

-(float) getZEye
{
	return ( winSizeInPixels_.height / 1.1566f / CC_CONTENT_SCALE_FACTOR() );
}

-(void) setProjection:(ccDirectorProjection)projection
{
	CCLOG(@"cocos2d: override me");
}

- (void) setDepthTest: (BOOL) on
{
	if (on)
    {
		glClearDepthf(1.0f);

		glEnable(GL_DEPTH_TEST);
		glDepthFunc(GL_LEQUAL);

	} else
		glDisable( GL_DEPTH_TEST );

	CHECK_GL_ERROR_DEBUG();
}

#pragma mark Director Integration with a UIKit view

-(void) setView: (CCGLView*)view
{
	if( view != view_ )
    {
	
#ifdef __CC_PLATFORM_IOS
		[super setView:view];
#endif
        CCShaderCacheInitialize();

		[view_ release];
		view_ = [view retain];

		// set size
		winSizeInPixels_ = winSizeInPoints_ = [view_ bounds].size;

		[self createStatsLabel];
		
		// it could be nil
		if( view )
        {
			[self setGLDefaultValues];
        }
        
		CHECK_GL_ERROR_DEBUG();
	}
}

-(CCGLView*) view
{
	return  view_;
}


#pragma mark Director Scene Landscape

-(CGPoint)convertToGL:(CGPoint)uiPoint
{
	CCLOG(@"CCDirector#convertToGL: OVERRIDE ME.");
	return CGPointZero;
}

-(CGPoint)convertToUI:(CGPoint)glPoint
{
	CCLOG(@"CCDirector#convertToUI: OVERRIDE ME.");
	return CGPointZero;
}

-(CGSize)winSize
{
	return winSizeInPoints_;
}

-(CGSize)winSizeInPixels
{
	return winSizeInPixels_;
}

-(void) reshapeProjection:(CGSize)newWindowSize
{
	winSizeInPixels_ = winSizeInPoints_ = newWindowSize;
	[self setProjection:projection_];
}

#pragma mark Director Scene Management

- (void)runWithScene:(CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");

	[self pushScene:scene];
	[self startAnimation];
}

-(void) replaceScene: (CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");

	NSUInteger index = [scenesStack_ count];

	sendCleanupToScene_ = YES;
	[scenesStack_ replaceObjectAtIndex:index-1 withObject:scene];
	nextScene_ = scene;	// nextScene_ is a weak ref
}

- (void) pushScene: (CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");

	sendCleanupToScene_ = NO;

	[scenesStack_ addObject: scene];
	nextScene_ = scene;	// nextScene_ is a weak ref
}

-(void) popScene
{
	NSAssert( runningScene_ != nil, @"A running Scene is needed");

	[scenesStack_ removeLastObject];
	NSUInteger c = [scenesStack_ count];

	if( c == 0 )
		[self end];
	else {
		sendCleanupToScene_ = YES;
		nextScene_ = [scenesStack_ objectAtIndex:c-1];
	}
}

-(void) popToRootScene
{
	NSAssert(runningScene_ != nil, @"A running Scene is needed");
	NSUInteger c = [scenesStack_ count];
	
    if (c == 1) {
        [scenesStack_ removeLastObject];
        [self end];
    } else {
        while (c > 1) {
			CCScene *current = [scenesStack_ lastObject];
			if( [current isRunning] )
				[current onExit];
			[current cleanup];
			
			[scenesStack_ removeLastObject];
			c--;
        }
		nextScene_ = [scenesStack_ lastObject];
		sendCleanupToScene_ = NO;
    }
}

-(void) end
{
	[runningScene_ onExit];
	[runningScene_ cleanup];
	[runningScene_ release];

	runningScene_ = nil;
	nextScene_ = nil;

	// remove all objects, but don't release it.
	// runWithScene might be executed after 'end'.
	[scenesStack_ removeAllObjects];

	[self stopAnimation];

	[delegate_ release];
	delegate_ = nil;

	[self setView:nil];
	
    
    CCShaderCacheFinalize();

	CCGLInvalidateStateCache();

	CHECK_GL_ERROR();
}

-(void) setNextScene
{
	BOOL runningIsTransition = NO;
	BOOL newIsTransition = NO;

	// If it is not a transition, call onExit/cleanup
	if( ! newIsTransition )
    {
		[runningScene_ onExit];

		// issue #709. the root node (scene) should receive the cleanup message too
		// otherwise it might be leaked.
		if( sendCleanupToScene_)
			[runningScene_ cleanup];
	}

	[runningScene_ release];

	runningScene_ = [nextScene_ retain];
	nextScene_ = nil;

	if( ! runningIsTransition )
    {
		[runningScene_ onEnter];
		[runningScene_ onEnterTransitionDidFinish];
	}
}

-(void) pause
{
	if( isPaused_ )
		return;

	oldAnimationInterval_ = animationInterval_;

	// when paused, don't consume CPU
	[self setAnimationInterval:1/4.0];
	
	[self willChangeValueForKey:@"isPaused"];
	isPaused_ = YES;
	[self didChangeValueForKey:@"isPaused"];
}

-(void) resume
{
	if( ! isPaused_ )
		return;

	[self setAnimationInterval: oldAnimationInterval_];

	if( gettimeofday( &lastUpdate_, NULL) != 0 ) {
		CCLOG(@"cocos2d: Director: Error in gettimeofday");
	}

	[self willChangeValueForKey:@"isPaused"];
	isPaused_ = NO;
	[self didChangeValueForKey:@"isPaused"];

	dt = 0;
}

- (void)startAnimation
{
	CCLOG(@"cocos2d: Director#startAnimation. Override me");
}

- (void)stopAnimation
{
	CCLOG(@"cocos2d: Director#stopAnimation. Override me");
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	CCLOG(@"cocos2d: Director#setAnimationInterval. Override me");
}


// display statistics
-(void) showStats
{
	frames_++;
	accumDt_ += dt;

	if( displayStats_ )
    {
		// Ms per Frame

		if( accumDt_ > CC_DIRECTOR_STATS_INTERVAL)
		{
            printf("spf: %.3f\n", secondsPerFrame_);
            
			frameRate_ = frames_/accumDt_;
			frames_ = 0;
			accumDt_ = 0;

            printf("fps: %.1f\n", frameRate_);
			
            printf("draws: %4d\n", (NSInteger)__ccNumberOfDraws);

		}
	}
	
	__ccNumberOfDraws = 0;
}

NSTimeInterval CCDirectorCalculateMPF(struct timeval lastUpdate_)
{
	struct timeval now;
	gettimeofday( &now, NULL);
    
	return (now.tv_sec - lastUpdate_.tv_sec) + (now.tv_usec - lastUpdate_.tv_usec) / 1000000.0f;
}

#pragma mark Director - Helper

-(void) createStatsLabel
{
}

@end

