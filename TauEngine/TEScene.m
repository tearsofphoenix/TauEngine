//
//  TEScene.m
//  TauGame
//
//  Created by Ian Terrell on 7/11/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEScene.h"
#import "TauEngine.h"
#import <QuartzCore/QuartzCore.h>

@implementation TEScene

@synthesize edgeInsets = _edgeInsets;
@synthesize clearColor = _clearColor;
@synthesize characters = _characters;

- (id)initWithFrame: (CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self)
    {
        // OPTIMIZATION: configurable multisample
        [self setDelegate: self];
        
        [self setDrawableMultisample: GLKViewDrawableMultisampleNone];// 4X;
        
        _characters = [[NSMutableArray alloc] init];
        _charactersToAdd = [[NSMutableArray alloc] init];
        
        dirtyProjectionMatrix = YES;
        
        _displayLink = [CADisplayLink displayLinkWithTarget: self
                                                   selector: @selector(update)];
        [_displayLink setFrameInterval: 1];
        [_displayLink addToRunLoop: [NSRunLoop currentRunLoop]
                           forMode: NSDefaultRunLoopMode];
    }
    
    return self;
}

- (void)update
{
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    GLfloat timeSince = currentTime - _lastUpdateTime;

    _lastUpdateTime = currentTime;
    
    // Update all characters
    for (TENode *character in _characters)
    {
        [character update: timeSince
                  inScene: self];
    }
    
    // Remove any who declared they need removed
    NSMutableArray *removed = [[NSMutableArray alloc] init];
    
    [_characters enumerateObjectsUsingBlock: (^(TENode *obj, NSUInteger idx, BOOL *stop)
                                              {
                                                  if ([obj remove])
                                                  {
                                                      [removed addObject: obj];
                                                  }
                                              })];
    
    for (TENode *character in removed)
    {
        [self nodeRemoved:character];
        [character onRemoval];
    }
    
    [removed release];
    
    // Add any who were created in update
    [_characters addObjectsFromArray: _charactersToAdd];
    [_charactersToAdd removeAllObjects];
}

- (void)glkView: (GLKView *)view
     drawInRect: (CGRect)rect
{
    [self render];
}

# pragma mark - Scene Setup
- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets
{
    _edgeInsets = edgeInsets;
    
    dirtyProjectionMatrix = YES;
    [self markChildrensFullMatricesDirty];
}

- (float)visibleWidth
{
    return self.topRightVisible.x - self.bottomLeftVisible.x;
}

- (float)visibleHeight
{
    return self.topRightVisible.y - self.bottomLeftVisible.y;
}

- (GLKVector2)center
{
    return GLKVector2Make((self.topRightVisible.x + self.bottomLeftVisible.x)/2, (self.topRightVisible.y + self.bottomLeftVisible.y)/2);
}

- (GLKVector2)bottomLeftVisible
{
    return GLKVector2Make(_edgeInsets.left, _edgeInsets.bottom);
}

- (GLKVector2)topRightVisible
{
    return GLKVector2Make(_edgeInsets.right, _edgeInsets.top);
}

# pragma mark - Helpers

-(GLKVector2)positionForLocationInView: (CGPoint)location
{
    CGRect frame = [self frame];
    CGSize size = [self size];
    
    float xPercent = location.x / frame.size.width;
    float yPercent = location.y / frame.size.height;
    
    return GLKVector2Make(_edgeInsets.left + xPercent * size.width, _edgeInsets.top - yPercent * size.height);
}

- (CGPoint)locationInViewForPosition: (GLKVector2)position
{
    CGRect frame = [self frame];
    
    float xPercent = (_edgeInsets.right - position.x) / (_edgeInsets.right - _edgeInsets.left);
    float yPercent = (_edgeInsets.top - position.y) / (_edgeInsets.top - _edgeInsets.bottom);
    
    return CGPointMake(xPercent * frame.size.width, frame.size.height - yPercent * frame.size.height);
}

# pragma mark - Rendering

- (void)markChildrensFullMatricesDirty
{
    [_characters makeObjectsPerformSelector: @selector(traverseUsingBlock:)
                                 withObject: (^(TENode *node)
                                              {
                                                  [node setDirtyFullModelViewMatrix: YES];
                                              })];
}

- (void)render
{
    glClearColor(_clearColor.r, _clearColor.g, _clearColor.b, _clearColor.a);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [_characters makeObjectsPerformSelector: @selector(renderInScene:)
                                 withObject: self];
}

- (GLKMatrix4)projectionMatrix
{
    if (dirtyProjectionMatrix)
    {
        cachedProjectionMatrix = GLKMatrix4MakeOrtho(_edgeInsets.left, _edgeInsets.right, _edgeInsets.bottom, _edgeInsets.top, 1.0, -1.0);
        dirtyProjectionMatrix = NO;
    }
    return cachedProjectionMatrix;
}

# pragma mark Scene Updating

- (void)addCharacterAfterUpdate: (TENode *)node
{
    [_charactersToAdd addObject:node];
}

- (void)nodeRemoved: (TENode *)node
{
}

@end
