//
//  VESprite.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/18/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "VESprite.h"

@implementation VESprite

- (id)initWithImage: (UIImage*)image
        pointRatio: (float)ratio
{
    self = [super init];
    if (self)
    {
        CGSize size = [image size];
        
        size.width /= ratio;
        size.height /= ratio;
        
        [self setSize: size];
        
        [self setTextureImage: image];
        
        GLKVector2 *textureCoordinates = [self textureCoordinates];
        
        textureCoordinates[0] = GLKVector2Make(1,0);
        textureCoordinates[1] = GLKVector2Make(1,1);
        textureCoordinates[2] = GLKVector2Make(0,1);
        textureCoordinates[3] = GLKVector2Make(0,0);
    }
    return self;
}

@end
