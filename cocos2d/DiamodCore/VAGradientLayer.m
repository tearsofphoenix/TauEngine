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

@implementation VAGradientLayer

@synthesize startOpacity = startOpacity_;
@synthesize endColor = endColor_, endOpacity = endOpacity_;
@synthesize vector = vector_;

- (id) initWithColor: (GLKVector4) start fadingTo: (GLKVector4) end
{
    return [self initWithColor:start fadingTo:end alongVector:ccp(0, -1)];
}

- (id) initWithColor: (GLKVector4) start
            fadingTo: (GLKVector4) end
         alongVector: (CGPoint) v
{
    if ((self = [super init]))
    {
        
        endColor_ = end;
        
        endOpacity_		= end.a;
        startOpacity_	= start.a;
        vector_ = v;
        
        start.a	= 1;
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
    
    float opacityf = _backgroundColor.a;
    
    GLKVector4 S = GLKVector4Make(
                                  _backgroundColor.r ,
                                  _backgroundColor.g ,
                                  _backgroundColor.b ,
                                  startOpacity_ * opacityf
                                  );
    
    GLKVector4 E = GLKVector4Make(
                                  endColor_.r ,
                                  endColor_.g ,
                                  endColor_.b ,
                                  endOpacity_*opacityf
                                  );
    
    
    // (-1, -1)
    squareColors_[0].r = E.r + (S.r - E.r) * ((c + u.x + u.y) / (2.0f * c));
    squareColors_[0].g = E.g + (S.g - E.g) * ((c + u.x + u.y) / (2.0f * c));
    squareColors_[0].b = E.b + (S.b - E.b) * ((c + u.x + u.y) / (2.0f * c));
    squareColors_[0].a = E.a + (S.a - E.a) * ((c + u.x + u.y) / (2.0f * c));
    // (1, -1)
    squareColors_[1].r = E.r + (S.r - E.r) * ((c - u.x + u.y) / (2.0f * c));
    squareColors_[1].g = E.g + (S.g - E.g) * ((c - u.x + u.y) / (2.0f * c));
    squareColors_[1].b = E.b + (S.b - E.b) * ((c - u.x + u.y) / (2.0f * c));
    squareColors_[1].a = E.a + (S.a - E.a) * ((c - u.x + u.y) / (2.0f * c));
    // (-1, 1)
    squareColors_[2].r = E.r + (S.r - E.r) * ((c + u.x - u.y) / (2.0f * c));
    squareColors_[2].g = E.g + (S.g - E.g) * ((c + u.x - u.y) / (2.0f * c));
    squareColors_[2].b = E.b + (S.b - E.b) * ((c + u.x - u.y) / (2.0f * c));
    squareColors_[2].a = E.a + (S.a - E.a) * ((c + u.x - u.y) / (2.0f * c));
    // (1, 1)
    squareColors_[3].r = E.r + (S.r - E.r) * ((c - u.x - u.y) / (2.0f * c));
    squareColors_[3].g = E.g + (S.g - E.g) * ((c - u.x - u.y) / (2.0f * c));
    squareColors_[3].b = E.b + (S.b - E.b) * ((c - u.x - u.y) / (2.0f * c));
    squareColors_[3].a = E.a + (S.a - E.a) * ((c - u.x - u.y) / (2.0f * c));
}

- (GLKVector4)startColor
{
    return _backgroundColor;
}

-(void) setStartColor:(GLKVector4)colors
{
    [self setBackgroundColor: colors];
}

-(void) setEndColor:(GLKVector4)colors
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


