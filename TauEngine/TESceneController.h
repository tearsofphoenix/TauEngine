//
//  TESceneController.h
//  TauGame
//
//  Created by Ian Terrell on 7/18/11.
//  Copyright 2011 Ian Terrell. All rights reserved.
//

#import <GLKit/GLKit.h>

@class TEScene;

@interface TESceneController : UIViewController
{
    UIView *_contentView;
    
    EAGLContext *_context;
    NSMutableDictionary *_scenes;
    TEScene *_currentScene;
    TEScene *_previousScene;
}

@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, strong, readonly) EAGLContext *context;

@property (nonatomic, strong, readonly) TEScene *currentScene;

@property (nonatomic, strong, readonly) NSString *currentSceneName;

@property (nonatomic, strong, readonly) NSMutableDictionary *scenes;

# pragma mark Scene Management

- (TEScene *)sceneNamed: (NSString *)name;

- (void)addSceneOfClass: (Class)sceneClass
                  named: (NSString *)name;

- (void)addScene: (TEScene *)scene
           named: (NSString *)name;

- (void)removeScene:(NSString *)name;

- (void)displayScene: (NSString *)name;

- (void)displayScene: (NSString *)name
            duration: (NSTimeInterval)duration
             options: (UIViewAnimationOptions)options
          completion: (void (^)(BOOL finished))completion;

- (void)replaceCurrentSceneWithScene: (TEScene *)scene
                               named: (NSString*)name;

- (void)replaceCurrentSceneWithScene: (TEScene *)scene
                               named: (NSString *)name
                            duration: (NSTimeInterval)duration
                             options: (UIViewAnimationOptions)options
                          completion: (void (^)(BOOL finished))completion;

@end

extern NSString *const kTEPreviousScene;
