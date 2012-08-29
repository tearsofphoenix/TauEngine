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
#import "CCSpriteBatchNode.h"
#import "CCSprite.h"
#import "CCSpriteFrame.h"
#import "CCSpriteFrameCache.h"
#import "CCAnimation.h"
#import "CCAnimationCacheService.h"
#import "CCTextureCache.h"

#import "CCShaderCache.h"
#import "ccGLStateCache.h"
#import "CCGLProgram.h"
#import "CCDirector.h"
#import "Support/CGPointExtension.h"
#import "Support/TransformUtils.h"

#import "Support/OpenGL_Internal.h"

// external


#pragma mark -
#pragma mark CCSprite

#if CC_SPRITEBATCHNODE_RENDER_SUBPIXEL
#define RENDER_IN_SUBPIXEL
#else
#define RENDER_IN_SUBPIXEL(__A__) ( (int)(__A__))
#endif


@interface CCSprite ()
-(void) setTextureCoords:(CGRect)rect;
-(void) updateBlendFunc;
-(void) setReorderChildDirtyRecursively;
@end

@implementation CCSprite

@synthesize dirty = dirty_;
@synthesize quad = quad_;
@synthesize atlasIndex = atlasIndex_;
@synthesize textureRect = rect_;
@synthesize textureRectRotated = rectRotated_;
@synthesize blendFunc = _blendFunc;
@synthesize textureAtlas = _textureAtlas;
@synthesize offsetPosition = offsetPosition_;

-(id) init
{
	return [self initWithTexture:nil rect:CGRectZero];
}

// designated initializer
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
	if( (self = [super init]) )
	{
		// shader program
		[self setShaderProgram: CCShaderCacheGetProgramByName(kCCShader_PositionTextureColor)];
        
		dirty_ = recursiveDirty_ = NO;
        
		opacityModifyRGB_			= YES;
		_opacity					= 255;
		_color = colorUnmodified_	= ccWHITE;
        
		_blendFunc.src = CC_BLEND_SRC;
		_blendFunc.dst = CC_BLEND_DST;
        
		flipY_ = flipX_ = NO;
        
		// default transform anchor: center
		_anchorPoint =  ccp(0.5f, 0.5f);
        
		// zwoptex default values
		offsetPosition_ = CGPointZero;
        
		hasChildren_ = NO;
		batchNode_ = nil;
        
		// clean the Quad
		bzero(&quad_, sizeof(quad_));
        
		// Atlas: Color
		ccColor4B tmpColor = {255,255,255,255};
		quad_.bl.colors = tmpColor;
		quad_.br.colors = tmpColor;
		quad_.tl.colors = tmpColor;
		quad_.tr.colors = tmpColor;
        
		[self setTexture:texture];
		[self setTextureRect:rect rotated:rotated untrimmedSize:rect.size];
        
        
		// by default use "Self Render".
		// if the sprite is added to a batchnode, then it will automatically switch to "batchnode Render"
		[self setBatchNode:nil];
        
	}
	return self;
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	return [self initWithTexture:texture rect:rect rotated:NO];
}

-(id) initWithTexture:(CCTexture2D*)texture
{
	NSAssert(texture!=nil, @"Invalid texture for sprite");
    
	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;
	return [self initWithTexture:texture rect:rect];
}

-(id) initWithFile:(NSString*)filename
{
	NSAssert(filename != nil, @"Invalid filename for sprite");
    
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: filename];
	if( texture ) {
		CGRect rect = CGRectZero;
		rect.size = texture.contentSize;
		return [self initWithTexture:texture rect:rect];
	}
    
	[self release];
	return nil;
}

-(id) initWithFile:(NSString*)filename rect:(CGRect)rect
{
	NSAssert(filename!=nil, @"Invalid filename for sprite");
    
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: filename];
	if( texture )
		return [self initWithTexture:texture rect:rect];
    
	[self release];
	return nil;
}

- (id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame
{
	NSAssert(spriteFrame!=nil, @"Invalid spriteFrame for sprite");
    
	id ret = [self initWithTexture:spriteFrame.texture rect:spriteFrame.rect];
	[self setDisplayFrame:spriteFrame];
	return ret;
}

-(id)initWithSpriteFrameName:(NSString*)spriteFrameName
{
	NSAssert(spriteFrameName!=nil, @"Invalid spriteFrameName for sprite");
    
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
	return [self initWithSpriteFrame:frame];
}

- (id) initWithCGImage:(CGImageRef)image key:(NSString*)key
{
	NSAssert(image!=nil, @"Invalid CGImageRef for sprite");
    
	// XXX: possible bug. See issue #349. New API should be added
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addCGImage:image forKey:key];
    
	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;
    
	return [self initWithTexture:texture rect:rect];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Rect = (%.2f,%.2f,%.2f,%.2f) | tag = %ld | atlasIndex = %ld>", [self class], self,
			rect_.origin.x, rect_.origin.y, rect_.size.width, rect_.size.height,
			(long)[self tag],
			(unsigned long)atlasIndex_
            ];
}

- (void) dealloc
{
	[texture_ release];
	[super dealloc];
}

-(CCSpriteBatchNode*) batchNode
{
	return batchNode_;
}

-(void) setBatchNode:(CCSpriteBatchNode *)batchNode
{
	batchNode_ = batchNode; // weak reference
    
	// self render
	if( ! batchNode ) {
		atlasIndex_ = CCSpriteIndexNotInitialized;
		_textureAtlas = nil;
		dirty_ = recursiveDirty_ = NO;
        
		float x1 = offsetPosition_.x;
		float y1 = offsetPosition_.y;
		float x2 = x1 + rect_.size.width;
		float y2 = y1 + rect_.size.height;
		quad_.bl.vertices = GLKVector3Make( x1, y1, 0 );
		quad_.br.vertices = GLKVector3Make( x2, y1, 0 );
		quad_.tl.vertices = GLKVector3Make( x1, y2, 0 );
		quad_.tr.vertices = GLKVector3Make( x2, y2, 0 );
        
	} else {
        
		// using batch
		transformToBatch_ = CGAffineTransformIdentity;
		_textureAtlas = [batchNode textureAtlas]; // weak ref
	}
}

-(void) setTextureRect:(CGRect)rect
{
	[self setTextureRect:rect rotated:NO untrimmedSize:rect.size];
}

-(void) setTextureRect:(CGRect)rect rotated:(BOOL)rotated untrimmedSize:(CGSize)untrimmedSize
{
	rectRotated_ = rotated;
    
	[self setContentSize:untrimmedSize];
	[self setVertexRect:rect];
	[self setTextureCoords:rect];
    
	CGPoint relativeOffset = unflippedOffsetPositionFromCenter_;
    
	// issue #732
	if( flipX_ )
		relativeOffset.x = -relativeOffset.x;
	if( flipY_ )
		relativeOffset.y = -relativeOffset.y;
    
    
	offsetPosition_.x = relativeOffset.x + (_contentSize.width - rect_.size.width) / 2;
	offsetPosition_.y = relativeOffset.y + (_contentSize.height - rect_.size.height) / 2;
    
    
	// rendering using batch node
	if( batchNode_ ) {
		// update dirty_, don't update recursiveDirty_
		dirty_ = YES;
	}
    
	// self rendering
	else
	{
		// Atlas: Vertex
		float x1 = offsetPosition_.x;
		float y1 = offsetPosition_.y;
		float x2 = x1 + rect_.size.width;
		float y2 = y1 + rect_.size.height;
        
		// Don't update Z.
		quad_.bl.vertices = GLKVector3Make( x1, y1, 0 );
		quad_.br.vertices = GLKVector3Make( x2, y1, 0 );
		quad_.tl.vertices = GLKVector3Make( x1, y2, 0 );
		quad_.tr.vertices = GLKVector3Make( x2, y2, 0 );
	}
}

// override this method to generate "double scale" sprites
-(void) setVertexRect:(CGRect)rect
{
	rect_ = rect;
}

-(void) setTextureCoords:(CGRect)rect
{
	rect = CC_RECT_POINTS_TO_PIXELS(rect);
    
	CCTexture2D *tex	= (batchNode_) ? [_textureAtlas texture] : texture_;
	if(!tex)
		return;
    
	float atlasWidth = (float)tex.pixelsWide;
	float atlasHeight = (float)tex.pixelsHigh;
    
	float left, right ,top , bottom;
    
	if(rectRotated_)
    {
#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		left	= (2*rect.origin.x+1)/(2*atlasWidth);
		right	= left+(rect.size.height*2-2)/(2*atlasWidth);
		top		= (2*rect.origin.y+1)/(2*atlasHeight);
		bottom	= top+(rect.size.width*2-2)/(2*atlasHeight);
#else
		left	= rect.origin.x/atlasWidth;
		right	= (rect.origin.x+rect.size.height) / atlasWidth;
		top		= rect.origin.y/atlasHeight;
		bottom	= (rect.origin.y+rect.size.width) / atlasHeight;
#endif // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
        
		if( flipX_)
			CC_SWAP(top,bottom);
		if( flipY_)
			CC_SWAP(left,right);
        
		quad_.bl.texCoords.u = left;
		quad_.bl.texCoords.v = top;
		quad_.br.texCoords.u = left;
		quad_.br.texCoords.v = bottom;
		quad_.tl.texCoords.u = right;
		quad_.tl.texCoords.v = top;
		quad_.tr.texCoords.u = right;
		quad_.tr.texCoords.v = bottom;
	} else {
#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		left	= (2*rect.origin.x+1)/(2*atlasWidth);
		right	= left + (rect.size.width*2-2)/(2*atlasWidth);
		top		= (2*rect.origin.y+1)/(2*atlasHeight);
		bottom	= top + (rect.size.height*2-2)/(2*atlasHeight);
#else
		left	= rect.origin.x/atlasWidth;
		right	= (rect.origin.x + rect.size.width) / atlasWidth;
		top		= rect.origin.y/atlasHeight;
		bottom	= (rect.origin.y + rect.size.height) / atlasHeight;
#endif // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
        
		if( flipX_)
			CC_SWAP(left,right);
		if( flipY_)
			CC_SWAP(top,bottom);
        
		quad_.bl.texCoords.u = left;
		quad_.bl.texCoords.v = bottom;
		quad_.br.texCoords.u = right;
		quad_.br.texCoords.v = bottom;
		quad_.tl.texCoords.u = left;
		quad_.tl.texCoords.v = top;
		quad_.tr.texCoords.u = right;
		quad_.tr.texCoords.v = top;
	}
}

-(void)updateTransform
{
	NSAssert( batchNode_, @"updateTransform is only valid when CCSprite is being rendered using an CCSpriteBatchNode");
    
	// recaculate matrix only if it is dirty
	if( dirty_ )
    {
        CCNode *parentNode = [self parent];
        
		// If it is not visible, or one of its ancestors is not visible, then do nothing:
		if( !_visible || ( parentNode && parentNode != batchNode_ && ((CCSprite*)parentNode)->shouldBeHidden_) )
        {
			quad_.br.vertices = quad_.tl.vertices = quad_.tr.vertices = quad_.bl.vertices = GLKVector3Make(0,0,0);
			shouldBeHidden_ = YES;
            
		}else
        {
            
			shouldBeHidden_ = NO;
            
			if( ! parentNode || parentNode == batchNode_ )
            {
				transformToBatch_ = [self nodeToParentTransform];
                
            }else {
				NSAssert( [parentNode isKindOfClass:[CCSprite class]], @"Logic error in CCSprite. Parent must be a CCSprite");
                
				transformToBatch_ = CGAffineTransformConcat( [self nodeToParentTransform] , ((CCSprite*)parentNode)->transformToBatch_ );
			}
            
			//
			// calculate the Quad based on the Affine Matrix
			//
            
			CGSize size = rect_.size;
            
			float x1 = offsetPosition_.x;
			float y1 = offsetPosition_.y;
            
			float x2 = x1 + size.width;
			float y2 = y1 + size.height;
			float x = transformToBatch_.tx;
			float y = transformToBatch_.ty;
            
			float cr = transformToBatch_.a;
			float sr = transformToBatch_.b;
			float cr2 = transformToBatch_.d;
			float sr2 = -transformToBatch_.c;
			float ax = x1 * cr - y1 * sr2 + x;
			float ay = x1 * sr + y1 * cr2 + y;
            
			float bx = x2 * cr - y1 * sr2 + x;
			float by = x2 * sr + y1 * cr2 + y;
            
			float cx = x2 * cr - y2 * sr2 + x;
			float cy = x2 * sr + y2 * cr2 + y;
            
			float dx = x1 * cr - y2 * sr2 + x;
			float dy = x1 * sr + y2 * cr2 + y;
            
            CGFloat vertexZ = [self vertexZ];
            
			quad_.bl.vertices = GLKVector3Make( RENDER_IN_SUBPIXEL(ax), RENDER_IN_SUBPIXEL(ay), vertexZ );
			quad_.br.vertices = GLKVector3Make( RENDER_IN_SUBPIXEL(bx), RENDER_IN_SUBPIXEL(by), vertexZ );
			quad_.tl.vertices = GLKVector3Make( RENDER_IN_SUBPIXEL(dx), RENDER_IN_SUBPIXEL(dy), vertexZ );
			quad_.tr.vertices = GLKVector3Make( RENDER_IN_SUBPIXEL(cx), RENDER_IN_SUBPIXEL(cy), vertexZ );
		}
        
		[_textureAtlas updateQuad:&quad_ atIndex:atlasIndex_];
		dirty_ = recursiveDirty_ = NO;
	}
    
	// recursively iterate over children
	if( hasChildren_ )
    {
		[(NSArray *)_children makeObjectsPerformSelector:@selector(updateTransform)];
    }
    
#if CC_SPRITE_DEBUG_DRAW
	// draw bounding box
	CGPoint vertices[4] = {
		ccp( quad_.bl.vertices.x, quad_.bl.vertices.y ),
		ccp( quad_.br.vertices.x, quad_.br.vertices.y ),
		ccp( quad_.tr.vertices.x, quad_.tr.vertices.y ),
		ccp( quad_.tl.vertices.x, quad_.tl.vertices.y ),
	};
	ccDrawPoly(vertices, 4, YES);
#endif // CC_SPRITE_DEBUG_DRAW
    
}

#pragma mark CCSprite - draw

-(void) draw
{
	CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"CCSprite - draw");
    
	NSAssert(!batchNode_, @"If CCSprite is being rendered by CCSpriteBatchNode, CCSprite#draw SHOULD NOT be called");
    
	CC_NODE_DRAW_SETUP();
    
	CCGLBlendFunc( _blendFunc.src, _blendFunc.dst );
    
	ccGLBindTexture2D( [texture_ name] );
    
	//
	// Attributes
	//
    
	VEGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );
    
#define kQuadSize sizeof(quad_.bl)
	long offset = (long)&quad_;
    
	// vertex
	NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
    
	// texCoods
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
    
	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
    
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
	CHECK_GL_ERROR_DEBUG();
    
    
#if CC_SPRITE_DEBUG_DRAW == 1
	// draw bounding box
	CGPoint vertices[4]={
		ccp(quad_.tl.vertices.x,quad_.tl.vertices.y),
		ccp(quad_.bl.vertices.x,quad_.bl.vertices.y),
		ccp(quad_.br.vertices.x,quad_.br.vertices.y),
		ccp(quad_.tr.vertices.x,quad_.tr.vertices.y),
	};
	ccDrawPoly(vertices, 4, YES);
#elif CC_SPRITE_DEBUG_DRAW == 2
	// draw texture box
	CGSize s = self.textureRect.size;
	CGPoint offsetPix = self.offsetPosition;
	CGPoint vertices[4] = {
		ccp(offsetPix.x,offsetPix.y), ccp(offsetPix.x+s.width,offsetPix.y),
		ccp(offsetPix.x+s.width,offsetPix.y+s.height), ccp(offsetPix.x,offsetPix.y+s.height)
	};
	ccDrawPoly(vertices, 4, YES);
#endif // CC_SPRITE_DEBUG_DRAW
    
	CC_INCREMENT_GL_DRAWS(1);
    
	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"CCSprite - draw");
}

#pragma mark CCSprite - CCNode overrides

-(void) addChild:(CCSprite*)child z:(NSInteger)z
{
	NSAssert( child != nil, @"Argument must be non-nil");
    
	if( batchNode_ )
    {
		NSAssert( [child isKindOfClass:[CCSprite class]], @"CCSprite only supports CCSprites as children when using CCSpriteBatchNode");
		NSAssert( child.texture.name == _textureAtlas.texture.name, @"CCSprite is not using the same texture id");
        
		//put it in descendants array of batch node
		[batchNode_ appendChild:child];
        
		if (!_isReorderChildDirty)
			[self setReorderChildDirtyRecursively];
	}
    
	//CCNode already sets _isReorderChildDirty so this needs to be after batchNode check
    
	[super addChild:child z:z];
    
	hasChildren_ = YES;
}

-(void) reorderChild:(CCSprite*)child z:(NSInteger)z
{
	NSAssert( child != nil, @"Child must be non-nil");
	NSAssert( [(NSArray *)_children containsObject:child], @"Child doesn't belong to Sprite" );
    
	if( z == child.zOrder )
		return;
    
	if( batchNode_ && ! _isReorderChildDirty)
	{
		[self setReorderChildDirtyRecursively];
		[batchNode_ reorderBatch:YES];
	}
    
	[super reorderChild:child z:z];
}

-(void)removeChild: (CCSprite *)sprite cleanup:(BOOL)doCleanup
{
	if( batchNode_ )
		[batchNode_ removeSpriteFromAtlas:sprite];
    
	[super removeChild:sprite cleanup:doCleanup];
    
	hasChildren_ = ( CFArrayGetCount(_children) > 0 );
}

-(void)removeAllChildrenWithCleanup:(BOOL)doCleanup
{
	if( batchNode_ )
    {
		for(CCSprite *child in (NSArray *)_children)
        {
			[batchNode_ removeSpriteFromAtlas:child];
        }
	}
    
	[super removeAllChildrenWithCleanup:doCleanup];
    
	hasChildren_ = NO;
}

- (void) sortAllChildren
{
	if (_isReorderChildDirty)
	{
        
        [(NSMutableArray *)_children sortUsingComparator: (^NSComparisonResult(CCNode *obj1, CCNode *obj2)
                                                           {
                                                               NSInteger z1 = [obj1 zOrder];
                                                               NSInteger z2 = [obj2 zOrder];
                                                               if (z1 < z2)
                                                               {
                                                                   return NSOrderedAscending;
                                                               }
                                                               if (z1 > z2)
                                                               {
                                                                   return NSOrderedDescending;
                                                               }
                                                               return NSOrderedSame;
                                                           })];
       
		if ( batchNode_)
        {
			[(NSArray *)_children makeObjectsPerformSelector:@selector(sortAllChildren)];
        }
        
		_isReorderChildDirty=NO;
	}
}

//
// CCNode property overloads
// used only when parent is CCSpriteBatchNode
//
#pragma mark CCSprite - property overloads

-(void) setReorderChildDirtyRecursively
{
	//only set parents flag the first time
    
	if ( ! _isReorderChildDirty )
	{
		_isReorderChildDirty = YES;
		CCNode* node = [self parent];
		while (node && node != batchNode_)
		{
			[(CCSprite*)node setReorderChildDirtyRecursively];
			node = [node parent];
		}
	}
}

-(void) setDirtyRecursively:(BOOL)b
{
	dirty_ = recursiveDirty_ = b;
	// recursively set dirty
	if( hasChildren_ )
    {
		for(CCSprite *child in (NSArray *)_children)
        {
			[child setDirtyRecursively:YES];
        }
	}
}

// XXX HACK: optimization
#define SET_DIRTY_RECURSIVELY() {									\
if( batchNode_ && ! recursiveDirty_ ) {	\
dirty_ = recursiveDirty_ = YES;				\
if( hasChildren_)							\
[self setDirtyRecursively:YES];			\
}											\
}

-(void)setPosition:(CGPoint)pos
{
	[super setPosition:pos];
	SET_DIRTY_RECURSIVELY();
}

-(void)setRotation:(float)rot
{
	[super setRotation:rot];
	SET_DIRTY_RECURSIVELY();
}

-(void)setSkewX:(float)sx
{
	[super setSkewX:sx];
	SET_DIRTY_RECURSIVELY();
}

-(void)setSkewY:(float)sy
{
	[super setSkewY:sy];
	SET_DIRTY_RECURSIVELY();
}

-(void)setScaleX:(float) sx
{
	[super setScaleX:sx];
	SET_DIRTY_RECURSIVELY();
}

-(void)setScaleY:(float) sy
{
	[super setScaleY:sy];
	SET_DIRTY_RECURSIVELY();
}

-(void)setScale:(float) s
{
	[super setScale:s];
	SET_DIRTY_RECURSIVELY();
}

-(void) setVertexZ:(float)z
{
	[super setVertexZ:z];
	SET_DIRTY_RECURSIVELY();
}

-(void)setAnchorPoint:(CGPoint)anchor
{
	[super setAnchorPoint:anchor];
	SET_DIRTY_RECURSIVELY();
}

-(void) setIgnoreAnchorPointForPosition:(BOOL)value
{
	NSAssert( ! batchNode_, @"ignoreAnchorPointForPosition is invalid in CCSprite");
	[super setIgnoreAnchorPointForPosition:value];
}

-(void)setVisible:(BOOL)v
{
	[super setVisible:v];
	SET_DIRTY_RECURSIVELY();
}

-(void)setFlipX:(BOOL)b
{
	if( flipX_ != b ) {
		flipX_ = b;
		[self setTextureRect:rect_ rotated:rectRotated_ untrimmedSize:_contentSize];
	}
}
-(BOOL) flipX
{
	return flipX_;
}

-(void) setFlipY:(BOOL)b
{
	if( flipY_ != b ) {
		flipY_ = b;
		[self setTextureRect:rect_ rotated:rectRotated_ untrimmedSize:_contentSize];
	}
}
-(BOOL) flipY
{
	return flipY_;
}

//
// RGBA protocol
//
#pragma mark CCSprite - RGBA protocol
-(void) updateColor
{
	ccColor4B color4 = {_color.r, _color.g, _color.b, _opacity};
    
	quad_.bl.colors = color4;
	quad_.br.colors = color4;
	quad_.tl.colors = color4;
	quad_.tr.colors = color4;
    
	// renders using batch node
	if( batchNode_ ) {
		if( atlasIndex_ != CCSpriteIndexNotInitialized)
			[_textureAtlas updateQuad:&quad_ atIndex:atlasIndex_];
		else
			// no need to set it recursively
			// update dirty_, don't update recursiveDirty_
			dirty_ = YES;
	}
	// self render
	// do nothing
}

-(GLubyte) opacity
{
	return _opacity;
}

-(void) setOpacity:(GLubyte) anOpacity
{
	_opacity			= anOpacity;
    
	// special opacity for premultiplied textures
	if( opacityModifyRGB_ )
		[self setColor: colorUnmodified_];
    
	[self updateColor];
}

- (ccColor4B) color
{
	if(opacityModifyRGB_)
		return colorUnmodified_;
    
	return _color;
}

-(void) setColor:(ccColor4B)color3
{
	_color = colorUnmodified_ = color3;
    
	if( opacityModifyRGB_ ){
		_color.r = color3.r * _opacity/255.0f;
		_color.g = color3.g * _opacity/255.0f;
		_color.b = color3.b * _opacity/255.0f;
	}
    
	[self updateColor];
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

//
// Frames
//
#pragma mark CCSprite - Frames

-(void) setDisplayFrame:(CCSpriteFrame*)frame
{
	unflippedOffsetPositionFromCenter_ = frame.offset;
    
	CCTexture2D *newTexture = [frame texture];
	// update texture before updating texture rect
	if ( newTexture.name != texture_.name )
		[self setTexture: newTexture];
    
	// update rect
	rectRotated_ = frame.rotated;
    
	[self setTextureRect:frame.rect rotated:rectRotated_ untrimmedSize:frame.originalSize];
}

-(void) setDisplayFrameWithAnimationName: (NSString*) animationName index:(int) frameIndex
{
	NSAssert( animationName, @"CCSprite#setDisplayFrameWithAnimationName. animationName must not be nil");
    
    VSC(CCAnimationCacheServiceID, CCAnimationCacheServiceAnimationByName, [NSArray arrayWithObject: animationName],
        (^(NSString *action, CCAnimation *animation)
         
         {
             
             NSAssert( animation, @"CCSprite#setDisplayFrameWithAnimationName: Frame not found");
             
             CCAnimationFrame *frame = [[animation frames] objectAtIndex:frameIndex];
             
             NSAssert( frame, @"CCSprite#setDisplayFrame. Invalid frame");
             
             [self setDisplayFrame: [frame spriteFrame]];
             
         }));
    
}


-(BOOL) isFrameDisplayed:(CCSpriteFrame*)frame
{
	CGRect r = [frame rect];
	return ( CGRectEqualToRect(r, rect_) &&
			frame.texture.name == self.texture.name &&
			CGPointEqualToPoint( frame.offset, unflippedOffsetPositionFromCenter_ ) );
}

-(CCSpriteFrame*) displayFrame
{
	CCSpriteFrame *frame = [[[CCSpriteFrame alloc] initWithTexture: texture_
                                                      rectInPixels: CC_RECT_POINTS_TO_PIXELS(rect_)] autorelease];
    [frame setRotated: rectRotated_];
    [frame setOffset: unflippedOffsetPositionFromCenter_];
    [frame setOriginalSize: CC_SIZE_POINTS_TO_PIXELS(_contentSize)];
    return  frame;
}

#pragma mark CCSprite - CocosNodeTexture protocol

-(void) updateBlendFunc
{
	NSAssert( ! batchNode_, @"CCSprite: updateBlendFunc doesn't work when the sprite is rendered using a CCSpriteBatchNode");
    
	// it is possible to have an untextured sprite
	if( !texture_ || ! [texture_ hasPremultipliedAlpha] ) {
		_blendFunc.src = GL_SRC_ALPHA;
		_blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
		[self setOpacityModifyRGB:NO];
	} else {
		_blendFunc.src = CC_BLEND_SRC;
		_blendFunc.dst = CC_BLEND_DST;
		[self setOpacityModifyRGB:YES];
	}
}

-(void) setTexture:(CCTexture2D*)texture
{
	// If batchnode, then texture id should be the same
	NSAssert( !batchNode_ || texture.name == batchNode_.texture.name , @"CCSprite: Batched sprites should use the same texture as the batchnode");
    
	// accept texture==nil as argument
	NSAssert( !texture || [texture isKindOfClass:[CCTexture2D class]], @"setTexture expects a CCTexture2D. Invalid argument");
    
	if( ! batchNode_ && texture_ != texture ) {
		[texture_ release];
		texture_ = [texture retain];
        
		[self updateBlendFunc];
	}
}

-(CCTexture2D*) texture
{
	return texture_;
}

@end
