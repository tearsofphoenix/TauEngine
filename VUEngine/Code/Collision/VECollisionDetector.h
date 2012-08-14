//
//  VECollisionDetector.h
//  VUEngine
//
//  Created by LeixSnake on 8/14/12.
//  Copyright (c) 2012 Ian Terrell. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VEShape;
@class VEEllipse;
@class VERectangle;
@class VERegularPolygon;
@class VETriangle;

@interface VECollisionDetector : NSObject

+  (BOOL)isEllipse: (VEEllipse *)ellipse1
collisionToEllipse: (VEEllipse *)ellipse2;



@end
