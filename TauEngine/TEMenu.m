//
//  TEMenu.m
//  TauGame
//
//  Created by Ian Terrell on 8/12/11.
//  Copyright (c) 2011 Ian Terrell. All rights reserved.
//

#import "TEMenu.h"
#import "TECollisionDetector.h"

@implementation TEMenu

@synthesize enabled = _enabled;

- (id)initWithFrame: (CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _buttons = [[NSMutableArray alloc] initWithCapacity: 5];
        _enabled = YES;
    }
    return self;
}

- (void)dealloc
{
    [_buttons release];
    
    [super dealloc];
}

- (void)addButton: (TEButton *)button
{
    [characters addObject: button];
    [_buttons addObject: button];
}

- (void)removeButton: (TEButton *)button
{
    [characters removeObject: button];
    [_buttons removeObject: button];
}

- (void)touchesBegan: (NSSet *)touches
           withEvent: (UIEvent *)event
{
    if (!_enabled)
    {
        return;
    }
    
    _currentButton = nil;
    UITouch *touch = [touches anyObject];
    GLKVector2 location = [self positionForLocationInView:[touch locationInView:self.view]];
    [_buttons enumerateObjectsUsingBlock: (^(TEButton *button, NSUInteger idx, BOOL *stop)
                                           {
                                               if ([TECollisionDetector point: location
                                                             collidesWithNode: button
                                                                  recurseNode: YES])
                                               {
                                                   _currentButton = button;
                                                   [_currentButton setHightLight: YES];
                                                   *stop = YES;
                                               }
                                           })];
}

- (void)touchesMoved: (NSSet *)touches
           withEvent: (UIEvent *)event
{
    if (_currentButton)
    {
        UITouch *touch = [touches anyObject];
        GLKVector2 location = [self positionForLocationInView: [touch locationInView: [self view]]];
        if (![TECollisionDetector point: location
                       collidesWithNode: _currentButton
                            recurseNode: YES])
        {
            [_currentButton setHightLight: NO];
            _currentButton = nil;
        }
    }
}

- (void)touchesCancelled: (NSSet *)touches
               withEvent: (UIEvent *)event
{
    if (_currentButton)
    {
        [_currentButton setHightLight: NO];
        _currentButton = nil;
    }
}

- (void)touchesEnded: (NSSet *)touches
           withEvent: (UIEvent *)event
{
    if (_currentButton != nil)
    {
        [_currentButton setHightLight: NO];
        [_currentButton fire];
        _currentButton = nil;
    }
}

@end
