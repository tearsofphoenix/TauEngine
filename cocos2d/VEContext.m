//
//  VEContext.m
//  VUEngine
//
//  Created by tearsofphoenix on 8/30/12.
//
//

#import "VEContext.h"
#import "ccGLStateCache.h"
#import "CCGLProgram.h"

@interface VEContext ()
{
@private
    NSMutableArray *_renderQueue;
}
@end

@implementation VEContext

- (id)init
{
    if ((self = [super init]))
    {
        _renderQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_renderQueue release];
    [super dealloc];
}

void VEContextAddLayer(VEContext *context, CCLayer *layer)
{
    [context->_renderQueue addObject: layer];
}

void VEContextRender(VEContext *context)
{
    for (CCLayer *layer in context->_renderQueue)
    {
        /*
        CC_NODE_DRAW_SETUP();
        
        VEGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );
        
        //
        // Attributes
        //
        glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, squareVertices_);
        glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, 0, squareColors_);
        
        CCGLBlendFunc( _blendFunc.src, _blendFunc.dst );
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        */
        CC_INCREMENT_GL_DRAWS(1);
    }
}

@end
