//
//  VEScene.h
//  ExampleEngine
//
//  Created by Ian Terrell on 8/16/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import <GLKit/GLKit.h>

@class VEGravityField;

@interface VEScene : NSObject
{
    GLKVector4 _clearColor;
    UIEdgeInsets _edgeInsets;
    
    NSMutableArray *_shapes;
}

@property (nonatomic) GLKVector4 clearColor;

@property (nonatomic) UIEdgeInsets edgeInsets;

@property (nonatomic, readonly) GLKMatrix4 projectionMatrix;

@property (strong,readonly) NSMutableArray *shapes;

@property (nonatomic, strong) VEGravityField *gravityField;

@property (nonatomic, strong) NSArray *fields;

- (void)update: (NSTimeInterval)dt;

- (void)render;

@end
