//
//  LandscapeScene.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/18/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "LandscapeScene.h"

@implementation LandscapeScene

- (id)init
{
    self = [super init];
    if (self)
    {
        rectangle = [[VERectangle alloc] init];
        [rectangle setSize: CGSizeMake(6, 4)];
        
        [rectangle setTextureImage:[UIImage imageNamed:@"landscape.jpg"]];
        rectangle.textureCoordinates[0] = GLKVector2Make(1,0);
        rectangle.textureCoordinates[1] = GLKVector2Make(1,0.88);
        rectangle.textureCoordinates[2] = GLKVector2Make(0,0.88);
        rectangle.textureCoordinates[3] = GLKVector2Make(0,0);
        
        [_shapes addObject: rectangle];
    }
    return self;
}

@end
