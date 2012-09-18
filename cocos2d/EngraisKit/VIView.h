//
//  VIView.h
//  VUEngine
//
//  Created by LeixSnake on 9/17/12.
//
//

#import <GLKit/GLKit.h>

@class VAScene;

@interface VIView : GLKView

@property (nonatomic, retain) VAScene *currentScene;

- (CGPoint)convertToGL: (CGPoint)uiPoint;

- (CGPoint)convertToUI: (CGPoint)glPoint;

@end
