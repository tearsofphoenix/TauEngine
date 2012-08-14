//
//  VECollisionDetector.m
//  VUEngine
//
//  Created by LeixSnake on 8/14/12.
//  Copyright (c) 2012 Ian Terrell. All rights reserved.
//

#import "VECollisionDetector.h"

#import "VEEllipse.h"

@implementation VECollisionDetector

+  (BOOL)isEllipse: (VEEllipse *)ellipse1
collisionToEllipse: (VEEllipse *)ellipse2
{
    if (ellipse1 && ellipse2)
    {
        GLfloat maxRaduis1 = MAX([ellipse1 radiusX], [ellipse1 radiusY]);
        GLfloat maxRaduis2 = MAX([ellipse2 radiusX], [ellipse2 radiusY]);
        
    }
    
    return NO;
}

@end
