//
//  VARenderer.m
//  VUEngine
//
//  Created by LeixSnake on 9/14/12.
//
//

#import "VARenderer.h"

@interface VARenderer ()
{
@private
    CGRect _updateBounds;
}

@end

@implementation VARenderer

@synthesize context = _context;

@synthesize delegate = _delegate;

@synthesize layer = _layer;

@synthesize bounds = _bounds;


- (void)endFrame
{
    
}

+ (VARenderer *)rendererWithCGLContext: (void *)ctx
                               options: (NSDictionary *)dict
{
    return [[[self alloc] _initWithEAGLContext: ctx
                                       options: dict] autorelease];
}

- (id)_initWithEAGLContext: (EAGLContext *)context
                   options: (NSDictionary *)options
{
    if ((self = [super init]))
    {
        [self setContext: context];
    }
    return self;
}

- (void)dealloc
{
    [_layer release];
    [_context release];
    
    [super dealloc];
}

- (void)render
{
   
}

- (BOOL)hasMissingContent
{
    return NO;
}

- (CFTimeInterval)nextFrameTime
{
    return 1.0 / 60.0;
}

- (void)addUpdateRect: (CGRect)rect
{
    _updateBounds = CGRectUnion(_updateBounds, rect);
}

- (CGRect)updateBounds
{
    return _updateBounds;
}

- (void)beginFrameAtTime: (CFTimeInterval)timeInterval
               timeStamp: (CVTimeStamp *)timeStamp
{
    
}


@end
