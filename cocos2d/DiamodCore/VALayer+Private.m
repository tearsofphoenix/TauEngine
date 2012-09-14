//
//  VALayer+Private.m
//  VUEngine
//
//  Created by LeixSnake on 9/11/12.
//
//

#import "VALayer+Private.h"
#import "VGColor.h"
#import "VAScene.h"

@implementation VALayer (Private)

- (void)updateColor
{
	for( NSUInteger i = 0; i < 4; i++ )
	{
		_vertexColors[i] = [_backgroundColor CCColor];
	}
}

void VALayer_renderInScene(VALayer *layer, VAScene *scene)
{
    GLKBaseEffect *effect = layer->_effect;
    GLKTextureInfo *textureInfo = layer->_textureInfo;
    if (textureInfo)
    {
        GLKEffectPropertyTexture *texture2d0 = [effect texture2d0];
        [texture2d0 setEnvMode: GLKTextureEnvModeReplace];
        [texture2d0 setTarget: GLKTextureTarget2D];
        [texture2d0 setName: [textureInfo name]];
    }
    
    // Create a modelview matrix to position and rotate the object
    [[effect transform] setModelviewMatrix: [layer transform]];
    
    // Set up the projection matrix to fit the scene's boundaries
    
    [[effect transform] setProjectionMatrix: [scene projectionMatrix]];
    
    // Tell OpenGL that we're going to use this effect for our upcoming drawing
    [effect prepareToDraw];
    
    // Enable transparency
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // Tell OpenGL that we'll be using vertex position data
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, layer->_vertices);
    
    // If we're using vertex coloring, tell OpenGL that we'll be using vertex color data
    if (layer->_attr->_useTextureColor)
    {
        glEnableVertexAttribArray(GLKVertexAttribColor);
        glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, layer->_vertexColors);
    }
    
    // If we have a texture, tell OpenGL that we'll be using texture coordinate data
    
    if (textureInfo)
    {
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, layer->_textureCoordinates);
    }
    
    // Draw our primitives!
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    // Cleanup: Done with position data
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    
    // Cleanup: Done with color data (only if we used it)
    if (layer->_attr->_useTextureColor)
    {
        glDisableVertexAttribArray(GLKVertexAttribColor);
    }
    
    // Cleanup: Done with texture data (only if we used it)
    if (textureInfo)
    {
        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    }
    
    // Cleanup: Done with the current blend function
    glDisable(GL_BLEND);
    
    for (VALayer *layerLooper in layer->_sublayers)
    {
        VALayer_renderInScene(layerLooper, scene);
    }
}

@end
