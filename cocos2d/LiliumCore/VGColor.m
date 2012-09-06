//
//  VGColor.m
//  VUEngine
//
//  Created by LeixSnake on 8/31/12.
//
//

#import "VGColor.h"
#import <GLKit/GLKit.h>

@interface VGColor ()
{
@private
    GLKVector4 _color;
}

@end

@implementation VGColor

+ (VGColor *)colorWithWhite: (float)white
                      alpha: (float)alpha
{
    return [[[self alloc] initWithWhite: white
                                  alpha: alpha] autorelease];
}

+ (VGColor *)colorWithHue: (float)hue
               saturation: (float)saturation
               brightness: (float)brightness
                    alpha: (float)alpha
{
    return [[[self alloc] initWithHue: hue
                           saturation: saturation
                           brightness: brightness
                                alpha: alpha] autorelease];
}

+ (VGColor *)colorWithRed: (float)red
                    green: (float)green
                     blue: (float)blue
                    alpha: (float)alpha
{
    return [[[self alloc] initWithRed: red
                                green: green
                                 blue: blue
                                alpha: alpha] autorelease];
}


- (VGColor *)initWithWhite: (float)white
                     alpha: (float)alpha
{
    if ((self = [super init]))
    {
        _color.r = 1.0 - white;
        _color.g = 1.0 - white;
        _color.b = 1.0 - white;
        _color.a = alpha;
    }
    return self;
}


- (VGColor *)initWithHue: (float)hue
              saturation: (float)saturation
              brightness: (float)brightness
                   alpha: (float)alpha
{
    return nil;
}

- (VGColor *)initWithRed: (float)red
                   green: (float)green
                    blue: (float)blue
                   alpha: (float)alpha
{
    if ((self = [super init]))
    {
        _color.r = red;
        _color.g = green;
        _color.b = blue;
        _color.a = alpha;
    }
    return self;
}

//- (VGColor *)initWithCGColor:(CGColorRef)cgColor;
//- (VGColor *)initWithPatternImage:(UIImage*)image;
//- (VGColor *)initWithCIColor:(CIColor *)ciColor ;

// Some convenience methods to create colors.  These colors will be as calibrated as possible.
// These colors are cached.

static VGColor *_blackCache = nil;

+ (VGColor *)blackColor      // 0.0 white
{
    if (!_blackCache)
    {
        _blackCache = [[self alloc] initWithWhite: 0.0
                                            alpha: 1.0];
    }
    return _blackCache;
}

static VGColor *_darkGrayColorCache = nil;

+ (VGColor *)darkGrayColor   // 0.333 white
{
    if (!_darkGrayColorCache)
    {
        _darkGrayColorCache = [[self alloc] initWithWhite: 0.333
                                                    alpha: 1.0];
    }
    return _darkGrayColorCache;
}

static VGColor *_lightGrayColorCache = nil;

+ (VGColor *)lightGrayColor  // 0.667 white
{
    if (!_lightGrayColorCache)
    {
        _lightGrayColorCache = [[self alloc] initWithWhite: 0.667
                                                     alpha: 1.0];
    }
    
    return _lightGrayColorCache;
}

static VGColor *_whiteColorCache = nil;
+ (VGColor *)whiteColor      // 1.0 white
{
    if (!_whiteColorCache)
    {
        _whiteColorCache = [[self alloc] initWithWhite: 1.0
                                                 alpha: 1.0];
    }
    return _whiteColorCache;
}

static VGColor *_grayColorCache = nil;
+ (VGColor *)grayColor       // 0.5 white
{
    if (!_grayColorCache)
    {
        _grayColorCache = [[self alloc] initWithWhite: 0.5
                                                alpha: 1.0];
    }
    return _grayColorCache;
}

static VGColor *_redColorCache = nil;
+ (VGColor *)redColor        // 1.0, 0.0, 0.0 RGB
{
    if (!_redColorCache)
    {
        _redColorCache = [[self alloc] initWithRed: 1.0
                                             green: 0.0
                                              blue: 0.0
                                             alpha: 1.0];
    }
    return _redColorCache;
}

static VGColor *_greenColorCache = nil;
+ (VGColor *)greenColor      // 0.0, 1.0, 0.0 RGB
{
    if (!_greenColorCache)
    {
        _greenColorCache = [[self alloc] initWithRed: 0.0
                                               green: 1.0
                                                blue: 0.0
                                               alpha: 1.0];
    }
    
    return _greenColorCache;
}

static VGColor *_blueColorCache = nil;
+ (VGColor *)blueColor       // 0.0, 0.0, 1.0 RGB
{
    if (!_blueColorCache)
    {
        _blueColorCache = [[self alloc] initWithRed: 0.0
                                              green: 0.0
                                               blue: 1.0
                                              alpha: 1.0];
    }
    return _blueColorCache;
}

static VGColor *_cyanColorCache = nil;
+ (VGColor *)cyanColor       // 0.0, 1.0, 1.0 RGB
{
    if (!_cyanColorCache)
    {
        _cyanColorCache = [[self alloc] initWithRed: 0.0
                                              green: 1.0
                                               blue: 1.0
                                              alpha: 1.0];
    }
    return _cyanColorCache;
}

static VGColor *_yellowColorCache = nil;
+ (VGColor *)yellowColor     // 1.0, 1.0, 0.0 RGB
{
    if (!_yellowColorCache)
    {
        _yellowColorCache = [[self alloc] initWithRed: 1.0
                                                green: 1.0
                                                 blue: 0.0
                                                alpha: 1.0];
    }
    
    return _yellowColorCache;
}

static VGColor *_magentaColorCache = nil;
+ (VGColor *)magentaColor    // 1.0, 0.0, 1.0 RGB
{
    if (!_magentaColorCache)
    {
        _magentaColorCache = [[self alloc] initWithRed: 1.0
                                                 green: 0.0
                                                  blue: 1.0
                                                 alpha: 1.0];
    }
    return _magentaColorCache;
}

static VGColor *_orangeColorCache = nil;
+ (VGColor *)orangeColor     // 1.0, 0.5, 0.0 RGB
{
    if (!_orangeColorCache)
    {
        _orangeColorCache = [[self alloc] initWithRed: 1.0
                                                green: 0.5
                                                 blue: 0.0
                                                alpha: 1.0];
    }
    return _orangeColorCache;
}

static VGColor *_purpleColorCache = nil;
+ (VGColor *)purpleColor     // 0.5, 0.0, 0.5 RGB
{
    if (!_purpleColorCache)
    {
        _purpleColorCache = [[self alloc] initWithRed: 0.5
                                                green: 0.0
                                                 blue: 0.5
                                                alpha: 1.0];
    }
    return _purpleColorCache;
}

static VGColor *_brownColorCache = nil;
+ (VGColor *)brownColor      // 0.6, 0.4, 0.2 RGB
{
    if (!_brownColorCache)
    {
        _brownColorCache = [[self alloc] initWithRed: 0.6
                                               green: 0.4
                                                blue: 0.2
                                               alpha: 1.0];
    }
    return _brownColorCache;
}

static VGColor *_clearColorCache = nil;

+ (VGColor *)clearColor      // 0.0 white, 0.0 alpha
{
    if (!_clearColorCache)
    {
        _clearColorCache = [[self alloc] initWithWhite: 0.0
                                                 alpha: 1.0];
    }
    
    return _clearColorCache;
}

// Set the color: Sets the fill and stroke colors in the current drawing context. Should be implemented by subclassers.
- (void)set
{
    
}

// Set the fill or stroke colors individually. These should be implemented by subclassers.
- (void)setFill
{
    
}

- (void)setStroke
{
    
}

// Convenience methods for getting components.
// If the receiver is of a compatible color space, any non-NULL parameters are populated and 'YES' is returned. Otherwise, the parameters are left unchanged and 'NO' is returned.
- (BOOL)getWhite: (float *)white
           alpha: (float *)alpha
{
    return NO;
}

- (BOOL)getHue: (float *)hue
    saturation: (float *)saturation
    brightness: (float *)brightness
         alpha: (float *)alpha
{
    return NO;
}

- (BOOL)getRed: (float *)red
         green: (float *)green
          blue: (float *)blue
         alpha: (float *)alpha
{
    *red = _color.r;
    *green = _color.g;
    *blue = _color.b;
    *alpha = _color.a;
    
    return YES;
}

// Returns a color in the same color space as the receiver with the specified alpha component.
- (VGColor *)colorWithAlphaComponent: (float)alpha
{
    VGColor *newColor = [[[self class] alloc] initWithRed: _color.r
                                                    green: _color.g
                                                     blue: _color.b
                                                    alpha: alpha];
    return [newColor autorelease];
}

#pragma mark - NSCoding
- (id)initWithCoder: (NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        _color.r = [aDecoder decodeFloatForKey: @"red"];
        _color.g = [aDecoder decodeFloatForKey: @"green"];
        _color.b = [aDecoder decodeFloatForKey: @"blue"];
        _color.a = [aDecoder decodeFloatForKey: @"alpha"];
    }
    
    return self;
}

- (void)encodeWithCoder: (NSCoder *)aCoder
{
    [aCoder encodeFloat: _color.r
                 forKey: @"red"];
    [aCoder encodeFloat: _color.g
                 forKey: @"green"];
    [aCoder encodeFloat: _color.b
                 forKey: @"blue"];
    [aCoder encodeFloat: _color.a
                 forKey: @"alpha"];
}

- (id)copyWithZone: (NSZone *)zone
{
    VGColor *copy = [[[self class] allocWithZone: zone] init];
    copy->_color = _color;
    return copy;
}

- (GLKVector4)CCColor
{
    return _color;
}

@end
