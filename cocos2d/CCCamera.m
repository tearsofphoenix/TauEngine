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

struct _VECamera
{
    GLKVector3 _eye;
    GLKVector3 _center;
    GLKVector3 _up;
    GLKMatrix4 _cachedLookupMatrix;
    BOOL _isDirty;
};

VECameraRef VECameraCreate(void)
{
    VECameraRef camera = malloc(sizeof(struct _VECamera));
    camera->_eye = GLKVector3Make(0, 0, FLT_EPSILON);
    camera->_center = GLKVector3Make(0, 0, 0);
    camera->_up = GLKVector3Make(0, 1, 0);
    
    return camera;
}

GLKMatrix4 VECameraGetLookAtMatrix(VECameraRef camera)
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

void VECameraFinalize(VECameraRef camera)
{
    free(camera);
}
#pragma mark - getter

 GLKVector3 VECameraGetEye(VECameraRef camera)
{
    return camera->_eye;
}

 GLKVector3 VECameraGetCenter(VECameraRef camera)
{
    return camera->_center;
}

 GLKVector3 VECameraGetUp(VECameraRef camera)
{
    return camera->_up;
}

#pragma mark - setter

 void VECameraSetEye(VECameraRef camera, GLKVector3 eye)
{
    if (!GLKVector3AllEqualToVector3(camera->_eye, eye))
    {
        camera->_eye = eye;
        camera->_isDirty = YES;
    }
}

 void VECameraSetCenter(VECameraRef camera, GLKVector3 center)
{
    if (!GLKVector3AllEqualToVector3(camera->_center, center))
    {
        camera->_center = center;
        camera->_isDirty = YES;
    }
}

 void VECameraSetUp(VECameraRef camera, GLKVector3 up)
{
    if (!GLKVector3AllEqualToVector3(camera->_up, up))
    {
        camera->_up = up;
        camera->_isDirty = YES;
    }
}

