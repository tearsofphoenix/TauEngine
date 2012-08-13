//
//  VEAnimation.m
//  ExampleEngine
//
//  Created by Ian Terrell on 8/19/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "VEAnimation.h"
#import "VEShape.h"

@implementation VEAnimation

@synthesize duration = _duration;
@synthesize elapsedTime =_elapsedTime;

@synthesize positionDelta = _positionDelta;
@synthesize rotationDelta = _rotationDelta;
@synthesize scaleDelta = _scaleDelta;

@synthesize colorDelta = _colorDelta;

@synthesize completion = _completion;

- (id)init
{
    self = [super init];
    if (self)
    {
        _elapsedTime = 0;
        _duration = 0;
        _positionDelta = GLKVector2Make(0,0);
        _rotationDelta = 0;
        _scaleDelta = GLKVector2Make(0,0);
        _colorDelta = GLKVector4Make(0,0,0,0);
    }
    
    return self;
}

- (void)dealloc
{
    if (_completion)
    {
        Block_release(_completion);
    }
    
    [super dealloc];
}

- (void)animateShape: (VEShape *)shape
                  dt: (NSTimeInterval)dt
{    
    _elapsedTime += dt;
    
    if (_elapsedTime > _duration)
    {
        dt -= _elapsedTime - _duration;
    }
    
    float fractionOfDuration = dt / _duration;
    
    GLKVector2 positionIncrement = GLKVector2MultiplyScalar(_positionDelta, fractionOfDuration);
    
    [shape setPosition: GLKVector2Add([shape position], positionIncrement)];
    
    GLKVector4 colorIncrement = GLKVector4MultiplyScalar(_colorDelta, fractionOfDuration);
    [shape setColor: GLKVector4Add([shape color], colorIncrement)];
    
    GLKVector2 scaleIncrement = GLKVector2MultiplyScalar(_scaleDelta, fractionOfDuration);
    [shape setScale: GLKVector2Add([shape scale], scaleIncrement)];
    
    [shape setRotation: [shape rotation] + _rotationDelta * fractionOfDuration];
}

@end
