//
//  TENumberDisplay.m
//  TauGame
//
//  Created by Ian Terrell on 7/28/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TENumberDisplay.h"
#import "TauEngine.h"


static GLKBaseEffect *digitsTextureEffect;

static CGSize digitSize;
static float digitFractionalWidth;

@implementation TENumberDisplay

@synthesize numDigits = _numDigits;
@synthesize decimalPointDigit = _decimalPointDigit;
@synthesize hiddenDigits = _hiddenDigits;
@synthesize width = _width;

@synthesize number = _number;

+ (void)initialize
{
    UIFont *font = [UIFont fontWithName:@"Courier-Bold" size:30];
    
    digitsTextureEffect = [TETexture effectWithTextureFromImage:[TEImage imageFromText:@"0123456789." withFont:font color:[UIColor whiteColor]]];
    digitsTextureEffect.texture2d0.envMode = GLKTextureEnvModeModulate;
    
    digitSize = [@"0" sizeWithFont:font];
    digitSize = CGSizeMake(digitSize.width-1.0, digitSize.height); // pads by 1 px on end
    digitFractionalWidth = digitSize.width / (11*digitSize.width + 1.0);
}

- (id)initWithNumDigits: (int)num
{
    self = [super initWithVertices:num*4];
    if (self)
    {
        [self setEffect: digitsTextureEffect];
        [self setRenderStyle: kTERenderStyleTexture | kTERenderStyleVertexColors];
        
        _numDigits = num;
        _decimalPointDigit = 0;
        _hiddenDigits = 0;
        _width = _numDigits;
        self.number = 0;
    }
    
    return self;
}

- (void)updateVertices
{
    float digitWidth = _width / (_numDigits - _hiddenDigits);
    float digitHeight = digitSize.height * (digitWidth/digitSize.width);
    
    float offset = _numDigits % 2 == 0 ? 0 : digitWidth / 2.0;
    int middle = (_numDigits - _hiddenDigits) / 2;
    float top = digitHeight/2;
    float bottom = -1*top;
    
    GLKVector2 *vertices = [self vertices];

    for (int i = 0; i < _numDigits; i++)
    {
        int index = i*4;
        if (i < _hiddenDigits)
        {
            vertices[index+0] = vertices[index+1] = vertices[index+2] = vertices[index+3] = GLKVector2Make(1000, 1000); // offscreen hack
        } else
        {
            float left = -1 * (middle - (i - _hiddenDigits)) * digitWidth - offset;
            float right = left + digitWidth;
            vertices[index+0] = GLKVector2Make(left, top);
            vertices[index+1] = GLKVector2Make(left, bottom);
            vertices[index+2] = GLKVector2Make(right, top);
            vertices[index+3] = GLKVector2Make(right, bottom);
        }
    }
}

- (void)updateTextureCoordinates
{
    for(int i = 0, temp = _number; i < _numDigits; ++i)
    {
        int index = (_numDigits - i - 1)*4;
        int digit;
        
        if (_decimalPointDigit > 0 && i == _decimalPointDigit)
        {
            digit = 10;
            
        }else
        {
            digit = temp-10*(temp/10);
            temp /= 10;
        }
        
        if (_hiddenDigits > 0 && i >= _hiddenDigits)
        {
            self.textureCoordinates[index+0] = self.textureCoordinates[index+1] = self.textureCoordinates[index+2] = self.textureCoordinates[index+3] = GLKVector2Make(0, 0);
        } else
        {
            self.textureCoordinates[index+0] = GLKVector2Make(digit*digitFractionalWidth, 1);
            self.textureCoordinates[index+1] = GLKVector2Make(digit*digitFractionalWidth, 0);
            self.textureCoordinates[index+2] = GLKVector2Make((digit+1)*digitFractionalWidth, 1);
            self.textureCoordinates[index+3] = GLKVector2Make((digit+1)*digitFractionalWidth, 0);
        }
        
        GLKVector4 digitColor = digit == 10 || ((digit == 0) && (temp <= 0)) ? GLKVector4Make(0.5,0.5,0.5,0.5) : GLKVector4Make(1,1,1,1);
        self.colorVertices[index+0] = self.colorVertices[index+1] = self.colorVertices[index+2] = self.colorVertices[index+3] = digitColor;
    }
}

- (GLenum)renderMode
{
    return GL_TRIANGLE_STRIP;
}

-(void)setNumber: (int)number
{
    _number = number;
    [self updateTextureCoordinates];
}

- (float)height
{
    return digitSize.height * ((_width / (_numDigits - _hiddenDigits)) / digitSize.width);
}

- (void)setWidth:(float)width
{
    _width = width;
    [self updateVertices];
}

@end
