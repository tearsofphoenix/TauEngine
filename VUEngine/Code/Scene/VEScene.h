//
//  VEScene.h
//  ExampleEngine
//
//  Created by Ian Terrell on 8/16/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface VEScene : NSObject
{
    GLKVector4 _clearColor;
    UIEdgeInsets _edgeInsets;
    
    NSMutableArray *_shapes;
}

@property (nonatomic) GLKVector4 clearColor;

@property (nonatomic) UIEdgeInsets edgeInsets;

@property(nonatomic, readonly) GLKMatrix4 projectionMatrix;

@property(strong,readonly) NSMutableArray *shapes;

- (void)update: (NSTimeInterval)dt;

- (void)render;

@end
