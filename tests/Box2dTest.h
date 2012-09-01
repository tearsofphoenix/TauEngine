//
// cocos2d
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "BaseApplicationDelegate.h"

@interface AppController : BaseApplicationDelegate
@end

@interface MainLayer : CCLayer
{
    CCNode *_parentNode;
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
}
@end

@interface PhysicsSprite : CCSprite
{
	b2Body *body_;	// strong ref
}

-(void) setPhysicsBody:(b2Body*)body;

@end

@interface UIWebView (Private)


- (Class)_printFormatterClass;

- (BOOL)isElementAccessibilityExposedToInterfaceBuilder;

- (void)_populateArchivedSubviews: (id)value;


- (CGSize)sizeThatFits: (CGSize)size;

- (BOOL)canPerformAction: (SEL)selector
              withSender: (id)sender;

- (CGImageRef)newSnapshotWithRect: (CGRect)rect;

- (CGImageRef)createSnapshotWithRect: (CGRect)rect;

- (BOOL)_appliesExclusiveTouchToSubviewTree;



- (void)_define: (id)value;

- (void)modalView: (UIView *)view
didDismissWithButtonIndex: (NSInteger)index;

- (UIScrollView *)scrollView;


- (void)loadData:MIMEType:textEncodingName:baseURL:;

- (void)view: (UIView *)view
 didSetFrame: (CGRect)frame
    oldFrame: (CGRect)oldFrame;

- (void)webViewMainFrameDidFinishLoad: (id)view;

- (void)webViewMainFrameDidCommitLoad: (id)view;

- (void)saveStateToHistoryItem: (id)value
                    forWebView: (id)view;

- (void)restoreStateFromHistoryItem: (id)item
                         forWebView: (id)view;

- (void)setMediaPlaybackAllowsAirPlay: (BOOL)flag;


- (id)_documentView;

- (BOOL)scalesPageToFit;

- (id)_browserView;

- (void)_setScalesPageToFitViewportSettings;

- (void)_setRichTextReaderViewportSettings;

- (void)_updateCheckeredPattern;

- (void)_setDrawInWebThread: (BOOL)flag;

- (void)_updateOpaqueAndBackgroundColor;

- (void)_updateViewSettings;

- (void)_didRotate: (id)value;

- (void)setScalesPageToFit: (BOOL)flag;

- (void)_webViewCommonInit: (id)view;

- (NSString *)stringByEvaluatingJavaScriptFromString: (NSString *)str;

- (void)setAllowsInlineMediaPlayback: (BOOL)flag;

- (BOOL)allowsInlineMediaPlayback;

- (void)setMediaPlaybackRequiresUserAction: (BOOL)flag;

- (BOOL)mediaPlaybackRequiresUserAction;

- (void)_rescaleDocument;

- (void)_frameOrBoundsChanged;

- (void)_updateScrollerViewForInputView: (id)view;

- (void)_didCompleteScrolling;

- (void)_reportError: (NSError *)error;

- (void)_updateRequest;

- (void)saveGeolocation: (id)value;

- (void)_beginRotation;

- (void)_finishRotation;

- (void)webViewMainFrameDidFirstVisuallyNonEmptyLayoutInFrame: (id)view;

- (void)scrollViewWasRemoved: (id)scrollView;

- (id)_pdfViewHandler;

- (void)_setOverridesOrientationChangeEventHandling: (BOOL)flag;

- (void)_setDrawsCheckeredPattern: (BOOL)flag;

- (void)_setWebSelectionEnabled: (BOOL)flag;


- (void)decidePolicyForGeolocationRequestFromOrigin: (id)origin
                                              frame: (id)frame
                                           listener: (id)listener;

- (void)webView: (id)view exceededApplicationCacheOriginQuotaForSecurityOrigin: (id)origin totalSpaceNeeded: (NSUInteger)speed;


- (void)webView: (id)view frame: (id)frame exceededDatabaseQuotaForSecurityOrigin: (id)origin database: (id)database;

- (void)webView: (id)webView printFrameView: (id)view;

- (void)webView: (id)webView runJavaScriptTextInputPanelWithPrompt: (id)prompt defaultText: (id)text initiatedByFrame: (id)frame;

- (void)webView: (id)webView runJavaScriptConfirmPanelWithMessage: (id)message initiatedByFrame: (id)frame;

- (void)webView: (id)webView runJavaScriptAlertPanelWithMessage: (id)message initiatedByFrame: (id)frame;

- (void)request;

- (void)webView: (id)webView didStartProvisionalLoadForFrame: (id)frame;

- (void)webView: (id)webView decidePolicyForNewWindowAction: (id)action request: (id)request newFrameName: (id)frame decisionListener: (id)listerner;

- (void)webView: (id)view decidePolicyForNavigationAction: (id)action request: (id)request frame: (id)frame decisionListener: (id)listener;

- (void)webView: (id)view decidePolicyForMIMEType: (id)type request: (id)request frame: (id)frame decisionListener: (id)listener;

- (id)webView: (id)view connectionPropertiesForResource: (id)resource dataSource: (id)dataSource;

- (BOOL)webView: (id)view resource: (id)resource canAuthenticateAgainstProtectionSpace: (id)space forDataSource: (id)dataSource;

- (void)webView: (id)view resource: (id)resource didCancelAuthenticationChallenge: (id)challenge fromDataSource: (id)dataSource;

- (void)webView: (id)view didClearWindowObject: (id)obj forFrame: (id)frame;

- (void)webView: (id)view unableToImplementPolicyWithError: (NSError *)error frame: (id)frame;

- (void)webView: (id)view didFinishLoadForFrame: (id)frame;

- (void)webView: (id)view didFailLoadWithError: (NSError *)error forFrame: (id)frame;

- (void)webView: (id)view didFailProvisionalLoadWithError: (NSError *)error forFrame: (id)frame;

- (void)webView: (id)view didCommitLoadForFrame: (id)frame;

- (void)webView: (id)view didChangeLocationWithinPageForFrame: (id)frame;

- (void)webView: (id)view resource: (id)resource didFailLoadingWithError: (NSError *)error fromDataSource: (id)dataSource;

- (void)webView: (id)view resource: (id)resource willSendRequest: (NSURLRequest *)request redirectResponse: (NSURLResponse *)response fromDataSource: (id)dataSource;

- (void)webView: (id)view identifierForInitialRequest: (NSURLRequest *)request
 fromDataSource: (id)dataSource;

- (id)_scrollView;

- (BOOL)mediaPlaybackAllowsAirPlay;

- (void)stopLoading;

- (void)webViewClose: (id)value;

- (void)webView: (id)view didReceiveTitle: (id)title forFrame: (id)frame;

- (void)webView: (id)view didReceiveServerRedirectForProvisionalLoadForFrame: (id)frame;

- (void)webView: (id)view didFirstLayoutInFrame: (id)frame;

- (void)webView: (id)view resource: (id)resource didFinishLoadingFromDataSource: (id)dataSource;

- (void)webView: (id)view resource: (id)resource didReceiveAuthenticationChallenge: (id)challenge fromDataSource: (id)dataSource;

- (BOOL)isLoading;

@end
