//
//  VARenderer.h
//  VUEngine
//
//  Created by LeixSnake on 9/14/12.
//
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class VALayer;

@interface VARenderer : NSObject

- (void)endFrame;

+ (VARenderer *)rendererWithCGLContext: (void *)ctx
                               options: (NSDictionary *)dict;

- (void)render;

- (BOOL)hasMissingContent;

- (CFTimeInterval)nextFrameTime;

- (void)addUpdateRect: (CGRect)rect;

- (CGRect)updateBounds;

- (void)beginFrameAtTime: (CFTimeInterval)timeInterval
               timeStamp: (CVTimeStamp *)timeStamp;

@property (atomic, retain) EAGLContext *context;

@property (atomic, assign) id delegate;

@property (atomic, retain) VALayer *layer;

@property (atomic) CGRect bounds;

@end
