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


#import "VAScene.h"
#import "CGPointExtension.h"
#import "VEDirector.h"
#import "VALayer+Private.h"

@implementation VAScene

- (id)init
{
	if( (self=[super init]) )
    {
		CGSize s = [[VEDirector sharedDirector] winSize];

		_anchorPoint = ccp(0.5f, 0.5f);
        _scene = self;
        
		[self setFrame: CGRectMake(0, 0, s.width, s.height)];
	}

	return self;
}

- (GLKMatrix4)projectionMatrix
{
    CGRect bounds = [self bounds];

    return GLKMatrix4MakeOrtho(0, bounds.size.width, 0, bounds.size.height, 1, -1);
}

@end
