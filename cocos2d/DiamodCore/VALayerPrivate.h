//
//  VALayerPrivate.h
//  VUEngine
//
//  Created by LeixSnake on 9/12/12.
//
//

#import <Foundation/Foundation.h>

struct VALayerAttribute
{
    unsigned int _delegateRespondsToDisplayLayer: 1;
    unsigned int _delegateRespondsToDrawLayerInContext: 1;
    unsigned int _delegateRespondsToLayoutSublayersOfLayer: 1;
    unsigned int _delegateRespondsToActionForLayerForKey: 1;
};

