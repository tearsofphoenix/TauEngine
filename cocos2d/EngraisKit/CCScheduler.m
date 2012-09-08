/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


// cocos2d imports
#import "CCScheduler.h"
#import "ccMacros.h"
#import "CCDirector.h"
#import "VEDataSource.h"

//
// Data structures
//
#pragma mark -
#pragma mark Data Structures

// A list double-linked list used for "updates with priority"
@interface tListEntry : NSObject
{
@public
	TICK_IMP	impMethod;
	id			target;				// not retained (retained by hashUpdateEntry)
	NSInteger	priority;
	BOOL		paused;
    BOOL		markedForDeletion;	// selector will no longer be called and entry will be removed at end of the next tick
}

@end

@implementation tListEntry


@end

@interface tHashUpdateEntry : NSObject
{
@public
	CFMutableArrayRef		list;		// Which list does it belong to ?
	tListEntry		*entry;		// entry in the list
	id				target;		// hash key (retained)
    
};

@end

@implementation tHashUpdateEntry


@end

// Hash Element used for "selectors with interval"
@interface tHashSelectorEntry : NSObject
{
@public
	CFMutableArrayRef  timers;
	id				target;		// hash key (retained)
	unsigned int	timerIndex;
	CCTimer			*currentTimer;
	BOOL			currentTimerSalvaged;
	BOOL			paused;
    
}

@end

@implementation tHashSelectorEntry

- (void)dealloc
{
    CFArrayRemoveAllValues(timers);
    [super dealloc];
}

@end

//
// CCTimer
//
#pragma mark -
#pragma mark - CCTimer

@interface CCTimer ()
{
@private
    //    dispatch_block_t _block;
    //    dispatch_source_t _timer;
}
@end

@implementation CCTimer

@synthesize interval;

-(id) init
{
	NSAssert(NO, @"CCTimer: Init not supported.");
	return nil;
}

-(id) initWithTarget: (id)t
            selector: (SEL)s
{
	return [self initWithTarget: t
                       selector: s
                       interval: 0
                         repeat: UINT_MAX
                          delay: 0];
}

-(id) initWithTarget: (id)t
            selector: (SEL)s
            interval: (NSTimeInterval) seconds
              repeat: (uint) r
               delay: (NSTimeInterval) d
{
	if( (self=[super init]) )
    {
#if COCOS2D_DEBUG
		NSMethodSignature *sig = [t methodSignatureForSelector:s];
		NSAssert(sig !=0 , @"Signature not found for selector - does it have the following form? -(void) name: (NSTimeInterval) dt");
#endif
        
		// target is not retained. It is retained in the hash structure
		target = t;
		selector = s;
		impMethod = (TICK_IMP) [t methodForSelector:s];
		elapsed = -1;
		interval = seconds;
		repeat = r;
		delay = d;
		useDelay = (delay > 0) ? YES : NO;
		repeat = r;
		runForever = (repeat == UINT_MAX) ? YES : NO;
	}
    
	return self;
}


- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | target:%@ selector:(%@)>", [self class], self, [target class], NSStringFromSelector(selector)];
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	[super dealloc];
}

-(void) update: (NSTimeInterval) dt
{
	if( elapsed == - 1)
	{
		elapsed = 0;
		nTimesExecuted = 0;
        
	}else
	{
		if (runForever && !useDelay)
		{//standard timer usage
			elapsed += dt;
			if( elapsed >= interval )
            {
				impMethod(target, selector, elapsed);
				elapsed = 0;
                
			}
            
		}else
		{//advanced usage
			elapsed += dt;
			if (useDelay)
			{
				if( elapsed >= delay )
				{
					impMethod(target, selector, elapsed);
					elapsed = elapsed - delay;
					nTimesExecuted+=1;
					useDelay = NO;
				}
			}
			else
			{
				if (elapsed >= interval)
				{
					impMethod(target, selector, elapsed);
					elapsed = 0;
					nTimesExecuted += 1;
                    
				}
			}
            
			if (nTimesExecuted > repeat)
			{	//unschedule timer
				[[VEDataSource serviceByIdentity: CCScheduleServiceID] unscheduleSelector: selector
                                                                                forTarget: target];
			}
		}
	}
}

@end

//
// CCScheduler
//
#pragma mark -
#pragma mark - CCScheduler

#define kCCScheduleArrayCount (3)

@implementation CCScheduler

static void CCScheduleRemoveHashElement(CCScheduler *self, tHashSelectorEntry *element)
{
    CFRelease(element->timers);
    
    CFDictionaryRemoveValue(self->hashForSelectors, element->target);
	[element->target release];
    
	free(element);
}

static void CCSchedulerRemoveUpdate(CCScheduler *self, tListEntry *entry)
{
	tHashUpdateEntry * element = (void *)CFDictionaryGetValue(self->hashForUpdates, entry->target);
    
	if( element )
    {
		// list entry
        [(NSMutableArray *)element->list removeObject: element->entry];
        
		// hash entry
		id target = element->target;
        CFDictionaryRemoveValue(self->hashForUpdates, target);
	}
}

+ (void)load
{
    [VEDataSource registerServiceByClass: self];
}

+ (NSString *)identity
{
    return CCScheduleServiceID;
}

@synthesize timeScale = timeScale_;

- (id) init
{
	if( (self=[super init]) )
    {
		timeScale_ = 1.0f;
        
		// used to trigger CCTimer#update
		updateSelector = @selector(update:);
		impMethod = (TICK_IMP) [CCTimer instanceMethodForSelector:updateSelector];
        
		// updates with priority
        for (NSInteger iLooper = 0; iLooper < kCCScheduleArrayCount; ++iLooper)
        {
            _updateArrays[iLooper] = CFArrayCreateMutable(CFAllocatorGetDefault(), 10, NULL);
        }
        
		hashForUpdates = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 10, NULL, NULL);
		hashForSelectors = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 10, NULL, NULL);
		// selectors with interval
		currentTarget = nil;
		currentTargetSalvaged = NO;
        updateHashLocked = NO;        
	}
    
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | timeScale = %0.2f >", [self class], self, timeScale_];
}

- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);
    
	[self unscheduleAllSelectors];
    
	[super dealloc];
}


#pragma mark CCScheduler - Custom Selectors

-(void) scheduleSelector: (SEL)selector
               forTarget: (id)target
                interval: (NSTimeInterval)interval
                  paused: (BOOL)paused
{
	[self scheduleSelector: selector
                 forTarget: target
                  interval: interval
                    paused: paused
                    repeat: UINT_MAX
                     delay: 0.0f];
}

-(void) scheduleSelector: (SEL)selector
               forTarget: (id)target
                interval: (NSTimeInterval)interval
                  paused: (BOOL)paused
                  repeat: (uint)repeat
                   delay: (NSTimeInterval)delay
{
	NSAssert( selector != nil, @"Argument selector must be non-nil");
	NSAssert( target != nil, @"Argument target must be non-nil");
    
	tHashSelectorEntry *element = (void*)CFDictionaryGetValue(hashForSelectors, target);
	if( ! element )
    {
		element = [[tHashSelectorEntry alloc] init];
		element->target = [target retain];
        CFDictionarySetValue(hashForSelectors, target , [element retain]);
        
		// Is this the 1st element ? Then set the pause level to all the selectors of this target
		element->paused = paused;
        
	} else
    {
		NSAssert( element->paused == paused, @"CCScheduler. Trying to schedule a selector with a pause value different than the target");
    }
    
	if( element->timers == nil )
    {
		element->timers = CFArrayCreateMutable(CFAllocatorGetDefault(), 10, NULL);
    }
	else
	{
		for( CFIndex i=0; i< CFArrayGetCount(element->timers); i++ )
        {
			CCTimer *timer = CFArrayGetValueAtIndex(element->timers, i);
			if( selector == timer->selector )
            {
				CCLOG(@"CCScheduler#scheduleSelector. Selector already scheduled. Updating interval from: %.4f to %.4f", timer->interval, interval);
				timer->interval = interval;
				return;
			}
		}
        
	}
    
	CCTimer *timer = [[CCTimer alloc] initWithTarget: target
                                            selector: selector
                                            interval: interval
                                              repeat: repeat
                                               delay: delay];
    
	CFArrayAppendValue(element->timers, [timer retain]);
	[timer release];
}

-(void) unscheduleSelector: (SEL)selector
                 forTarget: (id)target
{
	// explicity handle nil arguments when removing an object
	if( target==nil && selector==NULL)
		return;
    
	tHashSelectorEntry *element = (void *)CFDictionaryGetValue(hashForSelectors, target);
    
	if( element )
    {
        
		for( CFIndex i=0; i< CFArrayGetCount(element->timers); i++ )
        {
			CCTimer *timer = CFArrayGetValueAtIndex(element->timers, i);
            
            
			if( selector == timer->selector )
            {
                
				if( timer == element->currentTimer && !element->currentTimerSalvaged )
                {
					[element->currentTimer retain];
					element->currentTimerSalvaged = YES;
				}
                
				[(NSMutableArray *)element->timers removeObjectAtIndex: i];
                
				// update timerIndex in case we are in tick:, looping over the actions
				if( element->timerIndex >= i )
					element->timerIndex--;
                
				if( CFArrayGetCount(element->timers) == 0 )
                {
					if( currentTarget == element )
						currentTargetSalvaged = YES;
					else
                    {
                        CCScheduleRemoveHashElement(self, element);
                    }
				}
				return;
			}
		}
	}
    
}

#pragma mark CCScheduler - Update Specific

-(void) priorityIn: (CFMutableArrayRef)list
            target: (id)target
          priority: (NSInteger)priority
            paused: (BOOL)paused
{
	tListEntry *listElement =  [[tListEntry alloc] init];
    
	listElement->target = target;
	listElement->priority = priority;
	listElement->paused = paused;
	listElement->impMethod = (TICK_IMP) [target methodForSelector:updateSelector];
    
    listElement->markedForDeletion = NO;
    
    
    __block BOOL added = NO;
    
    NSArray *tmpList = [NSArray arrayWithArray: (NSArray *)list];
    
    [tmpList enumerateObjectsWithOptions: NSEnumerationConcurrent
                              usingBlock: (^(tListEntry *obj, NSUInteger idx, BOOL *stop)
                                          {
                                              if( priority < obj->priority )
                                              {
                                                  CFArrayInsertValueAtIndex(list, idx, [listElement retain]);
                                                  added = YES;
                                                  *stop = YES;
                                              }
                                          })];
    
    // Not added? priority has the higher value. Append it.
    if( !added )
    {
        CFArrayAppendValue(list, [listElement retain]);
    }
    
    [listElement release];
    
	// update hash entry for quicker access
	tHashUpdateEntry *hashElement = [[tHashUpdateEntry alloc] init];
    
	hashElement->target = [target retain];
	hashElement->list = list;
	hashElement->entry = listElement;
    CFDictionarySetValue(hashForUpdates, target, hashElement);
}

-(void) appendIn: (CFMutableArrayRef)list
          target: (id)target
          paused: (BOOL)paused
{
	tListEntry *listElement = [[tListEntry alloc] init];
    
	listElement->target = target;
	listElement->paused = paused;
    listElement->markedForDeletion = NO;
	listElement->impMethod = (TICK_IMP) [target methodForSelector:updateSelector];
    
    CFArrayAppendValue(list, [listElement retain]);
    
    [listElement release];
    
	// update hash entry for quicker access
	tHashUpdateEntry *hashElement = [[tHashUpdateEntry alloc] init];
	hashElement->target = [target retain];
	hashElement->list = list;
	hashElement->entry = listElement;
    CFDictionarySetValue(hashForUpdates, target, [hashElement retain]);
    
    [hashElement release];
}

-(void) scheduleUpdateForTarget: (id)target
                       priority: (CCSchedulerPriority)priority
                         paused: (BOOL)paused
{
	tHashUpdateEntry * hashElement = (void *)CFDictionaryGetValue(hashForUpdates, target);
    
    if(hashElement)
    {
#if COCOS2D_DEBUG >= 1
        NSAssert( hashElement->entry->markedForDeletion, @"CCScheduler: You can't re-schedule an 'update' selector'. Unschedule it first");
#endif
        hashElement->entry->markedForDeletion = NO;
        return;
    }
    
	// most of the updates are going to be 0, that's way there
	// is an special list for updates with priority 0
    if (priority == CCSchedulerPriorityZero)
    {
        [self appendIn: _updateArrays[CCSchedulerPriorityZero]
                target: target
                paused: paused];
    }else
    {
        [self priorityIn: _updateArrays[priority]
                  target: target
                priority: priority
                  paused: paused];
    }
}

-(void) unscheduleUpdateForTarget:(id)target
{    
	tHashUpdateEntry * element = (void *)CFDictionaryGetValue(hashForUpdates, target);
    
	if( element )
    {
        if(updateHashLocked)
        {
            element->entry->markedForDeletion = YES;
            
        }else
        {
            CCSchedulerRemoveUpdate(self, element->entry);
        }
	}
}

#pragma mark CCScheduler - Common for Update selector & Custom Selectors

-(void) unscheduleAllSelectors
{
    [self unscheduleAllSelectorsWithMinPriority:kCCPrioritySystem];
}

-(void) unscheduleAllSelectorsWithMinPriority: (CCSchedulerPriority)minPriority
{
	// Custom Selectors
    
    [(NSDictionary *)hashForSelectors enumerateKeysAndObjectsWithOptions: NSEnumerationConcurrent
                                                              usingBlock:(^(id key, tHashSelectorEntry *element, BOOL *stop)
                                                                          {
                                                                              [self unscheduleAllSelectorsForTarget: element->target];
                                                                          })];
    
    
    // Updates selectors
    
    
    [(NSArray *)_updateArrays[minPriority] enumerateObjectsWithOptions: NSEnumerationConcurrent
                                                            usingBlock: (^(tListEntry *entry, NSUInteger idx, BOOL *stop)
                                                                        {
                                                                            if(entry->priority >= minPriority)
                                                                            {
                                                                                [self unscheduleUpdateForTarget:entry->target];
                                                                            }
                                                                        })];
}

-(void) unscheduleAllSelectorsForTarget:(id)target
{    
    // Custom Selectors
    tHashSelectorEntry *element = (void *)CFDictionaryGetValue(hashForSelectors, target);
    
    if( element )
    {
        if( CFArrayContainsValue(element->timers, CFRangeMake(0, CFArrayGetCount(element->timers)), element->currentTimer)
           && !element->currentTimerSalvaged )
        {
            [element->currentTimer retain];
            element->currentTimerSalvaged = YES;
        }
        
        [(NSMutableArray *)element->timers removeAllObjects];
        
        if( currentTarget == element )
            currentTargetSalvaged = YES;
        else
        {
            CCScheduleRemoveHashElement(self, element);
        }
    }
    
    // Update Selector
    [self unscheduleUpdateForTarget:target];
}

-(void) resumeTarget:(id)target
{
    NSAssert( target != nil, @"target must be non nil" );
    
    // Custom Selectors
    tHashSelectorEntry *element = (void *)CFDictionaryGetValue(hashForSelectors, target);
    
    if( element )
    {
        element->paused = NO;
    }
    
    // Update selector
    tHashUpdateEntry * elementUpdate = (void *)CFDictionaryGetValue(hashForUpdates, target);
    
    if( elementUpdate )
    {
        NSAssert( elementUpdate->entry != NULL, @"resumeTarget: unknown error");
        elementUpdate->entry->paused = NO;
    }
}

-(void) pauseTarget:(id)target
{
    NSAssert( target != nil, @"target must be non nil" );
    
    // Custom selectors
    tHashSelectorEntry *element = (void *)CFDictionaryGetValue(hashForSelectors, target);
    if( element )
    {
        element->paused = YES;
    }
    
    // Update selector
    tHashUpdateEntry * elementUpdate = (void *)CFDictionaryGetValue(hashForUpdates, target);
    
    if( elementUpdate )
    {
        NSAssert( elementUpdate->entry != NULL, @"pauseTarget: unknown error");
        elementUpdate->entry->paused = YES;
    }
    
}

-(BOOL) isTargetPaused:(id)target
{
    NSAssert( target != nil, @"target must be non nil" );
    
    // Custom selectors
    tHashSelectorEntry *element = (void *)CFDictionaryGetValue(hashForSelectors, target);
    if( element )
    {
        return element->paused;
    }
    return NO;  // should never get here
    
}

-(NSSet*) pauseAllTargets
{
    return [self pauseAllTargetsWithMinPriority:kCCPrioritySystem];
}

-(NSSet*) pauseAllTargetsWithMinPriority: (CCSchedulerPriority)minPriority
{
    NSMutableSet* idsWithSelectors = [NSMutableSet setWithCapacity:50];
    
    // Custom Selectors
    [(NSDictionary *)hashForSelectors enumerateKeysAndObjectsWithOptions: NSEnumerationConcurrent
                                                              usingBlock: (^(id key, tHashSelectorEntry *element, BOOL *stop)
                                                                          {
                                                                              element->paused = YES;
                                                                              [idsWithSelectors addObject:element->target];
                                                                          })];
    
    // Updates selectors
    
    
    [(NSArray *)_updateArrays[minPriority] enumerateObjectsWithOptions: NSEnumerationConcurrent
                                                            usingBlock: (^(tListEntry *entry, NSUInteger idx, BOOL *stop)
                                                                        {
                                                                            if(entry->priority >= minPriority)
                                                                            {
                                                                                entry->paused = YES;
                                                                                [idsWithSelectors addObject:entry->target];
                                                                            }
                                                                        })];
    
    return idsWithSelectors;
}

#pragma mark CCScheduler - Main Loop

-(void) update: (NSTimeInterval) dt
{
    updateHashLocked = YES;
    
    dt *= timeScale_;
    
    // updates with priority < 0
    for (NSInteger iLooper = 0; iLooper < kCCScheduleArrayCount; ++iLooper)
    {
        NSArray *array = [NSArray arrayWithArray: (NSArray *)_updateArrays[iLooper]];
        
        for (tListEntry *entry in array)
        {
            if (entry->markedForDeletion)
            {
                CCSchedulerRemoveUpdate(self, entry);
                
            }else if( ! entry->paused )
            {
                entry->impMethod( entry->target, updateSelector, dt );
            }
        }
    }
    
    // Iterate all over the  custome selectors
    [(NSDictionary *)hashForSelectors enumerateKeysAndObjectsWithOptions: NSEnumerationConcurrent
                                                              usingBlock: (^(id key, tHashSelectorEntry *elt, BOOL *stop)
                                                                          {
                                                                              
                                                                              currentTarget = elt;
                                                                              currentTargetSalvaged = NO;
                                                                              
                                                                              if( ! currentTarget->paused )
                                                                              {
                                                                                  
                                                                                  // The 'timers' ccArray may change while inside this loop.
                                                                                  for( elt->timerIndex = 0; elt->timerIndex < CFArrayGetCount(elt->timers); elt->timerIndex++)
                                                                                  {
                                                                                      elt->currentTimer = CFArrayGetValueAtIndex(elt->timers, elt->timerIndex);
                                                                                      elt->currentTimerSalvaged = NO;
                                                                                      
                                                                                      impMethod( elt->currentTimer, updateSelector, dt);
                                                                                      
                                                                                      if( elt->currentTimerSalvaged )
                                                                                      {
                                                                                          // The currentTimer told the remove itself. To prevent the timer from
                                                                                          // accidentally deallocating itself before finishing its step, we retained
                                                                                          // it. Now that step is done, it is safe to release it.
                                                                                          [elt->currentTimer release];
                                                                                      }
                                                                                      
                                                                                      elt->currentTimer = nil;
                                                                                  }
                                                                              }
                                                                              
                                                                              // only delete currentTarget if no actions were scheduled during the cycle (issue #481)
                                                                              if( currentTargetSalvaged && CFArrayGetCount(currentTarget->timers) == 0 )
                                                                              {
                                                                                  CCScheduleRemoveHashElement(self, currentTarget);
                                                                                  
                                                                                  currentTarget = nil;
                                                                              }
                                                                          })];
    
    updateHashLocked = NO;
    currentTarget = nil;
}

@end

const char * CCScheduleTimerQueue = "com.veritas.cocos2d.queue.timer";

NSString * const CCScheduleServiceID = @"com.veritas.cocos2d.service.schedule";

