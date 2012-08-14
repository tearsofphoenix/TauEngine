//
//  SpriteScene.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/18/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "SpriteScene.h"

@implementation SpriteScene

- (id)init
{
    self = [super init];
    if (self)
    {
        sprite = [[VESprite alloc] initWithImage:[UIImage imageNamed:@"boy-sprite.png"] pointRatio:100];
        sprite.position = GLKVector2Make(2,-1);
        sprite.rotation = 0.25*(2 * M_PI);
        sprite.scale = GLKVector2Make(0.5, 1.5);
        [_shapes addObject: sprite];
    }
    return self;
}

@end
