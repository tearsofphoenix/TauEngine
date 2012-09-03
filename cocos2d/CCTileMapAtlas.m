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
 *
 */

#import "ccConfig.h"
#import "CCTileMapAtlas.h"
#import "ccMacros.h"
#import "Support/CCFileUtils.h"

@interface CCTileMapAtlas (Private)
-(void) loadTGAfile:(NSString*)file;
-(void) calculateItemsToRender;
-(void) updateAtlasValueAt:(ccGridSize)pos withValue:(GLKVector3)value withIndex:(NSUInteger)idx;
@end


@implementation CCTileMapAtlas

@synthesize tgaInfo;

#pragma mark CCTileMapAtlas - Creation & Init
+(id) tileMapAtlasWithTileFile:(NSString*)tile mapFile:(NSString*)map tileWidth:(int)w tileHeight:(int)h
{
	return [[[self alloc] initWithTileFile:tile mapFile:map tileWidth:w tileHeight:h] autorelease];
}


-(id) initWithTileFile:(NSString*)tile mapFile:(NSString*)map tileWidth:(int)w tileHeight:(int)h
{
	[self loadTGAfile: map];
	[self calculateItemsToRender];

	if( (self=[super initWithTileFile:tile tileSize: CGSizeMake(w, h) itemsToRender: itemsToRender]) )
    {

		_color = ccWHITE;

		posToAtlasIndex = [[NSMutableDictionary dictionaryWithCapacity:itemsToRender] retain];

		[self updateAtlasValues];

		[self setContentSize: CGSizeMake(tgaInfo->width * _itemSize.width, tgaInfo->height * _itemSize.height)];
	}

	return self;
}

-(void) dealloc
{
	if( tgaInfo )
		tgaDestroy(tgaInfo);

	[posToAtlasIndex release];

	[super dealloc];
}

-(void) releaseMap
{
	if( tgaInfo )
		tgaDestroy(tgaInfo);

	tgaInfo = nil;

	[posToAtlasIndex release];
	posToAtlasIndex = nil;
}

-(void) calculateItemsToRender
{
	NSAssert( tgaInfo != nil, @"tgaInfo must be non-nil");

	itemsToRender = 0;
	for(int x = 0;x < tgaInfo->width; x++ ) {
		for(int y = 0; y < tgaInfo->height; y++ ) {
			GLKVector3 *ptr = (GLKVector3*) tgaInfo->imageData;
			GLKVector3 value = ptr[x + y * tgaInfo->width];
			if( value.r )
				itemsToRender++;
		}
	}
}

-(void) loadTGAfile:(NSString*)file
{
	NSAssert( file != nil, @"file must be non-nil");

	NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:file ];

//	//Find the path of the file
//	NSBundle *mainBndl = [CCDirector sharedDirector].loadingBundle;
//	NSString *resourcePath = [mainBndl resourcePath];
//	NSString * path = [resourcePath stringByAppendingPathComponent:file];

	tgaInfo = tgaLoad( [path UTF8String] );
#if 1
	if( tgaInfo->status != TGA_OK )
		[NSException raise:@"TileMapAtlasLoadTGA" format:@"TileMapAtas cannot load TGA file"];

#endif
}

#pragma mark CCTileMapAtlas - Atlas generation / updates

-(void) setTile:(GLKVector3) tile at:(ccGridSize) pos
{
	NSAssert( tgaInfo != nil, @"tgaInfo must not be nil");
	NSAssert( posToAtlasIndex != nil, @"posToAtlasIndex must not be nil");
	NSAssert( pos.x < tgaInfo->width, @"Invalid position.x");
	NSAssert( pos.y < tgaInfo->height, @"Invalid position.x");
	NSAssert( tile.r != 0, @"R component must be non 0");

	GLKVector3 *ptr = (GLKVector3*) tgaInfo->imageData;
	GLKVector3 value = ptr[pos.x + pos.y * tgaInfo->width];
	if( value.r == 0 )
		CCLOG(@"cocos2d: Value.r must be non 0.");
	else {
		ptr[pos.x + pos.y * tgaInfo->width] = tile;

		// XXX: this method consumes a lot of memory
		// XXX: a tree of something like that shall be impolemented
		NSNumber *num = [posToAtlasIndex objectForKey: [NSString stringWithFormat:@"%ld,%ld", (long)pos.x, (long)pos.y]];
		[self updateAtlasValueAt:pos withValue:tile withIndex: [num integerValue]];
	}
}

-(GLKVector3) tileAt:(ccGridSize) pos
{
	NSAssert( tgaInfo != nil, @"tgaInfo must not be nil");
	NSAssert( pos.x < tgaInfo->width, @"Invalid position.x");
	NSAssert( pos.y < tgaInfo->height, @"Invalid position.y");

	GLKVector3 *ptr = (GLKVector3*) tgaInfo->imageData;
	GLKVector3 value = ptr[pos.x + pos.y * tgaInfo->width];

	return value;
}

-(void) updateAtlasValueAt:(ccGridSize)pos withValue:(GLKVector3)value withIndex:(NSUInteger)idx
{
	ccV3F_C4B_T2F_Quad quad;

	NSInteger x = pos.x;
	NSInteger y = pos.y;
    //TODO
	float row = (value.r / itemsPerRow_);
	float col = (value.r / itemsPerRow_);

	float textureWide = [[_textureAtlas texture] pixelsWide];
	float textureHigh = [[_textureAtlas texture] pixelsHigh];

	float itemWidthInPixels = _itemSize.width * CC_CONTENT_SCALE_FACTOR();
    float itemHeightInPixels = _itemSize.height * CC_CONTENT_SCALE_FACTOR();


#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
	float left		= (2*row*itemWidthInPixels+1)/(2*textureWide);
	float right		= left+(itemWidthInPixels*2-2)/(2*textureWide);
	float top		= (2*col*itemHeightInPixels+1)/(2*textureHigh);
	float bottom	= top+(itemHeightInPixels*2-2)/(2*textureHigh);
#else
	float left		= (row*itemWidthInPixels)/textureWide;
	float right		= left+itemWidthInPixels/textureWide;
	float top		= (col*itemHeightInPixels)/textureHigh;
	float bottom	= top+itemHeightInPixels/textureHigh;
#endif


	quad.tl.texCoords.u = left;
	quad.tl.texCoords.v = top;
	quad.tr.texCoords.u = right;
	quad.tr.texCoords.v = top;
	quad.bl.texCoords.u = left;
	quad.bl.texCoords.v = bottom;
	quad.br.texCoords.u = right;
	quad.br.texCoords.v = bottom;

    CGFloat itemWidth_ = _itemSize.width;
    CGFloat itemHeight_ = _itemSize.height;
    
	quad.bl.vertices.x = (int) (x * itemWidth_);
	quad.bl.vertices.y = (int) (y * itemHeight_);
	quad.bl.vertices.z = 0.0f;
	quad.br.vertices.x = (int)(x * itemWidth_ + itemWidth_);
	quad.br.vertices.y = (int)(y * itemHeight_);
	quad.br.vertices.z = 0.0f;
	quad.tl.vertices.x = (int)(x * itemWidth_);
	quad.tl.vertices.y = (int)(y * itemHeight_ + itemHeight_);
	quad.tl.vertices.z = 0.0f;
	quad.tr.vertices.x = (int)(x * itemWidth_ + itemWidth_);
	quad.tr.vertices.y = (int)(y * itemHeight_ + itemHeight_);
	quad.tr.vertices.z = 0.0f;

	GLKVector4 color = { {_color.r, _color.g, _color.b, _opacity} };
	quad.tr.colors = color;
	quad.tl.colors = color;
	quad.br.colors = color;
	quad.bl.colors = color;
	[_textureAtlas updateQuad:&quad atIndex:idx];
}

-(void) updateAtlasValues
{
	NSAssert( tgaInfo != nil, @"tgaInfo must be non-nil");


	int total = 0;

	for(int x = 0;x < tgaInfo->width; x++ ) {
		for(int y = 0; y < tgaInfo->height; y++ ) {
			if( total < itemsToRender ) {
				GLKVector3 *ptr = (GLKVector3*) tgaInfo->imageData;
				GLKVector3 value = ptr[x + y * tgaInfo->width];

				if( value.r != 0 ) {
					[self updateAtlasValueAt:ccg(x,y) withValue:value withIndex:total];

					NSString *key = [NSString stringWithFormat:@"%d,%d", x,y];
					NSNumber *num = [NSNumber numberWithInt:total];
					[posToAtlasIndex setObject:num forKey:key];

					total++;
				}
			}
		}
	}
}
@end
