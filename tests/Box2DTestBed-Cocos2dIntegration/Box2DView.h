//
//  Box2DView.h
//  Box2D OpenGL View
//
//  Box2D iPhone port by Simon Oliver - http://www.simonoliver.com - http://www.handcircus.com
//

//
// File heavily modified for cocos2d integration
// http://www.cocos2d-iphone.org
//


#import <UIKit/UIKit.h>

#import "cocos2d.h"

#import "iPhoneTest.h"

@class VIView;

@interface MenuLayer : VALayer<UITableViewDataSource, UITableViewDelegate>
{
    VALayer *_box2DNode;
	int		entryID;
}

+(id) menuWithEntryID:(int)entryId;
-(id) initWithEntryID:(int)entryId;

@end

@interface Box2DView : VAScene
{
	TestEntry* entry;
	Test* test;
	int		entryID;
}

+ (id)viewWithEntryID:(int)entryId;

- (id)initWithEntryID:(int)entryId;

- (NSString*) title;

@property (nonatomic, assign) VIView *view;

@end
