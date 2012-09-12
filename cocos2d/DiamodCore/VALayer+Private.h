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
    unsigned int _delegateRespondsToDisplayLayer: 1;
    unsigned int _delegateRespondsToDrawLayerInContext: 1;
    unsigned int _delegateRespondsToLayoutSublayersOfLayer: 1;
    unsigned int _delegateRespondsToActionForLayerForKey: 1;
};

@interface VALayer (Private)

- (void)updateColor;

@end
