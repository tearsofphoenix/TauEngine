//
//  TEPolygon.h
//  TauGame
//
//  Created by Ian Terrell on 7/26/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEShape.h"

@interface TEPolygon : TEShape

- (id)initWithVertices: (int)numVertices;

- (int)numEdges;
- (int)edgeVerticesOffset;


@end
