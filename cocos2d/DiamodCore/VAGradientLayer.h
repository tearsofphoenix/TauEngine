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

/* The array of CGColorRef objects defining the color of each gradient
 * stop. Defaults to nil. Animatable. */

@property(copy) NSArray *colors;

/* An optional array of NSNumber objects defining the location of each
 * gradient stop as a value in the range [0,1]. The values must be
 * monotonically increasing. If a nil array is given, the stops are
 * assumed to spread uniformly across the [0,1] range. When rendered,
 * the colors are mapped to the output colorspace before being
 * interpolated. Defaults to nil. Animatable. */

@property(copy) NSArray *locations;

/* The start and end points of the gradient when drawn into the layer's
 * coordinate space. The start point corresponds to the first gradient
 * stop, the end point to the last gradient stop. Both points are
 * defined in a unit coordinate space that is then mapped to the
 * layer's bounds rectangle when drawn. (I.e. [0,0] is the bottom-left
 * corner of the layer, [1,1] is the top-right corner.) The default values
 * are [.5,0] and [.5,1] respectively. Both are animatable. */

@property CGPoint startPoint, endPoint;

@end


