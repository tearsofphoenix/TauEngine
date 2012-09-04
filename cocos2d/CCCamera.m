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
 */


#import "CCCamera.h"
#import "ccGLStateCache.h"

@implementation CCCamera

@synthesize dirty = _dirty;

- (id) init
{
	if( (self=[super init]) )
    {
        _eye = GLKVector3Make(0, 0, [CCCamera getZEye]);
        _center = GLKVector3Make(0, 0, 0);
        _up = GLKVector3Make(0, 1, 0);
        
        _lookupMatrix = GLKMatrix4Identity;
        
        _dirty = NO;
    }
    
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | center = (%.2f,%.2f,%.2f)>", [self class], self, _center.v[0], _center.v[1], _center.v[2]];
}


- (void)dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	[super dealloc];
}

- (void)locate
{
	if( _dirty )
    {

        _lookupMatrix = GLKMatrix4MakeLookAt(_eye.v[0], _eye.v[1] , _eye.v[2],
                                             _center.v[0], _center.v[1], _center.v[2],
                                             _up.v[0], _up.v[1], _up.v[2]);
		_dirty = NO;

	}

	VECurrentGLMatrixStackMultiplyMatrix4( _lookupMatrix );

}

+(float) getZEye
{
	return FLT_EPSILON;
}

@synthesize eye = _eye;

- (void)setEye: (GLKVector3)eye
{
    if (!GLKVector3AllEqualToVector3(_eye, eye))
    {
        _eye = eye;
        _dirty = YES;
    }
}

@synthesize center = _center;

- (void)setCenter: (GLKVector3)center
{
    if (!GLKVector3AllEqualToVector3(_center, center))
    {
        _center = center;
        _dirty = YES;
    }
}

@synthesize up = _up;

- (void)setUp: (GLKVector3)up
{
    if (!GLKVector3AllEqualToVector3(_up, up))
    {
        _up = up;
        _dirty = YES;
    }
}

@end
