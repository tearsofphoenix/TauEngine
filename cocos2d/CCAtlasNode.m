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
 */


#import "CCAtlasNode.h"
#import "ccMacros.h"
#import "CCGLProgram.h"
#import "CCShaderCache.h"
#import "ccGLStateCache.h"
#import "CCDirector.h"
#import "CCAtlasTexture.h"
#import "Support/TransformUtils.h"


@interface CCAtlasNode ()
-(void) calculateMaxItems;
-(void) updateBlendFunc;
-(void) updateOpacityModifyRGB;
@end

@implementation CCAtlasNode

@synthesize textureAtlas = _textureAtlas;
@synthesize blendFunc = _blendFunc;
@synthesize quadsToDraw = quadsToDraw_;

#pragma mark CCAtlasNode - Creation & Init
- (id) init
{
	NSAssert( NO, @"Not supported - Use initWtihTileFile instead");
    return self;
}

-(id) initWithTileFile: (NSString*)tile
              tileSize: (CGSize)size
         itemsToRender: (NSUInteger) c;

{
	if( (self=[super init]) )
    {
        _itemSize = size;
		_opacity = 255;
		color_ = colorUnmodified_ = ccWHITE;
		opacityModifyRGB_ = YES;

		_blendFunc.src = CC_BLEND_SRC;
		_blendFunc.dst = CC_BLEND_DST;

		_textureAtlas = [[CCAtlasTexture alloc] initWithFile:tile capacity:c];
		
		if( ! _textureAtlas )
        {
			CCLOG(@"cocos2d: Could not initialize CCAtlasNode. Invalid Texture");
			[self release];
			return nil;
		}

		[self updateBlendFunc];
		[self updateOpacityModifyRGB];

		[self calculateMaxItems];

		self.quadsToDraw = c;

		// shader stuff
		self.shaderProgram = CCShaderCacheGetProgramByName(kCCShader_PositionTexture_uColor);
		uniformColor_ = CCGLProgramGetUniformLocation(_shaderProgram, "u_color");
	}
	return self;
}

-(void) dealloc
{
	[_textureAtlas release];

	[super dealloc];
}

#pragma mark CCAtlasNode - Atlas generation

-(void) calculateMaxItems
{
	CGSize s = [[_textureAtlas texture] contentSize];
	itemsPerColumn_ = s.height / _itemSize.height;
	itemsPerRow_ = s.width / _itemSize.width;
}

-(void) updateAtlasValues
{
	[NSException raise:@"CCAtlasNode:Abstract" format:@"updateAtlasValue not overriden"];
}

#pragma mark CCAtlasNode - draw
- (void) draw
{
	CC_NODE_DRAW_SETUP();

	CCGLBlendFunc( _blendFunc.src, _blendFunc.dst );
	
	GLfloat colors[4] = {color_.r / 255.0f, color_.g / 255.0f, color_.b / 255.0f, _opacity / 255.0f};
    
    CCGLProgramUniformfv(_shaderProgram, uniformColor_, colors, 1, CCGLUniform4fv);
	
	[_textureAtlas drawNumberOfQuads:quadsToDraw_ fromIndex:0];
}

#pragma mark CCAtlasNode - RGBA protocol

- (ccColor4B) color
{
	if(opacityModifyRGB_)
		return colorUnmodified_;

	return color_;
}

-(void) setColor:(ccColor4B)color3
{
	color_ = colorUnmodified_ = color3;

	if( opacityModifyRGB_ )
    {
		color_.r = color3.r * _opacity/255;
		color_.g = color3.g * _opacity/255;
		color_.b = color3.b * _opacity/255;
	}
}

@synthesize opacity = _opacity;

-(void) setOpacity:(GLubyte) anOpacity
{
	_opacity			= anOpacity;

	// special opacity for premultiplied textures
	if( opacityModifyRGB_ )
    {
		[self setColor: colorUnmodified_];
    }
}

-(void) setOpacityModifyRGB:(BOOL)modify
{
	ccColor4B oldColor	= self.color;
	opacityModifyRGB_	= modify;
	self.color			= oldColor;
}

-(BOOL) doesOpacityModifyRGB
{
	return opacityModifyRGB_;
}

-(void) updateOpacityModifyRGB
{
	opacityModifyRGB_ = [_textureAtlas.texture hasPremultipliedAlpha];
}

#pragma mark CCAtlasNode - CCNodeTexture protocol

-(void) updateBlendFunc
{
	if( ! [_textureAtlas.texture hasPremultipliedAlpha] )
    {
		_blendFunc.src = GL_SRC_ALPHA;
		_blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(void) setTexture:(CCTexture2D*)texture
{
	_textureAtlas.texture = texture;
	[self updateBlendFunc];
	[self updateOpacityModifyRGB];
}

-(CCTexture2D*) texture
{
	return _textureAtlas.texture;
}

@end
