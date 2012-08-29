/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
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
 *
 */


#import "CCActionManager.h"
#import "CCScheduler.h"
#import "ccMacros.h"

@implementation tHashElement

@end

@interface CCActionManager (Private)
-(void) removeActionAtIndex:(NSUInteger)index hashElement:(tHashElement*)element;
-(void) deleteHashElement:(tHashElement*)element;
-(void) actionAllocWithHashElement:(tHashElement*)element;
@end


@implementation CCActionManager

- (id)init
{
	if ((self=[super init]) )
    {
		targets = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 10, NULL, NULL);
	}
    
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p>", [self class], self];
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);
    
	[self removeAllActions];
    
	[super dealloc];
}

#pragma mark ActionManager - Private

-(void) deleteHashElement:(tHashElement*)element
{
	[(NSMutableArray *)element->actions release];
    
    CFDictionaryRemoveValue(targets, element);
    //	CCLOG(@"cocos2d: ---- buckets: %d/%d - %@", targets->entries, targets->size, element->target);
	[element->target release];
	
    free(element);
}

-(void) actionAllocWithHashElement:(tHashElement*)element
{
	// 4 actions per Node by default
	if( element->actions == nil )
    {
		element->actions = CFArrayCreateMutable(CFAllocatorGetDefault(), 4, NULL);
    }
}

-(void) removeActionAtIndex:(NSUInteger)index hashElement:(tHashElement*)element
{
	id action = CFArrayGetValueAtIndex(element->actions, index);
    
	if( action == element->currentAction && !element->currentActionSalvaged )
    {
		[element->currentAction retain];
		element->currentActionSalvaged = YES;
	}
    
	[(NSMutableArray *)element->actions removeObjectAtIndex: index];
    
	// update actionIndex in case we are in tick:, looping over the actions
	if( element->actionIndex >= index )
		element->actionIndex--;
    
	if( CFArrayGetCount(element->actions) == 0 )
    {
		if( currentTarget == element )
			currentTargetSalvaged = YES;
		else
			[self deleteHashElement: element];
	}
}

#pragma mark ActionManager - Pause / Resume

-(void) pauseTarget:(id)target
{
	tHashElement *element = (void*)CFDictionaryGetValue(targets, targets);
    
	if( element )
    {
		element->paused = YES;
    }
}

-(void) resumeTarget:(id)target
{
	tHashElement *element = (void*)CFDictionaryGetValue(targets, targets);
    
	if( element )
    {
		element->paused = NO;
    }
}

-(NSSet *) pauseAllRunningActions
{
    NSMutableSet* idsWithActions = [NSMutableSet setWithCapacity:50];
    
    [(NSDictionary *)targets enumerateKeysAndObjectsUsingBlock: (^(id key, tHashElement *element, BOOL *stop)
                                                                 {
                                                                     
                                                                     if( !element->paused )
                                                                     {
                                                                         element->paused = YES;
                                                                         [idsWithActions addObject: element->target];
                                                                     }
                                                                     
                                                                 })];
    
    return idsWithActions;
}

-(void) resumeTargets:(NSSet *)targetsToResume
{
    for(id target in targetsToResume) {
        [self resumeTarget:target];
    }
}

#pragma mark ActionManager - run

-(void) addAction:(CCAction*)action target:(id)target paused:(BOOL)paused
{
	NSAssert( action != nil, @"Argument action must be non-nil");
	NSAssert( target != nil, @"Argument target must be non-nil");
    
	tHashElement *element = (void *)CFDictionaryGetValue(targets, targets);
    
	if( ! element )
    {
		element = [[tHashElement alloc] init];
		element->paused = paused;
		element->target = [target retain];
        CFDictionarySetValue(targets, targets, element);
        
        //		CCLOG(@"cocos2d: ---- buckets: %d/%d - %@", targets->entries, targets->size, element->target);
        
	}
    
	[self actionAllocWithHashElement:element];
    
	NSAssert( ![(NSArray*)element->actions containsObject: action], @"runAction: Action already running");
	CFArrayAppendValue(element->actions, [action retain]);
    
	[action startWithTarget:target];
}

#pragma mark ActionManager - remove

-(void) removeAllActions
{
    [(NSDictionary *)targets enumerateKeysAndObjectsUsingBlock: (^(id key, tHashElement *element, BOOL *stop)
                                                                 {
                                                                     [self removeAllActionsFromTarget:element->target];
                                                                     
                                                                 })];
}
-(void) removeAllActionsFromTarget:(id)target
{
    // explicit nil handling
    if( target == nil )
        return;
    
    tHashElement *element = (void *)CFDictionaryGetValue(targets, target);
    
    if( element )
    {
        if( CFArrayContainsValue(element->actions, CFRangeMake(0, CFArrayGetCount(element->actions)), element->currentAction)
           && !element->currentActionSalvaged )
        {
            [element->currentAction retain];
            element->currentActionSalvaged = YES;
        }
        
        [(NSMutableArray *)element->actions removeAllObjects];
        
        if( currentTarget == element )
            currentTargetSalvaged = YES;
        else
            [self deleteHashElement:element];
    }
}

-(void) removeAction: (CCAction*) action
{
    // explicit nil handling
    if (action == nil)
        return;
    
    id target = [action originalTarget];
    tHashElement *element = (void *)CFDictionaryGetValue(targets, target);
    
    if( element )
    {
        NSUInteger i = CFArrayGetFirstIndexOfValue(element->actions, CFRangeMake(0, CFArrayGetCount(element->actions)), action);
        if( i != NSNotFound )
            [self removeActionAtIndex:i hashElement:element];
    }
    
}

#pragma mark ActionManager - get

-(NSUInteger) numberOfRunningActionsInTarget:(id) target
{
    tHashElement *element = (void *)CFDictionaryGetValue(targets, target);
    
    if( element )
    {
        return element->actions ? CFArrayGetCount(element->actions) : 0;
    }
    
    return 0;
}

#pragma mark ActionManager - main loop

-(void) update: (NSTimeInterval) dt
{
    [(NSDictionary *)targets enumerateKeysAndObjectsUsingBlock: (^(id key, tHashElement *elt, BOOL *stop)
                                                                 {
                                                                     currentTarget = elt;
                                                                     currentTargetSalvaged = NO;
                                                                     
                                                                     if( ! currentTarget->paused )
                                                                     {
                                                                         
                                                                         // The 'actions' ccArray may change while inside this loop.
                                                                         for( currentTarget->actionIndex = 0; currentTarget->actionIndex < CFArrayGetCount(currentTarget->actions); currentTarget->actionIndex++)
                                                                         {
                                                                             currentTarget->currentAction = CFArrayGetValueAtIndex(currentTarget->actions, currentTarget->actionIndex);
                                                                             currentTarget->currentActionSalvaged = NO;
                                                                             
                                                                             [currentTarget->currentAction step: dt];
                                                                             
                                                                             if( currentTarget->currentActionSalvaged )
                                                                             {
                                                                                 // The currentAction told the node to remove it. To prevent the action from
                                                                                 // accidentally deallocating itself before finishing its step, we retained
                                                                                 // it. Now that step is done, it's safe to release it.
                                                                                 [currentTarget->currentAction release];
                                                                                 
                                                                             } else if( [currentTarget->currentAction isDone] )
                                                                             {
                                                                                 [currentTarget->currentAction stop];
                                                                                 
                                                                                 CCAction *a = currentTarget->currentAction;
                                                                                 // Make currentAction nil to prevent removeAction from salvaging it.
                                                                                 currentTarget->currentAction = nil;
                                                                                 [self removeAction:a];
                                                                             }
                                                                             
                                                                             currentTarget->currentAction = nil;
                                                                         }
                                                                     }
                                                                     
                                                                     
                                                                     // only delete currentTarget if no actions were scheduled during the cycle (issue #481)
                                                                     if( currentTargetSalvaged && CFArrayGetCount(currentTarget->actions) == 0 )
                                                                     {
                                                                         [self deleteHashElement:currentTarget];
                                                                     }
                                                                 })];
     
     // issue #635
     currentTarget = nil;
     }
     @end
