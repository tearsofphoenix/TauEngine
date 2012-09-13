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


#import "VACamera.h"

struct _VACamera
{
    GLKVector3 _eye;
    GLKVector3 _center;
    GLKVector3 _up;
    GLKMatrix4 _cachedLookupMatrix;
    BOOL _isDirty;
};

VACameraRef VACameraCreate(void)
{
    VACameraRef camera = malloc(sizeof(struct _VACamera));
    camera->_eye = GLKVector3Make(0, 0, FLT_EPSILON);
    camera->_center = GLKVector3Make(0, 0, 0);
    camera->_up = GLKVector3Make(0, 1, 0);
    camera->_isDirty = YES;
    
    return camera;
}

GLKMatrix4 VACameraGetLookAtMatrix(VACameraRef camera)
{
    if (camera->_isDirty)
    {
        camera->_cachedLookupMatrix = GLKMatrix4MakeLookAt(camera->_eye.x,camera->_eye.y, camera->_eye.z ,
                                                           camera->_center.x, camera->_center.y, camera->_center.z,
                                                           camera->_up.x, camera->_up.y, camera->_up.z);
        camera->_isDirty = NO;
    }
    
    return camera->_cachedLookupMatrix;
}

void VACameraFinalize(VACameraRef camera)
{
    free(camera);
}
#pragma mark - getter

 GLKVector3 VACameraGetEye(VACameraRef camera)
{
    return camera->_eye;
}

 GLKVector3 VACameraGetCenter(VACameraRef camera)
{
    return camera->_center;
}

 GLKVector3 VACameraGetUp(VACameraRef camera)
{
    return camera->_up;
}

#pragma mark - setter

 void VACameraSetEye(VACameraRef camera, GLKVector3 eye)
{
    if (!GLKVector3AllEqualToVector3(camera->_eye, eye))
    {
        camera->_eye = eye;
        camera->_isDirty = YES;
    }
}

 void VACameraSetCenter(VACameraRef camera, GLKVector3 center)
{
    if (!GLKVector3AllEqualToVector3(camera->_center, center))
    {
        camera->_center = center;
        camera->_isDirty = YES;
    }
}

 void VACameraSetUp(VACameraRef camera, GLKVector3 up)
{
    if (!GLKVector3AllEqualToVector3(camera->_up, up))
    {
        camera->_up = up;
        camera->_isDirty = YES;
    }
}

