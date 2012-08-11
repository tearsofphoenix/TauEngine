;//
//  TEShape.m
//  TauGame
//
//  Created by Ian Terrell on 7/11/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEShape.h"
#import "TEEllipse.h"

#define RenderStyleIs(x) ((_renderStyle & x) == x)

static GLKBaseEffect *s_defaultEffect = nil;

static GLKBaseEffect *s_constantColorEffect = nil;

@implementation TEShape

@synthesize effect = _effect;
@synthesize renderStyle = _renderStyle;
@synthesize color = _color;
@synthesize colorData = _colorData;
@synthesize numVertices = _numVertices;
@synthesize radius = _radius;

+ (void)initialize
{
    s_defaultEffect = [[GLKBaseEffect alloc] init];
    
    s_constantColorEffect = [[GLKBaseEffect alloc] init];
    [s_constantColorEffect setUseConstantColor: YES];
    
    [super initialize];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _renderStyle = kTERenderStyleConstantColor;
    }
    
    return self;
}

- (int)numVertices
{
    return 0;
}

- (GLKVector2 *)vertices
{
    if (_vertexData == nil)
    {
        _vertexData = [NSMutableData dataWithLength:sizeof(GLKVector2) * _numVertices];
        _vertices = [_vertexData mutableBytes];
    }
    return _vertices;
}

- (GLKVector2 *)textureCoordinates
{
    if (_textureData == nil)
    {
        _textureData = [NSMutableData dataWithLength:sizeof(GLKVector2) * _numVertices];
        _textureCoordinates = [_textureData mutableBytes];
    }
    return _textureCoordinates;
}

-(GLKVector4 *)colorVertices
{
    if (_colorData == nil)
    {
        _colorData = [NSMutableData dataWithLength:sizeof(GLKVector4) * _numVertices];
        _colorVertices = [_colorData mutableBytes];
    }
    return _colorVertices;
}

- (void)updateVertices
{
    
}

- (GLenum)renderMode
{
    return GL_TRIANGLE_FAN;
}

- (void)renderInScene:(TEScene *)scene
{
    if (_renderStyle == kTERenderStyleNone)
    {
        return;
    }
    
    __block GLKVector4 *displayColorVertices = NULL;
    
    // Initialize the effect if necessary
    if (_effect == nil)
    {
        if (RenderStyleIs(kTERenderStyleConstantColor))
        {
            _effect = s_constantColorEffect;
            
        }else if (RenderStyleIs(kTERenderStyleVertexColors))
        {
            _effect = s_defaultEffect;
        }
    }
    
    _effect.transform.modelviewMatrix = [[super node] modelViewMatrix];
    _effect.transform.projectionMatrix = [scene projectionMatrix];
    
    // Set up effect specifics
    if (RenderStyleIs(kTERenderStyleConstantColor))
    {
        _effect.constantColor = _color;
        
        [[[super node] currentAnimations] enumerateObjectsUsingBlock: (^(id animation, NSUInteger idx, BOOL *stop)
                                                                       {
                                                                           if ([animation isKindOfClass:[TEColorAnimation class]])
                                                                           {
                                                                               TEColorAnimation *colorAnimation = (TEColorAnimation *)animation;
                                                                               _effect.constantColor = GLKVector4Add(_effect.constantColor, colorAnimation.easedColor);
                                                                           }
                                                                       })];
        
    } else if (RenderStyleIs(kTERenderStyleVertexColors))
    {
        displayColorVertices = _colorVertices;
        [[[super node] currentAnimations] enumerateObjectsUsingBlock: (^(id animation, NSUInteger idx, BOOL *stop)
                                                                       {
                                                                           if ([animation isKindOfClass:[TEVertexColorAnimation class]])
                                                                           {
                                                                               TEVertexColorAnimation *colorAnimation = (TEVertexColorAnimation *)animation;
                                                                               displayColorVertices = colorAnimation.easedColorVertices;
                                                                           }
                                                                       })];
    }
    
    // Finalize effect
    [_effect prepareToDraw];
    
    // Set up transparency
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // Set up position vertices
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, _vertices);
    
    // Set up color vertices
    if (RenderStyleIs(kTERenderStyleVertexColors))
    {
        glEnableVertexAttribArray(GLKVertexAttribColor);
        glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, displayColorVertices);
    }
    
    // Set up texture vertices
    if (RenderStyleIs(kTERenderStyleTexture))
    {
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, _textureCoordinates);
    }
    
    // Draw arrays
    glDrawArrays(self.renderMode, 0, _numVertices);
    
    // Tear down position vertices
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    
    // Tear down color vertices
    if (RenderStyleIs(kTERenderStyleVertexColors))
        glDisableVertexAttribArray(GLKVertexAttribColor);
    
    // Tear down texture vertices
    if (RenderStyleIs(kTERenderStyleTexture))
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    // Disable transparency
    glDisable(GL_BLEND);
}

- (BOOL)isPolygon
{
    return ![self isCircle];
}

- (BOOL)isCircle
{
    return [self isKindOfClass:[TEEllipse class]];
}

- (float)radius
{
    return 0.0;
}

@end
