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
 *
 */



#import "ccMacros.h"

#ifdef __CC_PLATFORM_IOS

#import "Platforms/iOS/CCTouchDelegateProtocol.h"		// Touches only supported on iOS
#elif defined(__CC_PLATFORM_MAC)
#import "Platforms/Mac/CCEventDispatcher.h"
#endif

#import "CCProtocols.h"
#import "CCNode.h"

#pragma mark -
#pragma mark CCLayer

/** CCLayer is a subclass of CCNode that implements the CCTouchEventsDelegate protocol.
 
 All features from CCNode are valid, plus the following new features:
 - It can receive iPhone Touches
 - It can receive Accelerometer input
 */

@interface CCLayer : CCNode <CCStandardTouchDelegate, CCTargetedTouchDelegate, CCRGBAProtocol, CCBlendProtocol>
{
	ccColor4B	color_;
	ccVertex2F	squareVertices_[4];
	ccColor4F	squareColors_[4];
    
	ccBlendFunc	_blendFunc;
    
	BOOL _isUserInteractionEnabled;
}

+ (id)layer;

/** If isTouchEnabled, this method is called onEnter. Override it to change the
 way CCLayer receives touch events.
 ( Default: [touchDispatcher addStandardDelegate:self priority:0] )
 Example:
 -(void) registerWithTouchDispatcher
 {
 [touchDispatcher addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
 }
 
 Valid only on iOS. Not valid on Mac.
 
 @since v0.8.0
 */
-(void) registerWithTouchDispatcher;

/** whether or not it will receive Touch events.
 You can enable / disable touch events with this property.
 Only the touches of this node will be affected. This "method" is not propagated to its children.
 
 Valid on iOS and Mac OS X v10.6 and later.
 
 @since v0.8.1
 */
@property(nonatomic,getter=isUserInteractionEnabled) BOOL userInteractionEnabled;

+ (void)animateWithDuration:(NSTimeInterval)duration
                      delay: (NSTimeInterval)delay
                    options:(UIViewAnimationOptions)options
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion ;

+ (void)animateWithDuration: (NSTimeInterval)duration
                 animations: (void (^)(void))animations
                 completion: (void (^)(BOOL finished))completion; // delay = 0.0, options = 0

+ (void)animateWithDuration: (NSTimeInterval)duration
                 animations: (void (^)(void))animations ; // delay = 0.0, options = 0, completion = NULL

+ (void)transitionWithLayer: (CCLayer *)layer
                   duration: (NSTimeInterval)duration
                    options: (UIViewAnimationOptions)options
                 animations: (void (^)(void))animations
                 completion: (void (^)(BOOL finished))completion ;

+ (void)transitionFromLayer: (CCLayer *)fromView
                    toLayer: (CCLayer *)toView
                   duration: (NSTimeInterval)duration
                    options: (UIViewAnimationOptions)options
                 completion: (void (^)(BOOL finished))completion; // toView added to fromView.superview, fromView removed from its superview


@end

#pragma mark -
#pragma mark CCGradientLayer

/** CCGradientLayer is a subclass of CCLayer that draws gradients across
 the background.
 
 All features from CCLayer are valid, plus the following new features:
 - direction
 - final color
 - interpolation mode
 
 Color is interpolated between the startColor and endColor along the given
 vector (starting at the origin, ending at the terminus).  If no vector is
 supplied, it defaults to (0, -1) -- a fade from top to bottom.
 
 If 'compressedInterpolation' is disabled, you will not see either the start or end color for
 non-cardinal vectors; a smooth gradient implying both end points will be still
 be drawn, however.
 
 If ' compressedInterpolation' is enabled (default mode) you will see both the start and end colors of the gradient.
 
 @since v0.99.5
 */
@interface CCGradientLayer : CCLayer
{
	ccColor4B endColor_;
	GLubyte startOpacity_;
	GLubyte endOpacity_;
	CGPoint vector_;
	BOOL	compressedInterpolation_;
}

/** Initializes the CCLayer with a gradient between start and end. */
- (id) initWithColor: (ccColor4B) start fadingTo: (ccColor4B) end;
/** Initializes the CCLayer with a gradient between start and end in the direction of v. */
- (id) initWithColor: (ccColor4B) start fadingTo: (ccColor4B) end alongVector: (CGPoint) v;

/** The starting color. */
@property (nonatomic) ccColor4B startColor;
/** The ending color. */
@property (nonatomic) ccColor4B endColor;
/** The starting opacity. */
@property (nonatomic) GLubyte startOpacity;
/** The ending color. */
@property (nonatomic) GLubyte endOpacity;
/** The vector along which to fade color. */
@property (nonatomic) CGPoint vector;
/** Whether or not the interpolation will be compressed in order to display all the colors of the gradient both in canonical and non canonical vectors
 Default: YES
 */
@property (nonatomic) BOOL compressedInterpolation;

@end

#pragma mark - CCMultiplexLayer

/** CCMultiplexLayer is a CCLayer with the ability to multiplex its children.
 Features:
 - It supports one or more children
 - Only one children will be active a time
 */
@interface CCMultiplexLayer : CCLayer
{
	unsigned int enabledLayer_;
	NSMutableArray *layers_;
}

/** initializes a MultiplexLayer with one or more layers using a variable argument list. */
-(id) initWithLayers: (NSArray*) layers;
/** switches to a certain layer indexed by n.
 The current (old) layer will be removed from its parent with 'cleanup:YES'.
 */
-(void) switchTo: (unsigned int) n;
/** release the current layer and switches to another layer indexed by n.
 The current (old) layer will be removed from its parent with 'cleanup:YES'.
 */
-(void) switchToAndReleaseMe: (unsigned int) n;
@end

