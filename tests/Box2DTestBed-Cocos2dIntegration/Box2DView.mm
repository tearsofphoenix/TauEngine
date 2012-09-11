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
#import "VGContext.h"

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
        
		[self addChild: view];
        
		[view setScale:15];
		[view setAnchorPoint:ccp(0,0)];
		[view setPosition:ccp(s.width/2, s.height/3)];
        

        [view setBackgroundColor: ccBLUE];
        [view setOpacity: 0];
        
        CGPoint origin = [view position];
        
        [VALayer animateWithDuration: 2.0
                          animations: (^
                                       {
                                           [view setOpacity: 1];
                                           [view setPosition: CGPointMake(0, 10)];
                                       })
                          completion: (^(BOOL finished)
                                       {
                                           [view setBackgroundColor: ccBLACK];
                                           [view setPosition: origin];
                                           [VALayer animateWithDuration: 3.0
                                                             animations: (^
                                                                          {
                                                                              [view setBackgroundColor: ccRED];
                                                                          })];
                                       })];
	}
	return self;
}

-(void) restartCallback: (id) sender
{
	VAScene *s = [VAScene node];
	id box = [MenuLayer menuWithEntryID:entryID];
	[s addChild:box];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	VAScene *s = [VAScene node];
	int next = entryID + 1;
	if( next >= g_totalEntries)
		next = 0;
	id box = [MenuLayer menuWithEntryID:next];
	[s addChild:box];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	VAScene *s = [VAScene node];
	int next = entryID - 1;
	if( next < 0 ) {
		next = g_totalEntries - 1;
	}
    
	id box = [MenuLayer menuWithEntryID:next];
	[s addChild:box];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{

}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
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
    VAScene *s = [VAScene node];
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
        [self setOpacity: 0];
    }
    
    return self;
}

-(NSString*) title
{
	return [NSString stringWithUTF8String: entry->name];
}

- (void)tick: (NSTimeInterval) dt
{
    test->Step(&settings);
}

- (void)drawInContext: (VGContext *)context
{
	[super drawInContext: context];
    
	VEGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    
	VGContextSaveState(context);
    
	test->m_world->DrawDebugData();
    
	VGContextRestoreState(context);
    
	CHECK_GL_ERROR_DEBUG();
}

- (void)dealloc
{
	delete test;
    [super dealloc];
}

- (void) touchBegan: (UITouch*)touch
          withEvent: (UIEvent*)event
{
    
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
    
	test->MouseDown(b2Vec2(nodePosition.x,nodePosition.y));
}

- (void) touchMoved:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
    
	test->MouseMove(b2Vec2(nodePosition.x,nodePosition.y));
}

- (void) touchEnded:(UITouch*)touch withEvent:(UIEvent*)event
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
