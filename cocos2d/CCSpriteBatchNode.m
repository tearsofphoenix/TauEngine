/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Matt Oswald
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
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
#import "CCSprite.h"
#import "CCSpriteBatchNode.h"
#import "CCGrid.h"

#import "CCTextureCache.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "ccGLStateCache.h"
#import "CCDirector.h"
#import "Support/CGPointExtension.h"
#import "Support/TransformUtils.h"


// external


static const NSUInteger defaultCapacity = 29;

#pragma mark -
#pragma mark CCSpriteBatchNode

@interface CCSpriteBatchNode (private)
-(void) updateAtlasIndex:(CCSprite*) sprite currentIndex:(NSInteger*) curIndex;
-(void) swap:(NSInteger) oldIndex withNewIndex:(NSInteger) newIndex;
-(void) updateBlendFunc;
@end

@implementation CCSpriteBatchNode

@synthesize textureAtlas = _textureAtlas;
@synthesize blendFunc = _blendFunc;
@synthesize descendants = _descendants;


-(id)init
{
    return [self initWithTexture:[[[CCTexture2D alloc] init] autorelease] capacity:0];
}

-(id)initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity
{
	CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:fileImage];
	return [self initWithTexture:tex capacity:capacity];
}

// Designated initializer
-(id)initWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity
{
	if( (self=[super init])) {
        
		_blendFunc.src = CC_BLEND_SRC;
		_blendFunc.dst = CC_BLEND_DST;
		_textureAtlas = [[CCAtlasTexture alloc] initWithTexture:tex capacity:capacity];
        
		[self updateBlendFunc];
        
		// no lazy alloc in this node
		_children = CFArrayCreateMutable(CFAllocatorGetDefault(), capacity, NULL);
		_descendants = CFArrayCreateMutable(CFAllocatorGetDefault(), capacity, NULL);
        
		[self setShaderProgram: CCShaderCacheGetProgramByName(kCCShader_PositionTextureColor)];
	}
    
	return self;
}


- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Tag = %ld>", [self class], self, (long)[self tag] ];
}

-(void)dealloc
{
	[_textureAtlas release];
    CFRelease(_descendants);
    
	[super dealloc];
}

#pragma mark CCSpriteBatchNode - composition

// override visit.
// Don't call visit on its children
-(void) renderInContext:(VEContext *)context
{
	CC_PROFILER_START_CATEGORY(kCCProfilerCategoryBatchSprite, @"CCSpriteBatchNode - visit");
    
	NSAssert([self parent] != nil, @"CCSpriteBatchNode should NOT be root node");
    
	// CAREFUL:
	// This visit is almost identical to CCNode#visit
	// with the exception that it doesn't call visit on its children
	//
	// The alternative is to have a void CCSprite#visit, but
	// although this is less mantainable, is faster
	//
	if (!_visible)
		return;
    
	VEGLPushMatrix();
    
	if ( _grid && _grid.active)
    {
		[_grid beforeDraw];
		[self transformAncestors];
	}
    
	[self sortAllChildren];
	[self transform];
	[self draw];
    
	if ( _grid && _grid.active)
		[_grid afterDraw:self];
    
	VEGLPopMatrix();
    
	_orderOfArrival = 0;
    
	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategoryBatchSprite, @"CCSpriteBatchNode - visit");
}

// override addChild:
-(void) addChild:(CCSprite*)child z:(NSInteger)z
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( [child isKindOfClass:[CCSprite class]], @"CCSpriteBatchNode only supports CCSprites as children");
	NSAssert( child.texture.name == _textureAtlas.texture.name, @"CCSprite is not using the same texture id");
    
	[super addChild:child z:z];
    
	[self appendChild:child];
}

// override reorderChild
-(void) reorderChild:(CCSprite*)child z:(NSInteger)z
{
	NSAssert( child != nil, @"Child must be non-nil");
	NSAssert( [(NSArray *)_children containsObject:child], @"Child doesn't belong to Sprite" );
    
	if( z == child.zOrder )
		return;
    
	//set the z-order and sort later
	[super reorderChild:child z:z];
}

// override removeChild:
-(void)removeChild: (CCSprite *)sprite cleanup:(BOOL)doCleanup
{
	// explicit nil handling
	if (sprite == nil)
		return;
    
	NSAssert([(NSArray *)_children containsObject:sprite], @"CCSpriteBatchNode doesn't contain the sprite. Can't remove it");
    
	// cleanup before removing
	[self removeSpriteFromAtlas:sprite];
    
	[super removeChild:sprite cleanup:doCleanup];
}

-(void)removeChildAtIndex:(NSUInteger)index cleanup:(BOOL)doCleanup
{
	[self removeChild: CFArrayGetValueAtIndex(_children, index)
              cleanup: doCleanup];
}

-(void)removeAllChildrenWithCleanup:(BOOL)doCleanup
{
	// Invalidate atlas index. issue #569
	// useSelfRender should be performed on all descendants. issue #1216
	[(NSArray*)_descendants makeObjectsPerformSelector:@selector(setBatchNode:) withObject:nil];
    
	[super removeAllChildrenWithCleanup:doCleanup];
    
	[(NSMutableArray *)_descendants removeAllObjects];
	[_textureAtlas removeAllQuads];
}

//override sortAllChildren
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
        
        
		//sorted now check all children
		if (CFArrayGetCount(_children) > 0)
		{
			//first sort all children recursively based on zOrder
			[(NSArray *)_children makeObjectsPerformSelector:@selector(sortAllChildren)];
            
			NSInteger index=0;
            
			//fast dispatch, give every child a new atlasIndex based on their relative zOrder (keep parent -> child relations intact)
			// and at the same time reorder descedants and the quads to the right index
			for(CCSprite *child in (NSArray *)_children)
            {
				[self updateAtlasIndex:child currentIndex:&index];
            }
		}
        
		_isReorderChildDirty=NO;
	}
}

-(void) updateAtlasIndex:(CCSprite*) sprite currentIndex:(NSInteger*) curIndex
{
	CFMutableArrayRef array = (CFMutableArrayRef)[sprite children];
	NSUInteger count = CFArrayGetCount(array);
	NSInteger oldIndex;
    
	if( count == 0 )
	{
		oldIndex = sprite.atlasIndex;
		sprite.atlasIndex = *curIndex;
		sprite.orderOfArrival = 0;
		if (oldIndex != *curIndex)
			[self swap:oldIndex withNewIndex:*curIndex];
		(*curIndex)++;
	}
	else
	{
		BOOL needNewIndex=YES;
        
		if ([((CCSprite*) CFArrayGetValueAtIndex(array, 0)) zOrder] >= 0)
		{
			//all children are in front of the parent
			oldIndex = sprite.atlasIndex;
			sprite.atlasIndex = *curIndex;
			sprite.orderOfArrival = 0;
			if (oldIndex != *curIndex)
				[self swap:oldIndex withNewIndex:*curIndex];
			(*curIndex)++;
            
			needNewIndex = NO;
		}
        
		for(CCSprite* child in (NSArray *)array)
		{
			if (needNewIndex && child.zOrder >= 0)
			{
				oldIndex = sprite.atlasIndex;
				sprite.atlasIndex = *curIndex;
				sprite.orderOfArrival = 0;
				if (oldIndex != *curIndex)
					[self swap:oldIndex withNewIndex:*curIndex];
				(*curIndex)++;
				needNewIndex = NO;
                
			}
            
			[self updateAtlasIndex:child currentIndex:curIndex];
		}
        
		if (needNewIndex)
		{//all children have a zOrder < 0)
			oldIndex=sprite.atlasIndex;
			sprite.atlasIndex=*curIndex;
			sprite.orderOfArrival=0;
			if (oldIndex!=*curIndex)
				[self swap:oldIndex withNewIndex:*curIndex];
			(*curIndex)++;
		}
	}
}

- (void) swap:(NSInteger) oldIndex withNewIndex:(NSInteger) newIndex
{
	ccV3F_C4B_T2F_Quad* quads = _textureAtlas.quads;
    
	ccV3F_C4B_T2F_Quad tempItemQuad=quads[oldIndex];
    
	//update the index of other swapped item
	((CCSprite*) CFArrayGetValueAtIndex(_descendants, newIndex)).atlasIndex=oldIndex;
    CFArrayExchangeValuesAtIndices(_descendants, oldIndex, newIndex);
    
	quads[oldIndex]=quads[newIndex];
	quads[newIndex]=tempItemQuad;
}

- (void) reorderBatch:(BOOL) reorder
{
	_isReorderChildDirty=reorder;
}

#pragma mark CCSpriteBatchNode - draw
-(void) draw
{
	CC_PROFILER_START(@"CCSpriteBatchNode - draw");
    
	// Optimization: Fast Dispatch
	if( _textureAtlas.totalQuads == 0 )
		return;
    
	CC_NODE_DRAW_SETUP();
    
	[(NSArray *)_children makeObjectsPerformSelector:@selector(updateTransform)];
    
	CCGLBlendFunc( _blendFunc.src, _blendFunc.dst );
    
	[_textureAtlas drawQuads];
    
	CC_PROFILER_STOP(@"CCSpriteBatchNode - draw");
}

#pragma mark CCSpriteBatchNode - private
-(void) increaseAtlasCapacity
{
	// if we're going beyond the current CCAtlasTexture's capacity,
	// all the previously initialized sprites will need to redo their texture coords
	// this is likely computationally expensive
	NSUInteger quantity = (_textureAtlas.capacity + 1) * 4 / 3;
    
	CCLOG(@"cocos2d: CCSpriteBatchNode: resizing TextureAtlas capacity from [%lu] to [%lu].",
		  (long)_textureAtlas.capacity,
		  (long)quantity);
    
    
	if( ! [_textureAtlas resizeCapacity:quantity] ) {
		// serious problems
		CCLOGWARN(@"cocos2d: WARNING: Not enough memory to resize the atlas");
		NSAssert(NO,@"XXX: CCSpriteBatchNode#increaseAtlasCapacity SHALL handle this assert");
	}
}


#pragma mark CCSpriteBatchNode - Atlas Index Stuff

-(NSUInteger) rebuildIndexInOrder:(CCSprite*)node atlasIndex:(NSUInteger)index
{
	for(CCSprite *sprite in (NSArray *)node.children)
    {
		if( sprite.zOrder < 0 )
			index = [self rebuildIndexInOrder:sprite atlasIndex:index];
	}
    
	// ignore self (batch node)
	if( ! [node isEqual:self]) {
		node.atlasIndex = index;
		index++;
	}
    
	for(CCSprite *sprite in (NSArray *)node.children)
    {
        if( sprite.zOrder >= 0 )
        {
            index = [self rebuildIndexInOrder:sprite atlasIndex:index];
        }
    }
    
    return index;
}

-(NSUInteger)highestAtlasIndexInChild: (CCSprite*)sprite
{
    CFMutableArrayRef array = (CFMutableArrayRef)[sprite children];
    NSUInteger count = CFArrayGetCount(array);
    if( count == 0 )
        return sprite.atlasIndex;
    else
        return [self highestAtlasIndexInChild: [(NSArray *)array lastObject]];
}

-(NSUInteger) lowestAtlasIndexInChild:(CCSprite*)sprite
{
    CFMutableArrayRef array = (CFMutableArrayRef)[sprite children];
    NSUInteger count = CFArrayGetCount(array);
    if( count == 0 )
        return sprite.atlasIndex;
    else
        return [self lowestAtlasIndexInChild: CFArrayGetValueAtIndex(array, 0) ];
}


-(NSUInteger)atlasIndexForChild:(CCSprite*)sprite atZ:(NSInteger)z
{
    NSMutableArray *brothers = (NSMutableArray*)[[sprite parent] children];
    NSUInteger childIndex = [brothers indexOfObject: sprite];
    
    // ignore parent Z if parent is batchnode
    BOOL ignoreParent = ( sprite.parent == self );
    CCSprite *previous = nil;
    if( childIndex > 0 )
        previous = [brothers objectAtIndex:childIndex-1];
    
    // first child of the sprite sheet
    if( ignoreParent ) {
        if( childIndex == 0 )
            return 0;
        // else
        return [self highestAtlasIndexInChild: previous] + 1;
    }
    
    // parent is a CCSprite, so, it must be taken into account
    
    // first child of an CCSprite ?
    if( childIndex == 0 )
    {
        CCSprite *p = (CCSprite*) sprite.parent;
        
        // less than parent and brothers
        if( z < 0 )
            return p.atlasIndex;
        else
            return p.atlasIndex+1;
        
    } else {
        // previous & sprite belong to the same branch
        if( ( previous.zOrder < 0 && z < 0 )|| (previous.zOrder >= 0 && z >= 0) )
            return [self highestAtlasIndexInChild:previous] + 1;
        
        // else (previous < 0 and sprite >= 0 )
        CCSprite *p = (CCSprite*) sprite.parent;
        return p.atlasIndex + 1;
    }
    
    NSAssert( NO, @"Should not happen. Error calculating Z on Batch Node");
    return 0;
}

#pragma mark CCSpriteBatchNode - add / remove / reorder helper methods
// add child helper
-(void) insertChild:(CCSprite*)sprite inAtlasAtIndex:(NSUInteger)index
{
    [sprite setBatchNode:self];
    [sprite setAtlasIndex:index];
    [sprite setDirty: YES];
    
    if(_textureAtlas.totalQuads == _textureAtlas.capacity)
        [self increaseAtlasCapacity];
    
    ccV3F_C4B_T2F_Quad quad = [sprite quad];
    [_textureAtlas insertQuad:&quad atIndex:index];
    
    CFArrayInsertValueAtIndex(_descendants, index, [sprite retain]);
    
    // update indices
    NSUInteger i = index+1;
    CCSprite *child;
    for(; i < CFArrayGetCount(_descendants); i++)
    {
        child = CFArrayGetValueAtIndex(_descendants, i);
        child.atlasIndex = child.atlasIndex + 1;
    }
    
    // add children recursively
    for(child in (NSArray *)sprite.children)
    {
        NSUInteger idx = [self atlasIndexForChild:child atZ: child.zOrder];
        [self insertChild:child inAtlasAtIndex:idx];
    }
}

// addChild helper, faster than insertChild
-(void) appendChild:(CCSprite*)sprite
{
    _isReorderChildDirty=YES;
    [sprite setBatchNode:self];
    [sprite setDirty: YES];
    
    if(_textureAtlas.totalQuads == _textureAtlas.capacity)
    {
        [self increaseAtlasCapacity];
    }
    
    CFArrayAppendValue(_descendants, [sprite retain]);
    
    NSUInteger index = CFArrayGetCount(_descendants) -1;
    
    sprite.atlasIndex=index;
    
    ccV3F_C4B_T2F_Quad quad = [sprite quad];
    [_textureAtlas insertQuad:&quad atIndex:index];
    
    // add children recursively

    for(CCSprite* child in (NSArray *)[sprite children])
    {
        [self appendChild: child];
    }
}


// remove child helper
-(void) removeSpriteFromAtlas:(CCSprite*)sprite
{
    // remove from TextureAtlas
    [_textureAtlas removeQuadAtIndex:sprite.atlasIndex];
    
    // Cleanup sprite. It might be reused (issue #569)
    [sprite setBatchNode:nil];
    
    NSUInteger index = CFArrayGetFirstIndexOfValue(_descendants, CFRangeMake(0, CFArrayGetCount(_descendants)), sprite);

    if( index != NSNotFound )
    {
        [(NSMutableArray *)_descendants removeObjectAtIndex: index];
        
        // update all sprites beyond this one
        NSUInteger count = CFArrayGetCount(_descendants);
        
        for(; index < count; index++)
        {
            CCSprite *s = CFArrayGetValueAtIndex(_descendants, index);
            s.atlasIndex = s.atlasIndex - 1;
        }
    }
    
    // remove children recursively

    for(CCSprite* child in (NSArray *)[sprite children])
    {
        [self removeSpriteFromAtlas: child];
    }
}

#pragma mark CCSpriteBatchNode - CocosNodeTexture protocol

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
}

-(CCTexture2D*) texture
{
    return _textureAtlas.texture;
}
@end

#pragma mark - CCSpriteBatchNode Extension


@implementation CCSpriteBatchNode (QuadExtension)

-(void) addQuadFromSprite:(CCSprite*)sprite quadIndex:(NSUInteger)index
{
    NSAssert( sprite != nil, @"Argument must be non-nil");
    NSAssert( [sprite isKindOfClass:[CCSprite class]], @"CCSpriteBatchNode only supports CCSprites as children");
    
    
    while(index >= _textureAtlas.capacity || _textureAtlas.capacity == _textureAtlas.totalQuads )
        [self increaseAtlasCapacity];
    
    //
    // update the quad directly. Don't add the sprite to the scene graph
    //
    
    [sprite setBatchNode:self];
    [sprite setAtlasIndex:index];
    
    ccV3F_C4B_T2F_Quad quad = [sprite quad];
    [_textureAtlas insertQuad:&quad atIndex:index];
    
    // XXX: updateTransform will update the textureAtlas too using updateQuad.
    // XXX: so, it should be AFTER the insertQuad
    [sprite setDirty:YES];
    [sprite updateTransform];
}

-(id) addSpriteWithoutQuad:(CCSprite*)child z:(NSUInteger)z
{
    NSAssert( child != nil, @"Argument must be non-nil");
    NSAssert( [child isKindOfClass:[CCSprite class]], @"CCSpriteBatchNode only supports CCSprites as children");
    
    // quad index is Z
    [child setAtlasIndex:z];
    
    // XXX: optimize with a binary search
    int i=0;
    for( CCSprite *c in (NSArray *)_descendants )
    {
        if( c.atlasIndex >= z )
            break;
        i++;
    }
    
    CFArrayInsertValueAtIndex(_descendants, i, [child retain]);
    
    // IMPORTANT: Call super, and not self. Avoid adding it to the texture atlas array
    [super addChild:child z:z];
    
    //#issue 1262 don't use lazy sorting, tiles are added as quads not as sprites, so sprites need to be added in order
    [self reorderBatch:NO];
    return self;
}
@end

