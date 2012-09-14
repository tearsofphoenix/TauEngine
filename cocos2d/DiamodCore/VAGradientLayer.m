//
//  VAGradientLayer.m
//  VUEngine
//
//  Created by LeixSnake on 9/11/12.
//
//

#import "VAGradientLayer.h"
#import "VALayer+Private.h"
#import "CGPointExtension.h"
#import "VGColor.h"

@implementation VAGradientLayer

@synthesize startOpacity = startOpacity_;
@synthesize endColor = endColor_, endOpacity = endOpacity_;
@synthesize vector = vector_;

- (id) initWithColor: (VGColor *) start
            fadingTo: (VGColor *) end
{
    return [self initWithColor: start
                      fadingTo: end
                   alongVector: ccp(0, -1)];
}

- (id) initWithColor: (VGColor *) start
            fadingTo: (VGColor *) end
         alongVector: (CGPoint) v
{
    if ((self = [super init]))
    {
        
        endColor_ = end;
        
        GLKVector4 endColor = [endColor_ CCColor];

        endOpacity_		= endColor.a ;
        startOpacity_	= [start CCColor].a;
        vector_ = v;
        compressedInterpolation_ = YES;
        [self setBackgroundColor: start];
    }
    return self;
}

- (void) updateColor
{
    [super updateColor];
    
    float h = ccpLength(vector_);
    if (h == 0)
        return;
    
    float c = sqrtf(2);
    CGPoint u = ccp(vector_.x / h, vector_.y / h);
    
    // Compressed Interpolation mode
    if( compressedInterpolation_ ) {
        float h2 = 1 / ( fabsf(u.x) + fabsf(u.y) );
        u = ccpMult(u, h2 * (float)c);
    }
    GLKVector4 color = [_backgroundColor CCColor];
    float opacityf = color.a;
    
    GLKVector4 S = GLKVector4Make(
                                  color.r ,
                                  color.g ,
                                  color.b ,
                                  startOpacity_ * opacityf
                                  );
    
    GLKVector4 endColor = [endColor_ CCColor];
    
    GLKVector4 E = GLKVector4Make(
                                  endColor.r ,
                                  endColor.g ,
                                  endColor.b ,
                                  endOpacity_*opacityf
                                  );
    
    
    // (-1, -1)
    _vertexColors[0].r = E.r + (S.r - E.r) * ((c + u.x + u.y) / (2.0f * c));
    _vertexColors[0].g = E.g + (S.g - E.g) * ((c + u.x + u.y) / (2.0f * c));
    _vertexColors[0].b = E.b + (S.b - E.b) * ((c + u.x + u.y) / (2.0f * c));
    _vertexColors[0].a = E.a + (S.a - E.a) * ((c + u.x + u.y) / (2.0f * c));
    // (1, -1)
    _vertexColors[1].r = E.r + (S.r - E.r) * ((c - u.x + u.y) / (2.0f * c));
    _vertexColors[1].g = E.g + (S.g - E.g) * ((c - u.x + u.y) / (2.0f * c));
    _vertexColors[1].b = E.b + (S.b - E.b) * ((c - u.x + u.y) / (2.0f * c));
    _vertexColors[1].a = E.a + (S.a - E.a) * ((c - u.x + u.y) / (2.0f * c));
    // (-1, 1)
    _vertexColors[2].r = E.r + (S.r - E.r) * ((c + u.x - u.y) / (2.0f * c));
    _vertexColors[2].g = E.g + (S.g - E.g) * ((c + u.x - u.y) / (2.0f * c));
    _vertexColors[2].b = E.b + (S.b - E.b) * ((c + u.x - u.y) / (2.0f * c));
    _vertexColors[2].a = E.a + (S.a - E.a) * ((c + u.x - u.y) / (2.0f * c));
    // (1, 1)
    _vertexColors[3].r = E.r + (S.r - E.r) * ((c - u.x - u.y) / (2.0f * c));
    _vertexColors[3].g = E.g + (S.g - E.g) * ((c - u.x - u.y) / (2.0f * c));
    _vertexColors[3].b = E.b + (S.b - E.b) * ((c - u.x - u.y) / (2.0f * c));
    _vertexColors[3].a = E.a + (S.a - E.a) * ((c - u.x - u.y) / (2.0f * c));
}

- (VGColor *)startColor
{
    return _backgroundColor;
}

- (void) setStartColor:(VGColor *)colors
{
    [self setBackgroundColor: colors];
}

-(void) setEndColor:(VGColor *)colors
{
    endColor_ = colors;
    [self updateColor];
}

-(void) setStartOpacity: (GLfloat) o
{
    startOpacity_ = o;
    [self updateColor];
}

-(void) setEndOpacity: (GLfloat) o
{
    endOpacity_ = o;
    [self updateColor];
}

-(void) setVector: (CGPoint) v
{
    vector_ = v;
    [self updateColor];
}

-(BOOL) compressedInterpolation
{
    return compressedInterpolation_;
}

-(void) setCompressedInterpolation:(BOOL)compress
{
    compressedInterpolation_ = compress;
    [self updateColor];
}

@end


