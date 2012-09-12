//
//  VAGradientLayer.h
//  VUEngine
//
//  Created by LeixSnake on 9/11/12.
//
//

#import "VALayer.h"

/** CCGradientLayer is a subclass of VALayer that draws gradients across
 the background.
 
 All features from VALayer are valid, plus the following new features:
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
@interface VAGradientLayer : VALayer
{
	VGColor *endColor_;
	GLfloat startOpacity_;
	GLfloat endOpacity_;
	CGPoint vector_;
	BOOL	compressedInterpolation_;
}

/** Initializes the VALayer with a gradient between start and end. */
- (id) initWithColor: (VGColor *) start
            fadingTo: (VGColor *) end;
/** Initializes the VALayer with a gradient between start and end in the direction of v. */
- (id) initWithColor: (VGColor *) start
            fadingTo: (VGColor *) end
         alongVector: (CGPoint) v;

/** The starting color. */
@property (nonatomic, retain) VGColor * startColor;
/** The ending color. */
@property (nonatomic, retain) VGColor * endColor;
/** The starting opacity. */
@property (nonatomic) GLfloat startOpacity;
/** The ending color. */
@property (nonatomic) GLfloat endOpacity;
/** The vector along which to fade color. */
@property (nonatomic) CGPoint vector;
/** Whether or not the interpolation will be compressed in order to display all the colors of the gradient both in canonical and non canonical vectors
 Default: YES
 */
@property (nonatomic) BOOL compressedInterpolation;

@end


