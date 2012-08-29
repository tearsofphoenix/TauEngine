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
 * Portions of this code are based and inspired on:
 *   http://www.71squared.co.uk/2009/04/iphone-game-programming-tutorial-4-bitmap-font-class
 *   by Michael Daley
 *
 *
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */

#import "ccConfig.h"
#import "ccMacros.h"
#import "CCBMFontLabel.h"
#import "CCSprite.h"

#import "CCConfiguration.h"
#import "CCTextureCache.h"
#import "Support/CCFileUtils.h"
#import "Support/CGPointExtension.h"


#pragma mark -
#pragma mark FNTConfig Cache - free functions

NSMutableDictionary *configurations = nil;
CCBMFontConfiguration* FNTConfigLoadFile( NSString *fntFile)
{
	CCBMFontConfiguration *ret = nil;
    
	if( configurations == nil )
		configurations = [[NSMutableDictionary dictionaryWithCapacity:3] retain];
    
	ret = [configurations objectForKey:fntFile];
	if( ret == nil )
    {
		ret = [[CCBMFontConfiguration alloc] initWithFNTfile: fntFile];
		if( ret )
        {
			[configurations setObject:ret forKey:fntFile];
            [ret release];
        }
	}
    
	return ret;
}

void FNTConfigRemoveCache( void )
{
	[configurations removeAllObjects];
}

#pragma mark - Hash Element

// Equal function for targetSet.
typedef struct _KerningHashElement
{
	int				key;		// key for the hash. 16-bit for 1st element, 16-bit for 2nd element
	int				amount;
    
} tKerningHashElement;


#pragma mark -
#pragma mark BitmapFontConfiguration

typedef struct _FontDefHashElement
{
	NSUInteger		key;		// key. Font Unicode value
	ccBMFontDef		fontDef;	// font definition
    
} tFontDefHashElement;


@interface CCBMFontConfiguration ()
-(BOOL) parseConfigFile:(NSString*)controlFile;
-(void) parseCharacterDefinition:(NSString*)line charDef:(ccBMFontDef*)characterDefinition;
-(void) parseInfoArguments:(NSString*)line;
-(void) parseCommonArguments:(NSString*)line;
-(void) parseImageFileName:(NSString*)line fntFile:(NSString*)fntFile;
-(void) parseKerningEntry:(NSString*)line;
-(void) purgeKerningDictionary;
-(void) purgeFontDefDictionary;
@end

#pragma mark -
#pragma mark CCBMFontConfiguration

@implementation CCBMFontConfiguration

@synthesize atlasName=atlasName_;

-(id) initWithFNTfile:(NSString*)fntFile
{
	if((self=[super init])) {
        
		kerningDictionary_ = NULL;
		fontDefDictionary_ = NULL;
        
		if( ! [self parseConfigFile:fntFile] ) {
			[self release];
			return nil;
		}
	}
	return self;
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);
	[self purgeFontDefDictionary];
	[self purgeKerningDictionary];
	[atlasName_ release];
	[super dealloc];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Glphys:%ld Kernings:%ld | Image = %@>", [self class], self,
			CFDictionaryGetCount(fontDefDictionary_),
			CFDictionaryGetCount(kerningDictionary_),
			atlasName_];
}


- (void)purgeFontDefDictionary
{
    CFDictionaryRemoveAllValues(fontDefDictionary_);
}

- (void)purgeKerningDictionary
{
    CFDictionaryRemoveAllValues(kerningDictionary_);
}

- (BOOL)parseConfigFile:(NSString*)fntFile
{
	NSString *fullpath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:fntFile];
	NSError *error;
	NSString *contents = [NSString stringWithContentsOfFile:fullpath encoding:NSUTF8StringEncoding error:&error];
    
	if( ! contents )
    {
		NSLog(@"cocos2d: Error parsing FNTfile %@: %@", fntFile, error);
		return NO;
	}
    
	// Move all lines in the string, which are denoted by \n, into an array
	NSArray *lines = [[NSArray alloc] initWithArray:[contents componentsSeparatedByString:@"\n"]];
    
	// Create an enumerator which we can use to move through the lines read from the control file
	NSEnumerator *nse = [lines objectEnumerator];
    
	// Create a holder for each line we are going to work with
	NSString *line;
    
	// Loop through all the lines in the lines array processing each one
	while( (line = [nse nextObject]) ) {
		// parse spacing / padding
		if([line hasPrefix:@"info face"]) {
			// XXX: info parsing is incomplete
			// Not needed for the Hiero editors, but needed for the AngelCode editor
            //			[self parseInfoArguments:line];
		}
		// Check to see if the start of the line is something we are interested in
		else if([line hasPrefix:@"common lineHeight"]) {
			[self parseCommonArguments:line];
		}
		else if([line hasPrefix:@"page id"]) {
			[self parseImageFileName:line fntFile:fntFile];
		}
		else if([line hasPrefix:@"chars c"]) {
			// Ignore this line
		}
		else if([line hasPrefix:@"char"]) {
			// Parse the current line and create a new CharDef
			tFontDefHashElement *element = malloc( sizeof(*element) );
			
			[self parseCharacterDefinition:line charDef:&element->fontDef];
			
			element->key = element->fontDef.charID;
            CFDictionarySetValue(fontDefDictionary_, (const void *)element->key, element);
		}
        //		else if([line hasPrefix:@"kernings count"]) {
        //			[self parseKerningCapacity:line];
        //		}
		else if([line hasPrefix:@"kerning first"]) {
			[self parseKerningEntry:line];
		}
	}
	// Finished with lines so release it
	[lines release];
	
	return  YES;
}

-(void) parseImageFileName:(NSString*)line fntFile:(NSString*)fntFile
{
	NSString *propertyValue = nil;
    
	// Break the values for this line up using =
	NSArray *values = [line componentsSeparatedByString:@"="];
    
	// Get the enumerator for the array of components which has been created
	NSEnumerator *nse = [values objectEnumerator];
    
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
    
	// page ID. Sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] == 0, @"XXX: LabelBMFont only supports 1 page");
    
	// file
	propertyValue = [nse nextObject];
	NSArray *array = [propertyValue componentsSeparatedByString:@"\""];
	propertyValue = [array objectAtIndex:1];
	NSAssert(propertyValue,@"LabelBMFont file could not be found");
    
	// Supports subdirectories
	NSString *dir = [fntFile stringByDeletingLastPathComponent];
	atlasName_ = [dir stringByAppendingPathComponent:propertyValue];
    
	[atlasName_ retain];
}

-(void) parseInfoArguments:(NSString*)line
{
	//
	// possible lines to parse:
	// info face="Script" size=32 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=1,4,3,2 spacing=0,0 outline=0
	// info face="Cracked" size=36 bold=0 italic=0 charset="" unicode=0 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1
	//
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];
	NSString *propertyValue = nil;
    
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
    
	// face (ignore)
	[nse nextObject];
    
	// size (ignore)
	[nse nextObject];
    
	// bold (ignore)
	[nse nextObject];
    
	// italic (ignore)
	[nse nextObject];
    
	// charset (ignore)
	[nse nextObject];
    
	// unicode (ignore)
	[nse nextObject];
    
	// strechH (ignore)
	[nse nextObject];
    
	// smooth (ignore)
	[nse nextObject];
    
	// aa (ignore)
	[nse nextObject];
    
	// padding (ignore)
	propertyValue = [nse nextObject];
	{
        
		NSArray *paddingValues = [propertyValue componentsSeparatedByString:@","];
		NSEnumerator *paddingEnum = [paddingValues objectEnumerator];
		// padding top
		propertyValue = [paddingEnum nextObject];
		padding_.top = [propertyValue intValue];
        
		// padding right
		propertyValue = [paddingEnum nextObject];
		padding_.right = [propertyValue intValue];
        
		// padding bottom
		propertyValue = [paddingEnum nextObject];
		padding_.bottom = [propertyValue intValue];
        
		// padding left
		propertyValue = [paddingEnum nextObject];
		padding_.left = [propertyValue intValue];
        
		CCLOG(@"cocos2d: padding: %d,%d,%d,%d", padding_.left, padding_.top, padding_.right, padding_.bottom);
	}
    
	// spacing (ignore)
	[nse nextObject];
}

-(void) parseCommonArguments:(NSString*)line
{
	//
	// line to parse:
	// common lineHeight=104 base=26 scaleW=1024 scaleH=512 pages=1 packed=0
	//
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];
	NSString *propertyValue = nil;
    
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
    
	// Character ID
	propertyValue = [nse nextObject];
	commonHeight_ = [propertyValue intValue];
    
	// base (ignore)
	[nse nextObject];
    
    
	// scaleW. sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] <= [[CCConfiguration sharedConfiguration] maxTextureSize], @"CCBMFontLabel: page can't be larger than supported");
    
	// scaleH. sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] <= [[CCConfiguration sharedConfiguration] maxTextureSize], @"CCBMFontLabel: page can't be larger than supported");
    
	// pages. sanity check
	propertyValue = [nse nextObject];
	NSAssert( [propertyValue intValue] == 1, @"CCBitfontAtlas: only supports 1 page");
    
	// packed (ignore) What does this mean ??
}
- (void)parseCharacterDefinition:(NSString*)line charDef:(ccBMFontDef*)characterDefinition
{
	// Break the values for this line up using =
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];
	NSString *propertyValue;
    
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
    
	// Character ID
	propertyValue = [nse nextObject];
	propertyValue = [propertyValue substringToIndex: [propertyValue rangeOfString: @" "].location];
	characterDefinition->charID = [propertyValue intValue];
    
	// Character x
	propertyValue = [nse nextObject];
	characterDefinition->rect.origin.x = [propertyValue intValue];
	// Character y
	propertyValue = [nse nextObject];
	characterDefinition->rect.origin.y = [propertyValue intValue];
	// Character width
	propertyValue = [nse nextObject];
	characterDefinition->rect.size.width = [propertyValue intValue];
	// Character height
	propertyValue = [nse nextObject];
	characterDefinition->rect.size.height = [propertyValue intValue];
	// Character xoffset
	propertyValue = [nse nextObject];
	characterDefinition->xOffset = [propertyValue intValue];
	// Character yoffset
	propertyValue = [nse nextObject];
	characterDefinition->yOffset = [propertyValue intValue];
	// Character xadvance
	propertyValue = [nse nextObject];
	characterDefinition->xAdvance = [propertyValue intValue];
}

-(void) parseKerningEntry:(NSString*) line
{
	NSArray *values = [line componentsSeparatedByString:@"="];
	NSEnumerator *nse = [values objectEnumerator];
	NSString *propertyValue;
    
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
    
	// first
	propertyValue = [nse nextObject];
	int first = [propertyValue intValue];
    
	// second
	propertyValue = [nse nextObject];
	int second = [propertyValue intValue];
    
	// second
	propertyValue = [nse nextObject];
	int amount = [propertyValue intValue];
    
	tKerningHashElement *element = calloc( sizeof( *element ), 1 );
	element->amount = amount;
	element->key = (first<<16) | (second&0xffff);

    CFDictionarySetValue(kerningDictionary_, (const void *)element->key, element);
}

@end

#pragma mark -
#pragma mark CCBMFontLabel

@interface CCBMFontLabel ()

-(int) kerningAmountForFirst:(unichar)first second:(unichar)second;
-(void) updateLabel;
-(void) setString:(NSString*) newString updateLabel:(BOOL)update;

@end

#pragma mark -
#pragma mark CCBMFontLabel

@implementation CCBMFontLabel

@synthesize alignment = alignment_;
@synthesize opacity = _opacity, color = _color;


#pragma mark LabelBMFont - Purge Cache
+(void) purgeCachedData
{
	FNTConfigRemoveCache();
}

#pragma mark LabelBMFont - Creation & Init

-(id) init
{
	return [self initWithString:nil fntFile:nil width:kCCLabelAutomaticWidth alignment:UITextAlignmentLeft imageOffset:CGPointZero];
}

-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile
{
    return [self initWithString:theString fntFile:fntFile width:kCCLabelAutomaticWidth alignment:UITextAlignmentLeft];
}

-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile width:(float)width alignment:(NSTextAlignment)alignment
{
	return [self initWithString:theString fntFile:fntFile width:width alignment:alignment imageOffset:CGPointZero];
}

// designated initializer
-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile width:(float)width alignment:(NSTextAlignment)alignment imageOffset:(CGPoint)offset
{
	NSAssert(!configuration_, @"re-init is no longer supported");
	
	// if theString && fntfile are both nil, then it is OK
	NSAssert( (theString && fntFile) || (theString==nil && fntFile==nil), @"Invalid params for CCBMFontLabel");
	
	CCTexture2D *texture = nil;
    
	if( fntFile ) {
		CCBMFontConfiguration *newConf = FNTConfigLoadFile(fntFile);
		NSAssert( newConf, @"CCBMFontLabel: Impossible to create font. Please check file: '%@'", fntFile );
        
		configuration_ = [newConf retain];
        
		fntFile_ = [fntFile retain];
        
		texture = [[CCTextureCache sharedTextureCache] addImage:configuration_.atlasName];
        
	} else
		texture = [[[CCTexture2D alloc] init] autorelease];
    
    
	if( (self=[super initWithTexture:texture capacity:[theString length]]) ) {
        width_ = width;
        alignment_ = alignment;
        
		_opacity = 255;
		_color = ccWHITE;
		
		_contentSize = CGSizeZero;
		
		opacityModifyRGB_ = [[_textureAtlas texture] hasPremultipliedAlpha];
		
		_anchorPoint = ccp(0.5f, 0.5f);
        
		imageOffset_ = offset;
        
		[self setString:theString updateLabel:YES];
	}
    
	return self;
}

-(void) dealloc
{
	[_string release];
    [initialString_ release];
	[configuration_ release];
    [fntFile_ release];
    
	[super dealloc];
}

#pragma mark LabelBMFont - Alignment

- (void)updateLabel
{
    [self setString:initialString_ updateLabel:NO];
	
    if (width_ > 0){
        //Step 1: Make multiline
		
        NSString *multilineString = @"", *lastWord = @"";
        int line = 1, i = 0;
        NSUInteger stringLength = [self.string length];
        float startOfLine = -1, startOfWord = -1;
        int skip = 0;
        //Go through each character and insert line breaks as necessary
        for (int j = 0; j < CFArrayGetCount(_children); j++)
        {
            CCSprite *characterSprite;
			
            while(!(characterSprite = (CCSprite *)[self getChildByTag:j+skip]))
                skip++;
			
            if (!characterSprite.visible) continue;
			
            if (i >= stringLength || i < 0)
                break;
			
            unichar character = [self.string characterAtIndex:i];
			
            if (startOfWord == -1)
                startOfWord = characterSprite.position.x - characterSprite.contentSize.width/2;
            if (startOfLine == -1)
                startOfLine = startOfWord;
			
            //Character is a line break
            //Put lastWord on the current line and start a new line
            //Reset lastWord
            if ([[NSCharacterSet newlineCharacterSet] characterIsMember:character]) {
                lastWord = [[lastWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByAppendingFormat:@"%C", character];
                multilineString = [multilineString stringByAppendingString:lastWord];
                lastWord = @"";
                startOfWord = -1;
                line++;
                startOfLine = -1;
                i++;
				
                //CCBMFontLabel do not have a character for new lines, so do NOT "continue;" in the for loop. Process the next character
                if (i >= stringLength || i < 0)
                    break;
                character = [self.string characterAtIndex:i];
				
                if (startOfWord == -1)
                    startOfWord = characterSprite.position.x - characterSprite.contentSize.width/2;
                if (startOfLine == -1)
                    startOfLine = startOfWord;
            }
			
            //Character is a whitespace
            //Put lastWord on current line and continue on current line
            //Reset lastWord
            if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:character]) {
                lastWord = [lastWord stringByAppendingFormat:@"%C", character];
                multilineString = [multilineString stringByAppendingString:lastWord];
                lastWord = @"";
                startOfWord = -1;
                i++;
                continue;
            }
			
            //Character is out of bounds
            //Do not put lastWord on current line. Add "\n" to current line to start a new line
            //Append to lastWord
            if (characterSprite.position.x + characterSprite.contentSize.width/2 - startOfLine >  width_) {
                lastWord = [lastWord stringByAppendingFormat:@"%C", character];
                NSString *trimmedString = [multilineString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                multilineString = [trimmedString stringByAppendingString:@"\n"];
                line++;
                startOfLine = -1;
                i++;
                continue;
            } else {
                //Character is normal
                //Append to lastWord
                lastWord = [lastWord stringByAppendingFormat:@"%C", character];
                i++;
                continue;
            }
        }
		
        multilineString = [multilineString stringByAppendingFormat:@"%@", lastWord];
		
        [self setString:multilineString updateLabel:NO];
    }
	
    //Step 2: Make alignment
	
    if (self.alignment != UITextAlignmentLeft) {
		
        int i = 0;
        //Number of spaces skipped
        int lineNumber = 0;
        //Go through line by line
        for (NSString *lineString in [_string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
            int lineWidth = 0;
			
            //Find index of last character in this line
            NSInteger index = i + [lineString length] - 1 + lineNumber;
            if (index < 0)
                continue;
			
            //Find position of last character on the line
            CCSprite *lastChar = (CCSprite *)[self getChildByTag:index];
			
            lineWidth = lastChar.position.x + lastChar.contentSize.width/2;
			
            //Figure out how much to shift each character in this line horizontally
            float shift = 0;
            switch (self.alignment)
            {
                case UITextAlignmentCenter:
                    shift = self.contentSize.width/2 - lineWidth/2;
                    break;
                case UITextAlignmentRight:
                    shift = self.contentSize.width - lineWidth;
                default:
                    break;
            }
			
            if (shift != 0) {
                int j = 0;
                //For each character, shift it so that the line is center aligned
                for (j = 0; j < [lineString length]; j++) {
                    index = i + j + lineNumber;
                    if (index < 0)
                        continue;
                    CCSprite *characterSprite = (CCSprite *)[self getChildByTag:index];
                    characterSprite.position = ccpAdd(characterSprite.position, ccp(shift, 0));
                }
            }
            i += [lineString length];
            lineNumber++;
        }
    }
}

#pragma mark LabelBMFont - Atlas generation

-(int) kerningAmountForFirst:(unichar)first second:(unichar)second
{
	int ret = 0;
	unsigned int key = (first<<16) | (second & 0xffff);
    
	if( configuration_->kerningDictionary_ )
    {
		tKerningHashElement *element = (void *)CFDictionaryGetValue(configuration_->kerningDictionary_, (const void *)key);
		if(element)
			ret = element->amount;
	}
    
	return ret;
}

-(void) createFontChars
{
	NSInteger nextFontPositionX = 0;
	NSInteger nextFontPositionY = 0;
	unichar prev = -1;
	NSInteger kerningAmount = 0;
    
	CGSize tmpSize = CGSizeZero;
    
	NSInteger longestLine = 0;
	NSUInteger totalHeight = 0;
    
	NSUInteger quantityOfLines = 1;
    
	NSUInteger stringLen = [_string length];
	if( ! stringLen )
		return;
    
	// quantity of lines NEEDS to be calculated before parsing the lines,
	// since the Y position needs to be calcualted before hand
	for(NSUInteger i=0; i < stringLen-1;i++) {
		unichar c = [_string characterAtIndex:i];
		if( c=='\n')
			quantityOfLines++;
	}
    
	totalHeight = configuration_->commonHeight_ * quantityOfLines;
	nextFontPositionY = -(configuration_->commonHeight_ - configuration_->commonHeight_*quantityOfLines);
    
	for(NSUInteger i = 0; i<stringLen; i++)
    {
		unichar c = [_string characterAtIndex:i];
        
		if (c == '\n') {
			nextFontPositionX = 0;
			nextFontPositionY -= configuration_->commonHeight_;
			continue;
		}
        
		kerningAmount = [self kerningAmountForFirst:prev second:c];
        
				
		// unichar is a short, and an int is needed on HASH_FIND_INT
		NSUInteger key = (NSUInteger)c;
		tFontDefHashElement *element = (void *)CFDictionaryGetValue(configuration_->fontDefDictionary_ , (const void *)key);
        
		NSAssert(element, @"FontDefinition could not be found!");
        
		ccBMFontDef fontDef = element->fontDef;
        
		CGRect rect = fontDef.rect;
		rect = CC_RECT_PIXELS_TO_POINTS(rect);
		
		rect.origin.x += imageOffset_.x;
		rect.origin.y += imageOffset_.y;
        
		CCSprite *fontChar;
        
		fontChar = (CCSprite*) [self getChildByTag:i];
		if( ! fontChar )
        {
			fontChar = [[CCSprite alloc] initWithTexture:_textureAtlas.texture rect:rect];
            [fontChar setTag: i];
            
			[self addChild: fontChar
                         z: 0];
            
			[fontChar release];
		}
		else {
			// reusing fonts
			[fontChar setTextureRect:rect rotated:NO untrimmedSize:rect.size];
            
			// restore to default in case they were modified
			fontChar.visible = YES;
			fontChar.opacity = 255;
		}
        
		// See issue 1343. cast( signed short + unsigned integer ) == unsigned integer (sign is lost!)
		NSInteger yOffset = configuration_->commonHeight_ - fontDef.yOffset;
		CGPoint fontPos = ccp( (CGFloat)nextFontPositionX + fontDef.xOffset + fontDef.rect.size.width*0.5f + kerningAmount,
							  (CGFloat)nextFontPositionY + yOffset - rect.size.height*0.5f * CC_CONTENT_SCALE_FACTOR() );
        fontChar.position = CC_POINT_PIXELS_TO_POINTS(fontPos);
		
		// update kerning
		nextFontPositionX += fontDef.xAdvance + kerningAmount;
		prev = c;
        
		// Apply label properties
		[fontChar setOpacityModifyRGB:opacityModifyRGB_];
		// Color MUST be set before opacity, since opacity might change color if OpacityModifyRGB is on
		[fontChar setColor:_color];
        
		// only apply opacity if it is different than 255 )
		// to prevent modifying the color too (issue #610)
		if( _opacity != 255 )
			[fontChar setOpacity: _opacity];
        
		if (longestLine < nextFontPositionX)
			longestLine = nextFontPositionX;
	}
    
	tmpSize.width = longestLine;
	tmpSize.height = totalHeight;
    
	[self setContentSize:CC_SIZE_PIXELS_TO_POINTS(tmpSize)];
}

#pragma mark LabelBMFont - CCLabelProtocol protocol

@synthesize string = _string;

- (void) setString:(NSString*)newString
{
	[self setString: newString
        updateLabel: YES];
}

- (void) setString: (NSString*) newString
       updateLabel: (BOOL)update
{
    if( !update )
    {
        [_string release];
        _string = [newString copy];
        
    } else
    {
        [initialString_ release];
        initialString_ = [newString copy];
    }
	
    for(CCSprite *child in (NSArray *)_children)
    {
        child.visible = NO;
    }
	
	[self createFontChars];
	
    if (update)
        [self updateLabel];
}

#pragma mark LabelBMFont - CCRGBAProtocol protocol

-(void) setColor:(ccColor4B)color
{
	_color = color;
    
    for(CCSprite *child in (NSArray *)_children)
    {
        [child setColor:_color];
    }
}

-(void) setOpacity:(GLubyte)opacity
{
	_opacity = opacity;
    
	for(id<CCRGBAProtocol> child in (NSArray *)_children)
    {
        [child setOpacity:_opacity];
    }
}
-(void) setOpacityModifyRGB:(BOOL)modify
{
	opacityModifyRGB_ = modify;
    
	for(id<CCRGBAProtocol> child in (NSArray *)_children)
    {
        [child setOpacityModifyRGB:modify];
    }
}

-(BOOL) doesOpacityModifyRGB
{
	return opacityModifyRGB_;
}

#pragma mark LabelBMFont - AnchorPoint
-(void) setAnchorPoint:(CGPoint)point
{
	if( ! CGPointEqualToPoint(point, _anchorPoint) ) {
		[super setAnchorPoint:point];
		[self createFontChars];
	}
}

#pragma mark LabelBMFont - Alignment
- (void)setWidth:(float)width
{
    width_ = width;
    [self updateLabel];
}

- (void)setAlignment: (NSTextAlignment)alignment
{
    if (alignment_ != alignment)
    {
        alignment_ = alignment;
        [self updateLabel];
    }
}

#pragma mark LabelBMFont - FntFile
- (void) setFntFile:(NSString*) fntFile
{
	if( fntFile != fntFile_ ) {
		
		CCBMFontConfiguration *newConf = FNTConfigLoadFile(fntFile);
		
		NSAssert( newConf, @"CCBMFontLabel: Impossible to create font. Please check file: '%@'", fntFile );
		
		[fntFile_ release];
		fntFile_ = [fntFile retain];
		
		[configuration_ release];
		configuration_ = [newConf retain];
        
		[self setTexture:[[CCTextureCache sharedTextureCache] addImage:configuration_.atlasName]];
		[self createFontChars];
	}
}

- (NSString*) fntFile
{
    return fntFile_;
}

#pragma mark LabelBMFont - Debug draw
#if CC_LABELBMFONT_DEBUG_DRAW
-(void) draw
{
	[super draw];
    
	CGSize s = [self contentSize];
	CGPoint vertices[4]={
		ccp(0,0),ccp(s.width,0),
		ccp(s.width,s.height),ccp(0,s.height),
	};
	ccDrawPoly(vertices, 4, YES);
}
#endif // CC_LABELBMFONT_DEBUG_DRAW
@end
