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

#import "CCNode.h"
#import "CCProtocols.h"

@class CCSprite;
@class CCSpriteFrame;

#define kCCItemSize 32

#pragma mark -
#pragma mark CCMenuItem
/** CCMenuItem base class
 *
 *  Subclass CCMenuItem (or any subclass) to create your custom CCMenuItem objects.
 */
@interface CCMenuItem : CCNode
{
    BOOL _enabled;
    BOOL _selected;
}
/** returns whether or not the item is selected
@since v0.8.2
*/
@property (nonatomic, getter = isSelected) BOOL selected;

@property (nonatomic, getter = isEnabled) BOOL enabled;

/** Initializes a CCMenuItem with the specified block.
 The block will be "copied".
*/
- (id)initWithBlock:(void(^)(id sender))block;

- (void)addTarget: (id)target
        forAction: (SEL)selector;

/** Returns the outside box in points */
-(CGRect) rect;

/** Activate the item */
-(void) activate;

/** Sets the block that is called when the item is tapped.
 The block will be "copied".
 */
@property (nonatomic, copy) void(^block)(id sender);

/** cleanup event. It will release the block and call [super cleanup] */
-(void) cleanup;

@end

#pragma mark -
#pragma mark CCMenuItemLabel

/** An abstract class for "label" CCMenuItemLabel items
 Any CCNode that supports the CCLabelProtocol protocol can be added.
 Supported nodes:
   - CCBMFontLabel
   - CCAtlasLabel
   - CCTTFLabel
 */
@interface CCMenuItemLabel : CCMenuItem  <CCRGBAProtocol>
{
	CCNode<CCLabelProtocol, CCRGBAProtocol> *label_;
	GLKVector4	colorBackup;
	GLKVector4	disabledColor_;
	float		originalScale_;
}

/** the color that will be used to disable the item */
@property (nonatomic) GLKVector4 disabledColor;

/** Label that is rendered. It can be any CCNode that implements the CCLabelProtocol */
@property (nonatomic, assign) CCNode<CCLabelProtocol, CCRGBAProtocol>* label;

/** initializes a CCMenuItemLabel with a Label and a block to execute.
 The block will be "copied".
 This is the designated initializer.
 */
-(id) initWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label block:(void(^)(id sender))block;

/** sets a new string to the inner label */
-(void) setString:(NSString*)label;

@end

#pragma mark -
#pragma mark CCMenuItemAtlasFont

/** A CCMenuItemAtlasFont
 Helper class that creates a CCMenuItemLabel class with a CCAtlasLabel
 */
@interface CCMenuItemAtlasFont : CCMenuItemLabel

/** initializes a menu item from a string and atlas with a  block.
 The block will be "copied".
 */
-(id) initWithString: (NSString*) value
         charMapFile:(NSString*) charMapFile
           itemSize: (CGSize)itemSize
        startCharMap: (char)startCharMap
               block: (void(^)(id sender))block;

@end

#pragma mark -
#pragma mark CCMenuItemFont

/** A CCMenuItemFont
 Helper class that creates a CCMenuItemLabel class with a Label
 */
@interface CCMenuItemFont : CCMenuItemLabel

/** set default font size */
+(void) setFontSize: (NSUInteger) s;

/** get default font size */
+(NSUInteger) fontSize;

/** set default font name */
+(void) setFontName: (NSString*) n;

/** get default font name */
+(NSString*) fontName;

@property (nonatomic) NSUInteger fontSize;

@property (nonatomic, copy) NSString *fontName;

/** initializes a menu item from a string with the specified block.
 The block will be "copied".
 */
-(id) initWithString: (NSString*)value
               block: (void(^)(id sender))block;

@end

#pragma mark -
#pragma mark CCMenuItemSprite

/** CCMenuItemSprite accepts CCNode<CCRGBAProtocol> objects as items.
 The images has 3 different states:
 - unselected image
 - selected image
 - disabled image

 @since v0.8.0
 */
@interface CCMenuItemSprite : CCMenuItem <CCRGBAProtocol>
{
	CCNode<CCRGBAProtocol> *normalImage_, *selectedImage_, *disabledImage_;
}

// weak references

/** the image used when the item is not selected */
@property (nonatomic,assign) CCNode<CCRGBAProtocol> *normalImage;
/** the image used when the item is selected */
@property (nonatomic,assign) CCNode<CCRGBAProtocol> *selectedImage;
/** the image used when the item is disabled */
@property (nonatomic,assign) CCNode<CCRGBAProtocol> *disabledImage;

/** initializes a menu item with a normal, selected  and disabled image with a block.
 The block will be "copied".
 */
-(id) initWithNormalSprite: (CCNode<CCRGBAProtocol>*)normalSprite
            selectedSprite: (CCNode<CCRGBAProtocol>*)selectedSprite
            disabledSprite: (CCNode<CCRGBAProtocol>*)disabledSprite
                     block: (void(^)(id sender))block;

@end

#pragma mark -
#pragma mark CCMenuItemImage

/** CCMenuItemImage accepts images as items.
 The images has 3 different states:
 - unselected image
 - selected image
 - disabled image

 For best results try that all images are of the same size
 */
@interface CCMenuItemImage : CCMenuItemSprite

/** initializes a menu item with a normal, selected  and disabled image with a block.
 The block will be "copied".
*/
-(id) initWithNormalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block;

/** sets the sprite frame for the normal image */
- (void) setNormalSpriteFrame:(CCSpriteFrame*)frame;

/** sets the sprite frame for the selected image */
- (void) setSelectedSpriteFrame:(CCSpriteFrame*)frame;

/** sets the sprite frame for the disabled image */
- (void) setDisabledSpriteFrame:(CCSpriteFrame*)frame;

@end

#pragma mark -
#pragma mark CCMenuItemToggle

/** A CCMenuItemToggle
 A simple container class that "toggles" its inner items
 The inner itmes can be any MenuItem
 */
@interface CCMenuItemToggle : CCMenuItem <CCRGBAProtocol>
{
    CCMenuItem *_currentItem;
	NSUInteger selectedIndex_;
	NSMutableArray* subItems_;
}

/** returns the selected item */
@property (nonatomic) NSUInteger selectedIndex;
/** NSMutableArray that contains the subitems. You can add/remove items in runtime, and you can replace the array with a new one.
 @since v0.7.2
 */
@property (nonatomic, retain) NSMutableArray *subItems;

/** initializes a menu item from a list of items with a block.
 The block will be "copied".
 */
-(id) initWithItems:(NSArray*)arrayOfItems block:(void (^)(id))block;

/** return the selected item */
-(CCMenuItem*) selectedItem;

@end

