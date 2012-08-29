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


#import "CCAtlasNode.h"
#import "CCAtlasTexture.h"

/** CCAtlasLabel is a subclass of CCAtlasNode.

 It can be as a replacement of CCLabel since it is MUCH faster.

 CCAtlasLabel versus CCLabel:
 - CCAtlasLabel is MUCH faster than CCLabel
 - CCAtlasLabel "characters" have a fixed height and width
 - CCAtlasLabel "characters" can be anything you want since they are taken from an image file

 A more flexible class is CCBMFontLabel. It supports variable width characters and it also has a nice editor.
 */
@interface CCAtlasLabel : CCAtlasNode  <CCLabelProtocol>
{
	// string to render
	NSString		*string_;

	// the first char in the charmap
	NSUInteger		mapStartChar_;
}

/** initializes the CCAtlasLabel with a string, a char map file(the atlas), the width and height in points of each element and the starting char of the atlas */
-(id) initWithString: (NSString*) theString
         charMapFile: (NSString*) charmapfile
            itemSize: (CGSize)size
        startCharMap:(NSUInteger)c;

/** initializes the CCAtlasLabel with a string and a configuration file
 @since v2.0
 */
-(id) initWithString:(NSString*) string fntFile:(NSString*)fontFile;

@end
