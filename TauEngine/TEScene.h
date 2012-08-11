//
//  TEScene.h
//  TauGame
//
//  Created by Ian Terrell on 7/11/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class TENode;
@class CADisplayLink;

@interface TEScene : GLKView <GLKViewDelegate>
{
    UIEdgeInsets _edgeInsets;
    NSTimeInterval _lastUpdateTime;
    GLKVector4 _clearColor;
    NSMutableArray *_characters;
    NSMutableArray *_charactersToAdd;
    
    CADisplayLink *_displayLink;
    
    GLKMatrix4 cachedProjectionMatrix;
    BOOL dirtyProjectionMatrix;
}

@property (nonatomic, readonly) UIEdgeInsets edgeInsets;

@property (nonatomic, readonly) CGSize size;

@property (nonatomic) GLKVector4 clearColor;

@property (nonatomic, strong, nonatomic) NSMutableArray *characters;

# pragma mark Scene Setup

@property (nonatomic, readonly) CGSize visibleSize;

@property (nonatomic,  readonly) GLKVector2 center;

@property (nonatomic,  readonly) GLKVector2 bottomLeftVisible;

@property (nonatomic,  readonly) GLKVector2 topRightVisible;

# pragma mark - Helpers

- (GLKVector2)positionForLocationInView: (CGPoint)location;

- (CGPoint)locationInViewForPosition: (GLKVector2)position;

# pragma mark Rendering

- (void)render;

- (void)markChildrensFullMatricesDirty;

- (GLKMatrix4)projectionMatrix;

# pragma mark Scene Updating

- (void)addCharacterAfterUpdate: (TENode *)node;
- (void)nodeRemoved: (TENode *)node;

@end
