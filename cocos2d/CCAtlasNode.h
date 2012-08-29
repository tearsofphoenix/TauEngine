/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
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


#import "CCNode.h"
#import "CCProtocols.h"

@class CCAtlasTexture;

/** CCAtlasNode is a subclass of CCNode that implements the CCRGBAProtocol and
 CCTextureProtocol protocol

 It knows how to render a TextureAtlas object.
 If you are going to render a TextureAtlas consider subclassing CCAtlasNode (or a subclass of CCAtlasNode)

 All features from CCNode are valid, plus the following features:
 - opacity and RGB colors
 */
@interface CCAtlasNode : CCNode <CCRGBAProtocol, CCTextureProtocol>
{
	// texture atlas
	CCAtlasTexture	*_textureAtlas;

	// chars per row
	NSUInteger		itemsPerRow_;
	// chars per column
	NSUInteger		itemsPerColumn_;

	// size of each char
    CGSize _itemSize;

	// quads to draw
	NSUInteger		quadsToDraw_;

	// blend function
	ccBlendFunc		_blendFunc;

	// texture RGBA.
	GLubyte		_opacity;
	ccColor4B	color_;
	ccColor4B	colorUnmodified_;
	BOOL opacityModifyRGB_;

	// color uniform
	GLint	uniformColor_;
}

@property (nonatomic, retain) CCAtlasTexture *textureAtlas;

/** how many quads to draw */
@property (nonatomic) NSUInteger quadsToDraw;

/** initializes an CCAtlasNode  with an Atlas file the width and height of each item measured in points and the quantity of items to render*/
-(id) initWithTileFile: (NSString*)tile
              tileSize: (CGSize)size
         itemsToRender: (NSUInteger) c;

/** updates the Atlas (indexed vertex array).
 * Shall be overriden in subclasses
 */
-(void) updateAtlasValues;
@end
