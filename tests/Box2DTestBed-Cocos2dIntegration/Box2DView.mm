//
//  Box2DView.mm
//  Box2D OpenGL View
//
//  Box2D iPhone port by Simon Oliver - http://www.simonoliver.com - http://www.handcircus.com
//

//
// File heavily modified for cocos2d integration
// http://www.cocos2d-iphone.org
//

#import "Box2DView.h"
#import "iPhoneTest.h"

#define kAccelerometerFrequency 30
#define FRAMES_BETWEEN_PRESSES_FOR_DOUBLE_CLICK 10

extern int g_totalEntries;

Settings settings;

@implementation MenuLayer

+(id) menuWithEntryID:(int)entryId
{
	return [[[self alloc] initWithEntryID:entryId] autorelease];
}

- (id) initWithEntryID:(int)entryId
{
	if ((self = [super init]))
    {
        
		CGSize s = [[CCDirector sharedDirector] winSize];
        
		entryID = entryId;
        
		_isUserInteractionEnabled = YES;
        
		Box2DView *view = [Box2DView viewWithEntryID:entryId];
        
        _box2DNode = view;
        
		[self addChild: view
                     z: 0];
		[view setScale:15];
		[view setAnchorPoint:ccp(0,0)];
		[view setPosition:ccp(s.width/2, s.height/3)];
        
		CCTTFLabel* label = [[CCTTFLabel alloc] initWithString:[view title] fontName:@"Helvetica" fontSize:32];
        
		[self addChild: label z:1];
        [label release];
		[label setPosition: ccp(s.width/2, s.height-50)];
        
		CCMenuItemImage *item1 = [[CCMenuItemImage alloc] initWithNormalImage: @"b1.png"
                                                                selectedImage: @"b2.png"
                                                                disabledImage: nil
                                                                        block: nil];
        [item1 addTarget: self
               forAction: @selector(backCallback:)];
        
		CCMenuItemImage *item2 = [[CCMenuItemImage alloc] initWithNormalImage: @"r1.png"
                                                                selectedImage: @"r2.png"
                                                                disabledImage: nil
                                                                        block: nil];
        [item2 addTarget: self
               forAction: @selector(restartCallback:)];
        
		CCMenuItemImage *item3 = [[CCMenuItemImage alloc] initWithNormalImage: @"f1.png"
                                                                selectedImage: @"f2.png"
                                                                disabledImage: nil
                                                                        block: nil];
        
        [item3 addTarget: self
               forAction: @selector(nextCallback:)];
        
		CCMenu *menu = [[CCMenu alloc] initWithArray: [NSArray arrayWithObjects:item1, item2, item3, nil]];
        
        [item1 release];
        [item2 release];
        [item3 release];
        
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 150,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 150,30);
		[self addChild: menu z:1];
        
        [menu release];
        [view setBackgroundColor: ccBLUE];
        [view setOpacity: 0];
        [item1 setOpacity: 0];
        
        [CCLayer animateWithDuration: 2.0
                          animations: (^
                                       {
                                           [item1 setOpacity: 255];
                                       })
                          completion: (^(BOOL finished)
                                       {
                                           [view setBackgroundColor: ccBLACK];
                                       })];
	}
	return self;
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	id box = [MenuLayer menuWithEntryID:entryID];
	[s addChild:box];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	int next = entryID + 1;
	if( next >= g_totalEntries)
		next = 0;
	id box = [MenuLayer menuWithEntryID:next];
	[s addChild:box];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	int next = entryID - 1;
	if( next < 0 ) {
		next = g_totalEntries - 1;
	}
    
	id box = [MenuLayer menuWithEntryID:next];
	[s addChild:box];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) registerWithTouchDispatcher
{
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];
    
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
    
	CGPoint diff = ccpSub(touchLocation,prevLocation);
    
	CGPoint currentPos = [_box2DNode position];
	[_box2DNode setPosition: ccpAdd(currentPos, diff)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return g_totalEntries;
}

- (UITableViewCell *)tableView: (UITableView *)tableView
         cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    TestEntry entry = g_testEntries[[indexPath row]];
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    [[cell textLabel] setFont: [UIFont fontWithName: @"Helvetica"
                                               size: 14]];
    [[cell textLabel] setText: [NSString stringWithUTF8String: entry.name]];
    return [cell autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCScene *s = [CCScene node];
	int next = [indexPath row];
	if( next >= g_totalEntries)
    {
		next = 0;
    }
    
	id box = [MenuLayer menuWithEntryID: next];
	[s addChild: box];
	[[CCDirector sharedDirector] replaceScene: s];
    
}

@end

#pragma mark -
#pragma mark Box2DView
@implementation Box2DView

+(id) viewWithEntryID:(int)entryId
{
	return [[[self alloc] initWithEntryID:entryId] autorelease];
}

- (id) initWithEntryID:(int)entryId
{
    if ((self = [super init]))
    {
		_isUserInteractionEnabled = YES;
        
        [_scheduler scheduleSelector: @selector(tick:)
                           forTarget: self
                            interval: 0
                              paused: NO];
        
		entry = g_testEntries + entryId;
		test = entry->createFcn();
        
    }
    
    return self;
}

-(NSString*) title
{
	return [NSString stringWithCString:entry->name encoding:NSUTF8StringEncoding];
}

- (void)tick:(NSTimeInterval) dt
{
    test->Step(&settings);
}

- (void)draw
{
	[super draw];
    
	VEGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    
	VEGLPushMatrix();
    
	test->m_world->DrawDebugData();
    
	VEGLPopMatrix();
    
	CHECK_GL_ERROR_DEBUG();
}

- (void)dealloc
{
	delete test;
    [super dealloc];
}

-(void) registerWithTouchDispatcher
{
	// higher priority than dragging
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:-10 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
    
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
    //	NSLog(@"pos: %f,%f -> %f,%f", touchLocation.x, touchLocation.y, nodePosition.x, nodePosition.y);
    
	return test->MouseDown(b2Vec2(nodePosition.x,nodePosition.y));
}

- (void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
    
	test->MouseMove(b2Vec2(nodePosition.x,nodePosition.y));
}

- (void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
    
	test->MouseUp(b2Vec2(nodePosition.x,nodePosition.y));
}


- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	// Only run for valid values
	if (acceleration.y!=0 && acceleration.x!=0)
	{
		if (test) test->SetGravity((float)-acceleration.y,(float)acceleration.x);
	}
}

@end
