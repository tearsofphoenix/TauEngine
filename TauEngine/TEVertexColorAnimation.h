//
//  TEVertexColorAnimation.h
//  TauGame
//
//  Created by Ian Terrell on 7/30/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TEAnimation.h"

@interface TEVertexColorAnimation : TEAnimation
{
    int numVertices;
    NSMutableData *_fromColorData;
    NSMutableData *_toColorData;
    NSMutableData *_easedColorData;
}

@property (nonatomic, readonly) GLKVector4 *fromColorVertices;

@property (nonatomic, readonly) GLKVector4 *toColorVertices;

@property (nonatomic, readonly) GLKVector4 *easedColorVertices;

- (GLKVector4)easedColorForVertex:(int)i;

@end
