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

_ (void)_updateOpaqueAndBackgroundColor;

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

- (void)webView:decidePolicyForNavigationAction:request:frame:decisionListener: encoding:v28@0:4@8@12@16@20@24
- (void)webView:decidePolicyForMIMEType:request:frame:decisionListener: encoding:v28@0:4@8@12@16@20@24
- (void)webView:connectionPropertiesForResource:dataSource: encoding:@20@0:4@8@12@16
- (void)webView:resource:canAuthenticateAgainstProtectionSpace:forDataSource: encoding:c24@0:4@8@12@16@20
- (void)webView:resource:didCancelAuthenticationChallenge:fromDataSource: encoding:v24@0:4@8@12@16@20

- (void)webView:didClearWindowObject:forFrame: encoding:v20@0:4@8@12@16
- (void)webView:unableToImplementPolicyWithError:frame: encoding:v20@0:4@8@12@16
- (void)webView:didFinishLoadForFrame: encoding:v16@0:4@8@12
- (void)webView:didFailLoadWithError:forFrame: encoding:v20@0:4@8@12@16
name:webView:didFailProvisionalLoadWithError:forFrame: encoding:v20@0:4@8@12@16
name:webView:didCommitLoadForFrame: encoding:v16@0:4@8@12
name:webView:didChangeLocationWithinPageForFrame: encoding:v16@0:4@8@12
name:webView:resource:didFailLoadingWithError:fromDataSource: encoding:v24@0:4@8@12@16@20
name:webView:resource:willSendRequest:redirectResponse:fromDataSource: encoding:@28@0:4@8@12@16@20@24
name:webView:identifierForInitialRequest:fromDataSource: encoding:@20@0:4@8@12@16
- (id)_scrollView;

name:mediaPlaybackAllowsAirPlay encoding:c8@0:4

    - (void)stopLoading;

    - (void)webViewClose: (id)value;

- (void)webView:didReceiveTitle:forFrame: encoding:v20@0:4@8@12@16
name:webView:didReceiveServerRedirectForProvisionalLoadForFrame: encoding:v16@0:4@8@12
name:webView:didFirstLayoutInFrame: encoding:v16@0:4@8@12
name:webView:resource:didFinishLoadingFromDataSource: encoding:v20@0:4@8@12@16
name:webView:resource:didReceiveAuthenticationChallenge:fromDataSource: encoding:v24@0:4@8@12@16@20

    - (BOOL)isLoading;
