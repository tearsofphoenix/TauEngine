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
#import "VALayer+Private.h"

@interface VAGradientLayer ()
{
    NSMutableArray *_colors;
    NSMutableArray *_locations;
    CGPoint _startPoint;
    CGPoint _endPoint;
}
@end

@implementation VAGradientLayer

- (void)setColors: (NSArray *)colors
{
    if (![_colors isEqualToArray: colors])
    {

        if (!_colors)
    {
        _colors = [[NSMutableArray alloc] initWithArray: colors];
        
    }else
    {
        [_colors setArray: colors];
    }
    }
}

- (NSArray *)colors
{
    return [NSArray arrayWithArray: _colors];
}

- (void)setLocations: (NSArray *)locations
{
    if (![_locations isEqualToArray: locations])
    {
        if (!_locations)
        {
            _locations = [[NSMutableArray alloc] initWithArray: locations];
        }else
        {
            [_locations setArray: locations];
        }
    }
}

- (NSArray *)locations
{
    return [NSArray arrayWithArray: _locations];
}

- (void)setStartPoint: (CGPoint)startPoint
{
    if (!CGPointEqualToPoint(_startPoint, startPoint))
    {
        _startPoint = startPoint;
    }
}

- (CGPoint)startPoint
{
    return _startPoint;
}

- (void)setEndPoint: (CGPoint)endPoint
{
    if (!CGPointEqualToPoint(_endPoint, endPoint))
    {
        _endPoint = endPoint;
    }
}

- (CGPoint)endPoint
{
    return _endPoint;
}

//- (void) updateColor
//{
//    [super updateColor];
//    
//    float h = ccpLength(vector_);
//    if (h == 0)
//        return;
//    
//    float c = sqrtf(2);
//    CGPoint u = ccp(vector_.x / h, vector_.y / h);
//    
//    // Compressed Interpolation mode
//    if( compressedInterpolation_ ) {
//        float h2 = 1 / ( fabsf(u.x) + fabsf(u.y) );
//        u = ccpMult(u, h2 * (float)c);
//    }
//    GLKVector4 color = [_backgroundColor CCColor];
//    float opacityf = color.a;
//    
//    GLKVector4 S = GLKVector4Make(
//                                  color.r ,
//                                  color.g ,
//                                  color.b ,
//                                  startOpacity_ * opacityf
//                                  );
//    
//    GLKVector4 endColor = [endColor_ CCColor];
//    
//    GLKVector4 E = GLKVector4Make(
//                                  endColor.r ,
//                                  endColor.g ,
//                                  endColor.b ,
//                                  endOpacity_*opacityf
//                                  );
//    
//    
//    // (-1, -1)
//    _vertexColors[0].r = E.r + (S.r - E.r) * ((c + u.x + u.y) / (2.0f * c));
//    _vertexColors[0].g = E.g + (S.g - E.g) * ((c + u.x + u.y) / (2.0f * c));
//    _vertexColors[0].b = E.b + (S.b - E.b) * ((c + u.x + u.y) / (2.0f * c));
//    _vertexColors[0].a = E.a + (S.a - E.a) * ((c + u.x + u.y) / (2.0f * c));
//    // (1, -1)
//    _vertexColors[1].r = E.r + (S.r - E.r) * ((c - u.x + u.y) / (2.0f * c));
//    _vertexColors[1].g = E.g + (S.g - E.g) * ((c - u.x + u.y) / (2.0f * c));
//    _vertexColors[1].b = E.b + (S.b - E.b) * ((c - u.x + u.y) / (2.0f * c));
//    _vertexColors[1].a = E.a + (S.a - E.a) * ((c - u.x + u.y) / (2.0f * c));
//    // (-1, 1)
//    _vertexColors[2].r = E.r + (S.r - E.r) * ((c + u.x - u.y) / (2.0f * c));
//    _vertexColors[2].g = E.g + (S.g - E.g) * ((c + u.x - u.y) / (2.0f * c));
//    _vertexColors[2].b = E.b + (S.b - E.b) * ((c + u.x - u.y) / (2.0f * c));
//    _vertexColors[2].a = E.a + (S.a - E.a) * ((c + u.x - u.y) / (2.0f * c));
//    // (1, 1)
//    _vertexColors[3].r = E.r + (S.r - E.r) * ((c - u.x - u.y) / (2.0f * c));
//    _vertexColors[3].g = E.g + (S.g - E.g) * ((c - u.x - u.y) / (2.0f * c));
//    _vertexColors[3].b = E.b + (S.b - E.b) * ((c - u.x - u.y) / (2.0f * c));
//    _vertexColors[3].a = E.a + (S.a - E.a) * ((c - u.x - u.y) / (2.0f * c));
//}

@end


