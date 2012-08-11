//
//  TESceneController.m
//  TauGame
//
//  Created by Ian Terrell on 7/18/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import "TESceneController.h"
#import "TEScene.h"

#define DEFAULT_SCENE_TRANSITION_DURATION (0.5)
#define DEFAULT_SCENE_TRANSITION_OPTIONS (UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionTransitionCrossDissolve)

NSString * const kTEPreviousScene = @"kTEPreviousScene";

@implementation TESceneController

@synthesize contentView = _contentView;
@synthesize context = _context;
@synthesize currentScene = _currentScene;
@synthesize currentSceneName = _currentSceneName;
@synthesize scenes = _scenes;

- (id)init
{
    self = [super init];
    if (self)
    {
        _scenes = [[NSMutableDictionary alloc] init];
        _context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext: _context];
        
        _contentView = [[UIView alloc] initWithFrame: [[self view] frame]];
        
        [_contentView setAutoresizingMask: UIViewAutoresizingFlexibleWidth
         | UIViewAutoresizingFlexibleHeight];
        
        [[self view] addSubview: _contentView];
    }
    
    return self;
}

# pragma mark Scene Management

- (TEScene *)sceneNamed: (NSString *)name
{
    return [_scenes objectForKey: name];
}

- (void)addSceneOfClass: (Class)sceneClass
                  named: (NSString *)name
{
    id scene = [[sceneClass alloc] initWithFrame: [_contentView frame]];
    
    [self addScene: scene
             named: name];
    
    [scene release];
}

- (void)addScene: (TEScene *)scene
           named: (NSString *)name
{
    [_contentView addSubview: scene];
    
    [scene setContext: _context];
    
    [_scenes setObject: scene
                forKey: name];
}

- (void)removeScene: (NSString *)name
{
    [[_scenes objectForKey: name] removeFromSuperview];
    [_scenes removeObjectForKey: name];
}

- (void)displayScene: (NSString *)name
{
    [self displayScene: name
              duration: DEFAULT_SCENE_TRANSITION_DURATION
               options: DEFAULT_SCENE_TRANSITION_OPTIONS
            completion: nil];
}

- (void)displayScene: (NSString *)name
            duration: (NSTimeInterval)duration
             options: (UIViewAnimationOptions)options
          completion: (void (^)(BOOL finished))completion
{
    TEScene *newScene = name == kTEPreviousScene ? _previousScene : [_scenes objectForKey: name];
    if (_currentScene == nil)
    {
        [_contentView addSubview: newScene];
        
    }else
    {
        _previousScene = _currentScene;
        [UIView transitionFromView: _currentScene
                            toView: newScene
                          duration: duration
                           options: options
                        completion: completion];
    }
    
    _currentScene = newScene;
    _currentSceneName = name;
}

- (void)replaceCurrentSceneWithScene: (TEScene *)scene
                               named: (NSString*)name
{
    [self replaceCurrentSceneWithScene: scene
                                 named: name
                              duration: DEFAULT_SCENE_TRANSITION_DURATION
                               options: DEFAULT_SCENE_TRANSITION_OPTIONS
                            completion: nil];
}

- (void)replaceCurrentSceneWithScene: (TEScene *)scene
                               named: (NSString *)name
                            duration: (NSTimeInterval)duration
                             options: (UIViewAnimationOptions)options
                          completion: (void (^)(BOOL finished))completion
{
    NSString *oldScene = _currentSceneName;
    [self addScene: scene
             named: name];
    
    [self displayScene: name
              duration: duration
               options: options
            completion: (^(BOOL finished)
                         {
                             [self removeScene: oldScene];
                             if (completion)
                             {
                                 completion(finished);
                             }
                         })];
}

# pragma mark Device Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

@end
