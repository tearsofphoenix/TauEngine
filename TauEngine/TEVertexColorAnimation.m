//
//  TEVertexColorAnimation.m
//  TauGame
//
//  Created by Ian Terrell on 7/30/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEVertexColorAnimation.h"
#import "TEShape.h"
#import "TENode.h"

@implementation TEVertexColorAnimation

@synthesize fromColorVertices = _fromColorVertices;
@synthesize easedColorVertices = _easedColorVertices;
@synthesize toColorVertices = _toColorVertices;

- (id)initWithNode: (TENode *)node
{
    self = [super initWithNode: node];
    if (self)
    {
        numVertices = [self node].shape.numVertices;
        
        _fromColorData = [[self node].shape colorData];
        _fromColorVertices = [_fromColorData mutableBytes];
        
        _easedColorData = [_fromColorData mutableCopy];
        _easedColorVertices = [_easedColorData mutableBytes];
    }
    
    return self;
}

- (GLKVector4 *)toColorVertices
{
    if (_toColorData == nil)
    {
        _toColorData = [NSMutableData dataWithLength: sizeof(GLKVector4) * numVertices];
        _toColorVertices = [_toColorData mutableBytes];
    }
    return _toColorVertices;
}

- (GLKVector4)easedColorForVertex: (int)i
{
    return GLKVector4Add(self.fromColorVertices[i],
                         GLKVector4MultiplyScalar( GLKVector4Subtract(self.toColorVertices[i], self.fromColorVertices[i]),
                                                  self.easingFactor));
}

- (void)incrementElapsedTime: (NSTimeInterval)time
{
    [super incrementElapsedTime:time];
    
    for (int i = 0; i < numVertices; i++)
    {
        _easedColorVertices[i] = [self easedColorForVertex:i];
    }
}

- (void)permanentize
{
    for (int i = 0; i < numVertices; i++)
    {
        self.node.shape.colorVertices[i] = _toColorVertices[i];
    }
}

@end
