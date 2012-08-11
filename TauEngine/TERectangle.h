//
//  TERectangle.h
//  TauGame
//
//  Created by Ian Terrell on 7/11/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEPolygon.h"

enum
{
    kTERectangleBottomRight = 0,
    kTERectangleTopRight    = 1,
    kTERectangleTopLeft     = 2,
    kTERectangleBottomLeft  = 3,
};

typedef NSUInteger TERectangleCornerVertex;

@interface TERectangle : TEPolygon

@property (nonatomic) CGSize size;

@end
