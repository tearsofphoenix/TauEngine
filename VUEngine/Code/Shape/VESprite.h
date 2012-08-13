//
//  VESprite.h
//  ExampleEngine
//
//  Created by Ian Terrell on 8/18/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "VERectangle.h"

@interface VESprite : VERectangle

- (id)initWithImage: (UIImage*)image
         pointRatio: (float)ratio;

@end
