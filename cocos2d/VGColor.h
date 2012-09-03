//
//  VGColor.h
//  VUEngine
//
//  Created by LeixSnake on 8/31/12.
//
//

#import <Foundation/Foundation.h>
#import "ccTypes.h"

@interface VGColor : NSObject <NSCoding, NSCopying>


// Convenience methods for creating autoreleased colors
+ (VGColor *)colorWithWhite: (float)white
                      alpha: (float)alpha;
+ (VGColor *)colorWithHue: (float)hue
               saturation: (float)saturation
               brightness: (float)brightness
                    alpha: (float)alpha;
+ (VGColor *)colorWithRed: (float)red
                    green: (float)green
                     blue: (float)blue
                    alpha: (float)alpha;

//+ (VGColor *)colorWithCGColor:(CGColorRef)cgColor;
//+ (VGColor *)colorWithPatternImage:(UIImage *)image;

// Initializers for creating non-autoreleased colors
- (VGColor *)initWithWhite: (float)white
                     alpha: (float)alpha;

- (VGColor *)initWithHue: (float)hue
              saturation: (float)saturation
              brightness: (float)brightness
                   alpha: (float)alpha;

- (VGColor *)initWithRed: (float)red
                   green: (float)green
                    blue: (float)blue
                   alpha: (float)alpha;

//- (VGColor *)initWithCGColor:(CGColorRef)cgColor;
//- (VGColor *)initWithPatternImage:(UIImage*)image;
//- (VGColor *)initWithCIColor:(CIColor *)ciColor ;

// Some convenience methods to create colors.  These colors will be as calibrated as possible.
// These colors are cached.
+ (VGColor *)blackColor;      // 0.0 white
+ (VGColor *)darkGrayColor;   // 0.333 white
+ (VGColor *)lightGrayColor;  // 0.667 white
+ (VGColor *)whiteColor;      // 1.0 white
+ (VGColor *)grayColor;       // 0.5 white
+ (VGColor *)redColor;        // 1.0, 0.0, 0.0 RGB
+ (VGColor *)greenColor;      // 0.0, 1.0, 0.0 RGB
+ (VGColor *)blueColor;       // 0.0, 0.0, 1.0 RGB
+ (VGColor *)cyanColor;       // 0.0, 1.0, 1.0 RGB
+ (VGColor *)yellowColor;     // 1.0, 1.0, 0.0 RGB
+ (VGColor *)magentaColor;    // 1.0, 0.0, 1.0 RGB
+ (VGColor *)orangeColor;     // 1.0, 0.5, 0.0 RGB
+ (VGColor *)purpleColor;     // 0.5, 0.0, 0.5 RGB
+ (VGColor *)brownColor;      // 0.6, 0.4, 0.2 RGB
+ (VGColor *)clearColor;      // 0.0 white, 0.0 alpha

// Set the color: Sets the fill and stroke colors in the current drawing context. Should be implemented by subclassers.
- (void)set;

// Set the fill or stroke colors individually. These should be implemented by subclassers.
- (void)setFill;
- (void)setStroke;

// Convenience methods for getting components.
// If the receiver is of a compatible color space, any non-NULL parameters are populated and 'YES' is returned. Otherwise, the parameters are left unchanged and 'NO' is returned.
- (BOOL)getWhite: (float *)white
           alpha: (float *)alpha ;
- (BOOL)getHue: (float *)hue
    saturation: (float *)saturation
    brightness: (float *)brightness
         alpha: (float *)alpha ;
- (BOOL)getRed: (float *)red
         green: (float *)green
          blue: (float *)blue
         alpha: (float *)alpha ;

// Returns a color in the same color space as the receiver with the specified alpha component.
- (VGColor *)colorWithAlphaComponent: (float)alpha;

- (GLKVector4)CCColor;

@end
