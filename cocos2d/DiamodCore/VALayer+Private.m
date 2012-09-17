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

static void ccDrawQuadBezier(CGPoint origin, CGPoint control, CGPoint destination, NSUInteger segments)
{
	GLKVector2 vertices[segments + 1];
	
	float t = 0.0f;
	for(NSUInteger i = 0; i < segments; i++)
	{
		GLfloat x = powf(1 - t, 2) * origin.x + 2.0f * (1 - t) * t * control.x + t * t * destination.x;
		GLfloat y = powf(1 - t, 2) * origin.y + 2.0f * (1 - t) * t * control.y + t * t * destination.y;
		vertices[i] = GLKVector2Make( x * CC_CONTENT_SCALE_FACTOR(), y * CC_CONTENT_SCALE_FACTOR() );
		t += 1.0f / segments;
	}
    
	vertices[segments] = GLKVector2Make(destination.x * CC_CONTENT_SCALE_FACTOR(), destination.y * CC_CONTENT_SCALE_FACTOR());
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_LINE_STRIP, 0, (GLsizei) segments + 1);
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

static void ccDrawCubicBezier(CGPoint origin, CGPoint control1, CGPoint control2, CGPoint destination, NSUInteger segments)
{
	GLKVector2 vertices[segments + 1];
	
	float t = 0;
	for(NSUInteger i = 0; i < segments; i++)
	{
		GLfloat x = powf(1 - t, 3) * origin.x + 3.0f * powf(1 - t, 2) * t * control1.x + 3.0f * (1 - t) * t * t * control2.x + t * t * t * destination.x;
		GLfloat y = powf(1 - t, 3) * origin.y + 3.0f * powf(1 - t, 2) * t * control1.y + 3.0f * (1 - t) * t * t * control2.y + t * t * t * destination.y;
		vertices[i] = GLKVector2Make(x * CC_CONTENT_SCALE_FACTOR(), y * CC_CONTENT_SCALE_FACTOR() );
		t += 1.0f / segments;
	}
	vertices[segments] = GLKVector2Make(destination.x * CC_CONTENT_SCALE_FACTOR(), destination.y * CC_CONTENT_SCALE_FACTOR());
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_LINE_STRIP, 0, (GLsizei) segments + 1);
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

@implementation VALayer (Private)

- (void)_commitLayer
{
    if (_attr->_isTextureInfoDirty)
    {
        GLKEffectPropertyTexture *texture2d0 = [_effect texture2d0];
        [texture2d0 setEnvMode: GLKTextureEnvModeReplace];
        [texture2d0 setTarget: GLKTextureTarget2D];
        [texture2d0 setName: [_textureInfo name]];
        
        _attr->_isTextureInfoDirty = NO;
    }
    
    if (!_attr->_isTransformClean)
    {
        [[_effect transform] setModelviewMatrix: [self transform]];
        
        _attr->_isTransformClean = YES;
    }
    
    if (!_attr->_isProjectionClean)
    {
        [[_effect transform] setProjectionMatrix: [_scene projectionMatrix]];
        
        _attr->_isProjectionClean = YES;
    }
    
    if (!_attr->_isVerticesClean)
    {
        //update vertices
        //
        GLKVector2 *vertices = VALayer_getVertices(self);
        
        CGPoint position = _position;
        
        for (VALayer *layerLooper = _superlayer; layerLooper; layerLooper = layerLooper->_superlayer)
        {
            CGPoint superPosition = [layerLooper position];
            CGRect superBounds = [layerLooper bounds];
            
            position.x += superPosition.x - superBounds.origin.x;
            position.y += superPosition.y - superBounds.origin.y;
        }
        
        CGFloat originX = position.x;
        CGFloat originY = position.y;
        CGFloat sizeWidth = _bounds.size.width;
        CGFloat sizeHeight = _bounds.size.height;
        
        vertices[0] =  GLKVector2Make(originX, originY);
        vertices[1] =  GLKVector2Make(originX + sizeWidth, originY);
        vertices[2] =  GLKVector2Make(originX + sizeWidth, originY + sizeHeight);
        vertices[3] =  GLKVector2Make(originX, originY + sizeHeight);
        
        _attr->_isVerticesClean = YES;
    }
}

- (void)updateColor
{
	for( NSUInteger i = 0; i < 4; i++ )
	{
		_vertexColors[i] = [_backgroundColor CCColor];
	}
}

GLKVector2 *VALayer_getVertices(VALayer *layer)
{
    if (!layer->_vertices)
    {
        layer->_vertices = malloc(sizeof(GLKVector2) * layer->_verticeCount);
    }
    
    return layer->_vertices;
}

void VALayer_renderInScene(VALayer *layer)
{
    GLKBaseEffect *effect = layer->_effect;
    GLKTextureInfo *textureInfo = layer->_textureInfo;
    
    [layer _commitLayer];
    
    // Tell OpenGL that we're going to use this effect for our upcoming drawing
    [effect prepareToDraw];
    
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
        VALayer_renderInScene(layerLooper);
    }
}

@end
