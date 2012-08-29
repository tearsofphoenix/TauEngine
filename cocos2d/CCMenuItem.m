/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
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

#import "CCMenuItem.h"
#import "CCTTFLabel.h"
#import "CCAtlasLabel.h"
#import "CCActionManager.h"

#import "CCSprite.h"
#import "Support/CGPointExtension.h"

static NSUInteger CCFontMenuItem_fontSize = kCCItemSize;
static NSString *CCFontMenuItem_fontName = @"Marker Felt";


#pragma mark -
#pragma mark CCMenuItem

@implementation CCMenuItem

@synthesize selected = _selected;

@synthesize enabled = _enabled;

@synthesize block = _block;

- (id)init
{
	return [self initWithBlock:nil];
}

// Designated initializer
- (id)initWithBlock: (void (^)(id))block
{
	if((self=[super init]) )
    {
		if( block )
        {
			_block = Block_copy(block);
        }
        
		_anchorPoint = ccp(0.5f, 0.5f);
		_enabled = YES;
		_selected = NO;
        
	}
	return self;
}

-(void) dealloc
{
    if (_block)
    {
        Block_release(_block);
    }
    
	[super dealloc];
}

-(void) cleanup
{
    if (_block)
    {
        Block_release(_block);
        _block = nil;
    }
    
	[super cleanup];
}

-(void) activate
{
	if(_enabled && _block)
    {
		_block(self);
    }
}

- (CGRect) rect
{
    CGPoint origin = [self position];
	return CGRectMake( origin.x - _contentSize.width*_anchorPoint.x,
					  origin.y - _contentSize.height*_anchorPoint.y,
					  _contentSize.width, _contentSize.height);
}

- (void)addTarget: (id)target
        forAction: (SEL)selector
{
    if (target && selector)
    {
        __block id tempTarget = target;
        [self setBlock: (^(id sender)
                         {
                             [tempTarget performSelector: selector
                                              withObject: sender];
                         })];
    }
}

@end


#pragma mark -
#pragma mark CCMenuItemLabel

@implementation CCMenuItemLabel

@synthesize disabledColor = disabledColor_;

//
// Designated initializer
//
-(id) initWithLabel: (CCNode<CCLabelProtocol,CCRGBAProtocol> *)label
              block: (void (^)(id))block
{
	if( (self=[self initWithBlock:block]) )
    {
		originalScale_ = 1;
		colorBackup = ccWHITE;
		disabledColor_ = ccc4( 126,126,126, 255);
		self.label = label;
	}
    
	return self;
}

-(CCNode<CCLabelProtocol, CCRGBAProtocol>*) label
{
	return label_;
}

-(void) setLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol>*) label
{
	if( label != label_ )
    {
		[self removeChild:label_ cleanup:YES];
		[self addChild:label];
        
		label_ = label;
		label_.anchorPoint = ccp(0,0);
        
		[self setContentSize:[label_ contentSize]];
	}
}

-(void) setString:(NSString *)string
{
	[label_ setString:string];
	[self setContentSize: [label_ contentSize]];
}

-(void) activate
{
	if(_enabled)
    {
        [_actionManager removeAllActionsFromTarget: self];
        
		self.scale = originalScale_;
        
		[super activate];
	}
}

-(void) setSelected: (BOOL)selected
{
    [super setSelected: selected];
}

-(void) setEnabled:(BOOL)enabled
{
	if( _enabled != enabled )
    {
		if(enabled == NO)
        {
			colorBackup = [label_ color];
			[label_ setColor: disabledColor_];
		}
		else
			[label_ setColor:colorBackup];
	}
    
	[super setEnabled: enabled];
}

- (void) setOpacity: (GLubyte)opacity
{
    [label_ setOpacity:opacity];
}

-(GLubyte) opacity
{
	return [label_ opacity];
}

-(void) setColor:(ccColor4B)color
{
	[label_ setColor: color];
}

- (ccColor4B)color
{
	return [label_ color];
}

@end

#pragma mark  - CCMenuItemAtlasFont

@implementation CCMenuItemAtlasFont

//
// Designated initializer
//
-(id) initWithString: (NSString*)value
         charMapFile: (NSString*)charMapFile
            itemSize: (CGSize)itemSize
        startCharMap: (char)startCharMap
               block: (void(^)(id sender))block
{
	NSAssert( [value length] > 0, @"value length must be greater than 0");
    
	CCAtlasLabel *label = [[CCAtlasLabel alloc] initWithString: value
                                                   charMapFile: charMapFile
                                                      itemSize: itemSize
                                                  startCharMap: startCharMap];
    
	id ret = [self initWithLabel: label
                           block: block];
    
	[label release];
    
	return ret;
    
}

@end


#pragma mark - CCMenuItemFont

@implementation CCMenuItemFont

+(void) setFontSize: (NSUInteger) s
{
	CCFontMenuItem_fontSize = s;
}

+(NSUInteger) fontSize
{
	return CCFontMenuItem_fontSize;
}

+(void) setFontName: (NSString*) n
{
    
    [CCFontMenuItem_fontName release];
    
	CCFontMenuItem_fontName = [n copy];
}

+ (NSString*)fontName
{
	return CCFontMenuItem_fontName;
}

@synthesize fontName = _fontName;
@synthesize fontSize = _fontSize;
//
// Designated initializer
//
-(id) initWithString: (NSString*)string
               block: (void(^)(id sender))block
{
	NSAssert( [string length] > 0, @"Value length must be greater than 0");
    
	_fontName = [_fontName copy];
	_fontSize = CCFontMenuItem_fontSize;
    
	CCTTFLabel *label = [[[CCTTFLabel alloc] initWithString: string
                                                   fontName: _fontName
                                                   fontSize: _fontSize] autorelease];
    
	if((self=[super initWithLabel: label
                            block: block]) )
    {
		// do something ?
	}
    
	return self;
}

-(void) recreateLabel
{
	CCTTFLabel *label = [[CCTTFLabel alloc] initWithString: [label_ string]
                                                  fontName: _fontName
                                                  fontSize: _fontSize];
	[self setLabel: label];
    
	[label release];
}

-(void) setFontSize: (NSUInteger) size
{
    if (_fontSize != size)
    {
        _fontSize = size;
        [self recreateLabel];
    }
}

-(void) setFontName: (NSString*) fontName
{
    if (_fontName != fontName)
    {
        _fontName = [fontName copy];
        [self recreateLabel];
    }
}

@end

#pragma mark - CCMenuItemSprite

@interface CCMenuItemSprite()

- (void)updateImagesVisibility;

@end

@implementation CCMenuItemSprite

@synthesize normalImage=normalImage_, selectedImage=selectedImage_, disabledImage=disabledImage_;

-(id) initWithNormalSprite: (CCNode<CCRGBAProtocol>*)normalSprite
            selectedSprite: (CCNode<CCRGBAProtocol>*)selectedSprite
            disabledSprite: (CCNode<CCRGBAProtocol>*)disabledSprite
                     block: (void(^)(id sender))block
{
	if ( (self = [super initWithBlock:block] ) )
    {        
		self.normalImage = normalSprite;
		self.selectedImage = selectedSprite;
		self.disabledImage = disabledSprite;
        
		[self setContentSize: [normalImage_ contentSize]];
	}
	return self;
}

-(void) setNormalImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != normalImage_ ) {
		image.anchorPoint = ccp(0,0);
        
		[self removeChild:normalImage_ cleanup:YES];
		[self addChild:image];
        
		normalImage_ = image;
        
        [self setContentSize: [normalImage_ contentSize]];
		
		[self updateImagesVisibility];
	}
}

-(void) setSelectedImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != selectedImage_ )
    {
		image.anchorPoint = ccp(0,0);
        
		[self removeChild:selectedImage_ cleanup:YES];
		[self addChild:image];
        
		selectedImage_ = image;
		
		[self updateImagesVisibility];
	}
}

-(void) setDisabledImage:(CCNode <CCRGBAProtocol>*)image
{
	if( image != disabledImage_ )
    {
		image.anchorPoint = ccp(0,0);
        
		[self removeChild:disabledImage_ cleanup:YES];
		[self addChild:image];
        
		disabledImage_ = image;
		
		[self updateImagesVisibility];
	}
}

#pragma mark CCMenuItemSprite - CCRGBAProtocol protocol

- (void) setOpacity: (GLubyte)opacity
{
	[normalImage_ setOpacity:opacity];
	[selectedImage_ setOpacity:opacity];
	[disabledImage_ setOpacity:opacity];
}

-(void) setColor:(ccColor4B)color
{
	[normalImage_ setColor: color];
	[selectedImage_ setColor: color];
	[disabledImage_ setColor: color];
}

-(GLubyte) opacity
{
	return [normalImage_ opacity];
}

-(ccColor4B) color
{
	return [normalImage_ color];
}

-(void)setSelected: (BOOL)selected
{
    if (_selected != selected)
    {
        
        [super setSelected: selected];
        
        if (_selected)
        {
            
            if( selectedImage_ )
            {
                [normalImage_ setVisible:NO];
                [selectedImage_ setVisible:YES];
                [disabledImage_ setVisible:NO];
                
            } else { // there is not selected image
                
                [normalImage_ setVisible:YES];
                [selectedImage_ setVisible:NO];
                [disabledImage_ setVisible:NO];
            }
        }else
        {
            [normalImage_ setVisible:YES];
            [selectedImage_ setVisible:NO];
            [disabledImage_ setVisible:NO];
            
        }
    }
}

- (void)setEnabled:(BOOL)enabled
{
	if( _enabled != enabled )
    {
		[super setEnabled: enabled];
        
		[self updateImagesVisibility];
	}
}


// Helper
-(void) updateImagesVisibility
{
	if( _enabled )
    {
		[normalImage_ setVisible:YES];
		[selectedImage_ setVisible:NO];
		[disabledImage_ setVisible:NO];
		
	} else
    {
		if( disabledImage_ )
        {
			[normalImage_ setVisible:NO];
			[selectedImage_ setVisible:NO];
			[disabledImage_ setVisible:YES];
		} else {
			[normalImage_ setVisible:YES];
			[selectedImage_ setVisible:NO];
			[disabledImage_ setVisible:NO];
		}
	}
}

@end

#pragma mark - CCMenuItemImage

@implementation CCMenuItemImage


-(id) initWithNormalImage:(NSString*)normalI selectedImage:(NSString*)selectedI disabledImage:(NSString*)disabledI block:(void(^)(id sender))block
{
	CCNode<CCRGBAProtocol> *normalImage = [[[CCSprite alloc] initWithFile: normalI] autorelease];
	CCNode<CCRGBAProtocol> *selectedImage = nil;
	CCNode<CCRGBAProtocol> *disabledImage = nil;
    
	if( selectedI )
		selectedImage = [[[CCSprite alloc] initWithFile:selectedI] autorelease];
	if(disabledI)
		disabledImage = [[[CCSprite alloc] initWithFile:disabledI] autorelease];
    
	return [super initWithNormalSprite: normalImage
                        selectedSprite: selectedImage
                        disabledSprite: disabledImage
                                 block: block];
}

//
// Setter of sprite frames
//
-(void) setNormalSpriteFrame:(CCSpriteFrame *)frame
{
    [self setNormalImage: [[[CCSprite alloc] initWithSpriteFrame: frame] autorelease]];
}

-(void) setSelectedSpriteFrame:(CCSpriteFrame *)frame
{
    [self setSelectedImage: [[[CCSprite alloc] initWithSpriteFrame: frame] autorelease]];
}

-(void) setDisabledSpriteFrame:(CCSpriteFrame *)frame
{
    [self setDisabledImage: [[[CCSprite alloc] initWithSpriteFrame: frame] autorelease]];
}

@end

#pragma mark - CCMenuItemToggle

//
// MenuItemToggle
//
@implementation CCMenuItemToggle

@synthesize subItems = subItems_;
@synthesize opacity = _opacity, color = _color;

- (id)initWithItems: (NSArray*)arrayOfItems
              block: (void(^)(id sender))block
{
	if( (self=[super initWithBlock:block] ) )
    {
        
		self.subItems = [NSMutableArray arrayWithArray:arrayOfItems];
        
		selectedIndex_ = NSUIntegerMax;
		[self setSelectedIndex:0];
	}
    
	return self;
}

-(void) dealloc
{
	[subItems_ release];
	[super dealloc];
}

-(void)setSelectedIndex:(NSUInteger)index
{
	if( index != selectedIndex_ )
    {
		selectedIndex_= index;

        [_currentItem removeFromParentAndCleanup:NO];
		
		_currentItem = [subItems_ objectAtIndex: selectedIndex_];

		[self addChild: _currentItem
                     z: 0];
        
		CGSize s = [_currentItem contentSize];
		[self setContentSize: s];
		_currentItem.position = ccp( s.width/2, s.height/2 );
	}
}

-(NSUInteger) selectedIndex
{
	return selectedIndex_;
}


-(void)setSelected: (BOOL)selected
{
	[super setSelected: selected];
	[[subItems_ objectAtIndex:selectedIndex_] setSelected: selected];
}

-(void) activate
{
	// update index
	if( _enabled ) {
		NSUInteger newIndex = (selectedIndex_ + 1) % [subItems_ count];
		[self setSelectedIndex:newIndex];
        
	}
    
	[super activate];
}

- (void)setEnabled: (BOOL)enabled
{
	if( _enabled != enabled )
    {
		[super setEnabled: enabled];
		for(CCMenuItem* item in subItems_)
        {
			[item setEnabled: enabled];
        }
	}
}

-(CCMenuItem*) selectedItem
{
	return [subItems_ objectAtIndex:selectedIndex_];
}

#pragma mark CCMenuItemToggle - CCRGBAProtocol protocol

- (void) setOpacity: (GLubyte)opacity
{
	_opacity = opacity;
	for(CCMenuItem<CCRGBAProtocol>* item in subItems_)
		[item setOpacity:opacity];
}

- (void) setColor:(ccColor4B)color
{
	_color = color;
	for(CCMenuItem<CCRGBAProtocol>* item in subItems_)
		[item setColor: color];
}

@end
