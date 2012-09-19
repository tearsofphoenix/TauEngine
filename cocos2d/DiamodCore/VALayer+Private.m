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
#import "TransformUtils.h"
#import "VAMacros.h"
#import "VGContext.h"

static const NSUInteger verticeCountForEachCorner = 8;

static void ccDrawQuadBezier(CGPoint origin, CGPoint control, CGPoint destination,
                             NSUInteger segments, GLKVector2 *vertices)
{	
	float t = 0.0f;
	for(NSUInteger i = 0; i < segments; i++)
	{
		GLfloat x = powf(1 - t, 2) * origin.x + 2.0f * (1 - t) * t * control.x + t * t * destination.x;
		GLfloat y = powf(1 - t, 2) * origin.y + 2.0f * (1 - t) * t * control.y + t * t * destination.y;
		vertices[i] = GLKVector2Make( x * CC_CONTENT_SCALE_FACTOR(), y * CC_CONTENT_SCALE_FACTOR() );
		t += 1.0f / segments;
	}
    
	vertices[segments] = GLKVector2Make(destination.x * CC_CONTENT_SCALE_FACTOR(), destination.y * CC_CONTENT_SCALE_FACTOR());
}

static void ccDrawCubicBezier(CGPoint origin, CGPoint control1, CGPoint control2, CGPoint destination,
                              NSUInteger segments, GLKVector2 *vertices)
{	
	float t = 0;
	for(NSUInteger i = 0; i < segments; i++)
	{
		GLfloat x = powf(1 - t, 3) * origin.x + 3.0f * powf(1 - t, 2) * t * control1.x + 3.0f * (1 - t) * t * t * control2.x + t * t * t * destination.x;
		GLfloat y = powf(1 - t, 3) * origin.y + 3.0f * powf(1 - t, 2) * t * control1.y + 3.0f * (1 - t) * t * t * control2.y + t * t * t * destination.y;
		vertices[i] = GLKVector2Make(x * CC_CONTENT_SCALE_FACTOR(), y * CC_CONTENT_SCALE_FACTOR() );
		t += 1.0f / segments;
	}
    
	vertices[segments] = GLKVector2Make(destination.x * CC_CONTENT_SCALE_FACTOR(), destination.y * CC_CONTENT_SCALE_FACTOR());
}

@implementation VALayer (Private)

- (void)_commitLayerInContextt: (VGContext *)context
{
    if (!_attr->_isTransformClean)
    {
        _cachedFullModelviewMatrix = _transform;
        for (VALayer *layerLooper = _superlayer; layerLooper; layerLooper = layerLooper->_superlayer)
        {
            _cachedFullModelviewMatrix = GLKMatrix4Multiply([layerLooper transform], _cachedFullModelviewMatrix);
        }
        
        VGContextMatrixMode(context, GL_MODELVIEW_MATRIX);
        VGContextLoadCTM(context, _cachedFullModelviewMatrix);
        
        VGContextMatrixMode(context, GL_PROJECTION_MATRIX);
        VGContextLoadCTM(context, [_scene projectionMatrix]);
        
        _attr->_isTransformClean = YES;
    }
    
    if (!_attr->_isVerticesClean)
    {
        //update vertices
        //
        GLKVector2 *vertices = _vertices;
        
        CGPoint position = CGPointApplyAffineTransform(_position, GLKMatrix4ToCGAffineTransform(&_cachedFullModelviewMatrix));
        
        CGFloat originX = position.x;
        CGFloat originY = position.y;
        CGFloat sizeWidth = _bounds.size.width;
        CGFloat sizeHeight = _bounds.size.height;

        if (_cornerRadius != 0)
        {
            _verticeCount = 48;
            ccDrawQuadBezier(CGPointMake(originX, originY + _cornerRadius),
                             CGPointMake(originX, originY),
                             CGPointMake(originX + _cornerRadius, originY),
                             11, _vertices);
            
            ccDrawQuadBezier(CGPointMake(originX + sizeWidth - _cornerRadius, originY),
                             CGPointMake(originX + sizeWidth, originY),
                             CGPointMake(originX + sizeWidth, originY + _cornerRadius),
                             11, _vertices + 12);
            
            ccDrawQuadBezier(CGPointMake(originX + sizeWidth, originY + sizeHeight - _cornerRadius),
                             CGPointMake(originX + sizeWidth, originY + sizeHeight),
                             CGPointMake(originX + sizeWidth - _cornerRadius, originY + sizeHeight),
                             11, _vertices + 24);
            
            ccDrawQuadBezier(CGPointMake(originX + _cornerRadius, originY + sizeHeight),
                             CGPointMake(originX, originY + sizeHeight),
                             CGPointMake(originX, originY + sizeHeight - _cornerRadius),
                             11, _vertices + 36);

        }else
        {
            vertices[0] =  GLKVector2Make(originX, originY);
            vertices[1] =  GLKVector2Make(originX + sizeWidth, originY);
            vertices[2] =  GLKVector2Make(originX + sizeWidth, originY + sizeHeight);
            vertices[3] =  GLKVector2Make(originX, originY + sizeHeight);
        }
        
        _attr->_isVerticesClean = YES;
    }
    
    for (VALayer *layerLooper in _sublayers)
    {
        [layerLooper _commitLayerInContextt: context];
    }
    
}

- (void)updateColor
{
	for( NSUInteger i = 0; i < 4; i++ )
	{
		_vertexColors[i] = [_backgroundColor CCColor];
	}
}

bool VALayer_attribute_useTextureColor(VALayer *layer)
{
    return layer->_attr->_useTextureColor;
}

bool VALayer_attribute_useTexture(VALayer *layer)
{
    return layer->_textureInfo;
}

@end
