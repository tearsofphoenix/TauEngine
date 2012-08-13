//
//  VERegularPolygon.h
//  ExampleEngine
//
//  Created by Ian Terrell on 8/17/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "VEShape.h"

@interface VERegularPolygon : VEShape
{
    int _numSides;
}

@property (nonatomic, readonly) int numSides;

@property (nonatomic) float radius;

- (id)initWithNumSides: (int)numSides;

@end
