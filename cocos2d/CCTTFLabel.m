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


#import "CCTTFLabel.h"
#import "Support/CGPointExtension.h"
#import "ccMacros.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "Support/CCFileUtils.h"


#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#endif

#if CC_USE_LA88_LABELS
#define SHADER_PROGRAM kCCShader_PositionTextureColor
#else
#define SHADER_PROGRAM kCCShader_PositionTextureA8Color
#endif

@interface CCTTFLabel ()
-(void) updateTexture;
@end

@implementation CCTTFLabel

- (id) init
{
    return [self initWithString:@"" fontName:@"Helvetica" fontSize:12];
}

- (id) initWithString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithString: str
                     dimensions: CGSizeZero
                     hAlignment: UITextAlignmentLeft
                     vAlignment: kCCVerticalTextAlignmentTop
                  lineBreakMode: UILineBreakModeWordWrap
                       fontName: name
                       fontSize: size];
}

// hAlignment
- (id) initWithString:(NSString*)str dimensions:(CGSize)dimensions hAlignment:(NSTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithString:str dimensions:dimensions hAlignment:alignment vAlignment:kCCVerticalTextAlignmentTop lineBreakMode:UILineBreakModeWordWrap fontName:name fontSize:size];
}

// hAlignment, vAlignment
- (id) initWithString:(NSString*)str dimensions:(CGSize)dimensions hAlignment:(NSTextAlignment)alignment vAlignment:(CCVerticalTextAlignment) vertAlignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithString:str dimensions:dimensions hAlignment:alignment vAlignment:vertAlignment lineBreakMode:UILineBreakModeWordWrap fontName:name fontSize:size];
}

// hAlignment, lineBreakMode
- (id) initWithString:(NSString*)str dimensions:(CGSize)dimensions hAlignment:(NSTextAlignment)alignment lineBreakMode:(UILineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithString:str dimensions:dimensions hAlignment:alignment vAlignment:kCCVerticalTextAlignmentTop lineBreakMode:lineBreakMode fontName:name fontSize:size];
}

// hAlignment, vAligment, lineBreakMode
- (id) initWithString:(NSString*)str dimensions:(CGSize)dimensions hAlignment:(NSTextAlignment)alignment vAlignment:(CCVerticalTextAlignment) vertAlignment lineBreakMode:(UILineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size
{
	if( (self=[super init]) )
    {
		// shader program
		[self setShaderProgram: CCShaderCacheGetProgramByName(SHADER_PROGRAM)];

		dimensions_ = dimensions;
		hAlignment_ = alignment;
		_verticalAlignment = vertAlignment;
		fontName_ = [name retain];
		fontSize_ = size;
		lineBreakMode_ = lineBreakMode;

		[self setString:str];
	}
	return self;
}

@synthesize string = _string;

- (void) setString:(NSString*)str
{
	NSAssert( str, @"Invalid string" );

	if( _string != str )
    {
		[_string release];
		_string = [str copy];
		
		[self updateTexture];
	}
}

- (void)setFontName:(NSString*)fontName
{
	if( fontName != fontName_ )
    {
		[fontName_ release];
		fontName_ = [fontName copy];
		
#ifdef __CC_PLATFORM_MAC
		if ([[fontName lowercaseString] hasSuffix:@".ttf"] || YES)
		{
			// This is a file, register font with font manager
			NSString* fontFile = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:fontName];
			NSURL* fontURL = [NSURL fileURLWithPath:fontFile];
			CTFontManagerRegisterFontsForURL((CFURLRef)fontURL, kCTFontManagerScopeProcess, NULL);
			NSString *newFontName = [[fontFile lastPathComponent] stringByDeletingPathExtension];

			fontName_ = [newFontName copy];
		}
#endif
		// Force update
		if( _string )
			[self updateTexture];
	}
}

- (NSString*)fontName
{
    return fontName_;
}

- (void) setFontSize:(float)fontSize
{
	if( fontSize != fontSize_ ) {
		fontSize_ = fontSize;
		
		// Force update
		if( _string )
			[self updateTexture];
	}
}

- (float) fontSize
{
    return fontSize_;
}

-(void) setDimensions:(CGSize) dim
{
    if( dim.width != dimensions_.width || dim.height != dimensions_.height)
	{
        dimensions_ = dim;
        
		// Force update
		if( _string )
			[self updateTexture];
    }
}

-(CGSize) dimensions
{
    return dimensions_;
}

-(void) setHorizontalAlignment:(NSTextAlignment)alignment
{
    if (alignment != hAlignment_)
    {
        hAlignment_ = alignment;
        
        // Force update
		if( _string )
			[self updateTexture];

    }
}

- (NSTextAlignment) horizontalAlignment
{
    return hAlignment_;
}

@synthesize verticalAlignment = _verticalAlignment;

-(void) setVerticalAlignment:(CCVerticalTextAlignment)verticalAlignment
{
    if (_verticalAlignment != verticalAlignment)
    {
        _verticalAlignment = verticalAlignment;
        
		// Force update
		if( _string )
			[self updateTexture];
    }
}

- (void) dealloc
{
	[_string release];
	[fontName_ release];

	[super dealloc];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | text: %@ fontName: %@ FontSize = %.1f>", [self class], self,
            _string, fontName_, fontSize_];
}

// Helper
- (void) updateTexture
{				
	CCTexture2D *tex;
	if( dimensions_.width == 0 || dimensions_.height == 0 )
		tex = [[CCTexture2D alloc] initWithString: _string
										 fontName: fontName_
										 fontSize: fontSize_  * CC_CONTENT_SCALE_FACTOR()];
	else
		tex = [[CCTexture2D alloc] initWithString: _string
									   dimensions: CC_SIZE_POINTS_TO_PIXELS(dimensions_)
									   hAlignment: hAlignment_
									   vAlignment: _verticalAlignment
									lineBreakMode: lineBreakMode_
										 fontName: fontName_
										 fontSize: fontSize_  * CC_CONTENT_SCALE_FACTOR()];
		
#ifdef __CC_PLATFORM_IOS
	// iPad ?
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
		if( CC_CONTENT_SCALE_FACTOR() == 2 )
			[tex setResolutionType:kCCResolutioniPadRetinaDisplay];
		else
			[tex setResolutionType:kCCResolutioniPad];
	}
	// iPhone ?
	else
	{
		if( CC_CONTENT_SCALE_FACTOR() == 2 )
			[tex setResolutionType:kCCResolutioniPhoneRetinaDisplay];
		else
			[tex setResolutionType:kCCResolutioniPhone];
	}
#endif
	
	[self setTexture:tex];
	[tex release];
	
	CGRect rect = CGRectZero;
	rect.size = [texture_ contentSize];
	[self setTextureRect: rect];
}
@end
