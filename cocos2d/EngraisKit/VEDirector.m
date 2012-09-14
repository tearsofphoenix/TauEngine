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

#import "VEDirector.h"
#import "VGContext.h"

#import "ccMacros.h"

#import "VAScene.h"

#import "VALayer.h"
#import "ccGLStateCache.h"

// support imports

#import "OpenGLInternal.h"
#import "CGPointExtension.h"


#import "VEDataSource.h"
#import "CCScheduler.h"
#import "VALayer+Private.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - Director - global variables (optimization)

// XXX it shoul be a Director ivar. Move it there once support for multiple directors is added
NSUInteger	__ccNumberOfDraws = 0;

#define kDefaultFPS		60.0	// 60 frames per second



@interface VEDirector ()
{
@private
    CCScheduler *_scheduler;
    EAGLContext *_context;
}

- (void) setNextScene;

@end

@implementation VEDirector

@synthesize runningScene = runningScene_;

// singleton stuff
//
static VEDirector *_sharedDirector = nil;

+ (VEDirector *)sharedDirector
{
	if (!_sharedDirector)
    {
        _sharedDirector = [[self alloc] init];
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
        
		scenesStack_ = [[NSMutableArray alloc] initWithCapacity:10];
        
		// Set default projection (3D)
		projection_ = kCCDirectorProjectionDefault;
        
		winSizeInPixels_ = winSizeInPoints_ = CGSizeZero;
        
        _renderContext = [[VGContext alloc] init];
        
        __ccContentScaleFactor = 1;
        
        _scheduler = [VEDataSource serviceByIdentity: CCScheduleServiceID];
        _context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
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
	[scenesStack_ release];
    
	_sharedDirector = nil;
    
	[super dealloc];
}

-(void) setGLDefaultValues
{
	// This method SHOULD be called only after view_ was initialized
	NSAssert( view_, @"view_ must be initialized");
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
	[self setProjection: projection_];
    
	// set other opengl default values
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
}

#pragma mark Director - Scene OpenGL Helper

@synthesize projection = projection_;

-(float) getZEye
{
	return ( winSizeInPixels_.height / 1.1566f / CC_CONTENT_SCALE_FACTOR() );
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

#pragma mark Director Scene Landscape

-(CGSize)winSize
{
	return winSizeInPoints_;
}

-(CGSize)winSizeInPixels
{
	return winSizeInPixels_;
}

- (void)viewDidLayoutSubviews
{
    CGSize size = [[self view] bounds].size;
    [self reshapeProjection: size];
}

#pragma mark Director Scene Management

-(void) replaceScene: (VAScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
    
	NSUInteger index = [scenesStack_ count];
    
	sendCleanupToScene_ = YES;
	[scenesStack_ replaceObjectAtIndex:index-1 withObject:scene];
	nextScene_ = scene;	// nextScene_ is a weak ref
}

- (void) pushScene: (VAScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
    
	sendCleanupToScene_ = NO;
    
	[scenesStack_ addObject: scene];
	nextScene_ = scene;	// nextScene_ is a weak ref
}

-(void) setNextScene
{
	[runningScene_ release];
    
	runningScene_ = [nextScene_ retain];
	nextScene_ = nil;
}

NSTimeInterval CCDirectorCalculateMPF(struct timeval lastUpdate_)
{
	struct timeval now;
	gettimeofday( &now, NULL);
    
	return (now.tv_sec - lastUpdate_.tv_sec) + (now.tv_usec - lastUpdate_.tv_usec) / 1000000.0f;
}

#pragma mark -
#pragma mark Director - global variables (optimization)

CGFloat	__ccContentScaleFactor = 1;

//
// Draw the Scene
//
- (void)glkView: (GLKView *)view
     drawInRect: (CGRect)rect
{
	GLKView *openGLview = (GLKView*)[self view];
    
	[EAGLContext setCurrentContext: [openGLview context]];
    
	/* tick before glClear: issue #533 */
    [_scheduler update: 1.0 / [self framesPerSecond]];
    
    glClearColor(1, 1, 1, 1);
    
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
	/* to avoid flickr, nextScene MUST be here: after tick and before draw.
	 XXX: Which bug is this one. It seems that it can't be reproduced with v0.9 */
	if( nextScene_ )
    {
		[self setNextScene];
    }
    
    VALayer_renderInScene(runningScene_, runningScene_);
    
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
			break;
        }
		default:
        {
			CCLOG(@"cocos2d: Director: unrecognized projection");
			break;
        }
	}
    
	projection_ = projection;
    
	CCSetProjectionMatrixDirty();
}

#pragma mark Director - Retina Display

+ (CGFloat) contentScaleFactor
{
	return __ccContentScaleFactor;
}

- (void)setContentScaleFactor: (CGFloat)scaleFactor
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

#pragma mark Director - UIViewController delegate


-(void) viewDidLoad
{    
    [super viewDidLoad];
    
    view_ = (GLKView *)[self view];
    [view_ setContext: _context];
    
    // set size
    winSizeInPixels_ = winSizeInPoints_ = [view_ bounds].size;
        
    // it could be nil
    
    [self setGLDefaultValues];
    
    CHECK_GL_ERROR_DEBUG();
    // set size
    winSizeInPixels_ = CGSizeMake(winSizeInPoints_.width * __ccContentScaleFactor, winSizeInPoints_.height *__ccContentScaleFactor);
    
    [view_ setContentScaleFactor: __ccContentScaleFactor];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: view_];
    VALayer *responsibleLayer = [runningScene_ hitTest: [self convertToGL: location]];
    [responsibleLayer touchBegan: touch
                       withEvent: event];
    NSLog(@"in func: %s %@", __func__, responsibleLayer);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: view_];
    VALayer *responsibleLayer = [runningScene_ hitTest: [self convertToGL: location]];
    [responsibleLayer touchEnded: touch
                       withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: view_];
    VALayer *responsibleLayer = [runningScene_ hitTest: [self convertToGL: location]];
    [responsibleLayer touchMoved: touch
                       withEvent: event];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: view_];
    VALayer *responsibleLayer = [runningScene_ hitTest: [self convertToGL: location]];
    [responsibleLayer touchCancelled: touch
                           withEvent: event];
    
}

@end

