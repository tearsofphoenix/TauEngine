//
//  TERandomPolygon.h
//  TauGame
//
//  Created by Ian Terrell on 7/29/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEPolygon.h"

@interface TERandomPolygon : TEPolygon
{
    float lowerFactor, upperFactor;
}

@property (nonatomic) int numSides;

- (id)initWithSides: (int)numSides
        lowerFactor: (float)lower
        upperFactor: (float)upper;

@end
