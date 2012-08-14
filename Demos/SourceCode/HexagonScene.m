//
//  HexagonScene.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/17/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "HexagonScene.h"

@implementation HexagonScene

-(id)init {
  self = [super init];
  if (self) {
    polygon = [[VERegularPolygon alloc] initWithNumSides:6];
    [polygon setRadius: 1];
    [polygon setBackgroundColor: GLKVector4Make(0.9, 0.9, 0.1, 1.0)];
  }
  return self;
}

-(void)render {
  [super render];
  [polygon renderInScene:self];
}

@end
