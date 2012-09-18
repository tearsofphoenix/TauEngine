//
//  VALayer+Private.h
//  VUEngine
//
//  Created by LeixSnake on 9/11/12.
//
//

#import "VALayer.h"

struct VALayerAttribute
{
    unsigned int _isUserInteractionDisabled: 1;

    
    unsigned int _isHidden: 1;
    
    unsigned int _isTransformClean: 1;
	unsigned int _isInverseClean: 1;
    unsigned int _isProjectionClean: 1;
    unsigned int _isVerticesClean: 1;
    
    unsigned int _isGeometryFlipped: 1;
    unsigned int _needsDisplayOnBoundsChange: 1;
    unsigned int _isPresentationLayer: 1;

    unsigned int _isLayoutingSublayers: 1;
    unsigned int _shouldRasterize: 1;
    unsigned int _drawsAsynchronously: 1;
    unsigned int _masksToBounds: 1;
    unsigned int _isOpaque: 1;
    unsigned int _needsDisplay: 1;
    unsigned int _needsLayout: 1;
    unsigned int _useTextureColor: 1;
    
    //Texture Info
    unsigned int _isTextureInfoDirty: 1;

    unsigned int _delegateRespondsToDisplayLayer: 1;
    unsigned int _delegateRespondsToDrawLayerInContext: 1;
    unsigned int _delegateRespondsToLayoutSublayersOfLayer: 1;
    unsigned int _delegateRespondsToActionForLayerForKey: 1;
};

@interface VALayer ()
{
@protected
    VALayer *_presentationLayer;
    VALayer *_modelLayer;
    VAScene *_scene;
    
    GLKBaseEffect *_effect;
    GLKTextureInfo *_textureInfo;
        
    VACameraRef _camera;
    
    NSUInteger _verticeCount;
    GLKVector2 _vertices[48];
    GLKVector2 _textureCoordinates[4];
    GLKVector4 _vertexColors[4];
}

@property (copy) NSDictionary *animations;

@property (copy) NSArray *animationKeys;

@end

@interface VALayer (Private)

- (void)updateColor;

- (void)_commitLayer;

@end

extern void VALayer_renderInScene(VALayer *layer);

//extern GLKVector2 *VALayer_getVertices(VALayer *layer);
