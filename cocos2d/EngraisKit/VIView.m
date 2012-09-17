//
//  VIView.m
//  VUEngine
//
//  Created by LeixSnake on 9/17/12.
//
//

#import "VIView.h"
#import "VALayer.h"

@implementation VIView

@synthesize currentScene = _currentScene;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: self];
    VALayer *responsibleLayer = [_currentScene hitTest: [self convertToGL: location]];
    [responsibleLayer touchBegan: touch
                       withEvent: event];
    NSLog(@"in func: %s %@", __func__, responsibleLayer);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: self];
    VALayer *responsibleLayer = [_currentScene hitTest: [self convertToGL: location]];
    [responsibleLayer touchEnded: touch
                       withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: self];
    VALayer *responsibleLayer = [_currentScene hitTest: [self convertToGL: location]];
    [responsibleLayer touchMoved: touch
                       withEvent: event];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: self];
    VALayer *responsibleLayer = [_currentScene hitTest: [self convertToGL: location]];
    [responsibleLayer touchCancelled: touch
                           withEvent: event];
    
}

- (CGPoint)convertToGL: (CGPoint)uiPoint
{
	CGSize s = [self bounds].size;
	float newY = s.height - uiPoint.y;
    
	return CGPointMake( uiPoint.x, newY );
}



- (CGPoint)convertToUI: (CGPoint)glPoint
{
	CGSize s = [self bounds].size;
	int oppositeY = s.height - glPoint.y;
    
	return CGPointMake(glPoint.x, oppositeY);
}

@end
