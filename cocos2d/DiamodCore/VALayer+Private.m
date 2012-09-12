//
//  VALayer+Private.m
//  VUEngine
//
//  Created by LeixSnake on 9/11/12.
//
//

#import "VALayer+Private.h"
#import "VGColor.h"

@implementation VALayer (Private)

- (void) updateColor
{
	for( NSUInteger i = 0; i < 4; i++ )
	{
		squareColors_[i] = [_backgroundColor CCColor];
	}
}

@end
