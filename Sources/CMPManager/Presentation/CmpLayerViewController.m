//
//  CmpLayerViewController.m
//  GDPR
//

#import "CmpLayerViewController.h"
#import "CMPActivityIndicatorView.h"
#import "CmpUtils.h"
#import "CmpConsentDto.h"
#import "Logger.h"
#import <WebKit/WebKit.h>

NSString *const ConsentStringQueryParam = @"code64";
NSString *const ConsentStringPrefix = @"consent://";

@interface CmpLayerViewController ()<UIGestureRecognizerDelegate, WKNavigationDelegate, WKScriptMessageHandler>
@property(nonatomic, retain) WKWebView *webView;
@property(nonatomic, retain) CMPActivityIndicatorView *activityIndicatorView;
@property(nonatomic, retain) CMPServerResponse *cmpServerResponse;
@end

@implementation CmpLayerViewController
static NSString *TAG = @"[Cmp]LayerVC";
static bool error = FALSE;

- (void)viewDidLoad {
  _timedOut = NO;
  [super viewDidLoad];
  [Logger debug:TAG :@"view did load initiated"];
  if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
	self.navigationController.interactivePopGestureRecognizer.delegate = self;
  }

  [self setModalPresentationStyle:UIModalPresentationFullScreen];

  if (@available(iOS 13.0, *)) {
	[self setModalInPresentation:YES];
  }
  if (!error) {
	[self initActivityIndicator];
  }

  dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 5);
  _timedOut = YES;
  dispatch_after(delay, dispatch_get_main_queue(), ^(void){
      if (self->_timedOut) {
      // network Event Listener
      if ([self networkErrorListener]) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
          self->_networkErrorListener(@"The CMP Layer has problems to open View: Please try again later");
        });
      }
	  [Logger error:TAG :@"The CMP Layer has problems to open View: Please try again later"];
      [super dismissViewControllerAnimated:YES completion:nil];
    }

  });
  self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
	self.navigationController.interactivePopGestureRecognizer.delegate = nil;
  }
  error = NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  return NO;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  if (error) {
	[super dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  [_activityIndicatorView removeFromSuperview];
  [Logger error:TAG :@"Failed to load consentScreen"];
  if (_networkErrorListener) {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
	  self->_networkErrorListener(@"Failed to load URL");
	});
  }
}

- (void)initWebView {
  [Logger debug:TAG :@"Init Webview"];
  /// consent Script to get Consent without navigating to consent://
  // TODO add second level param of sdk function
  NSString *consentScriptString =
	  @"var cmpToSDK_sendStatus = function(consent,jsonObject) { "
	  "jsonObject.cmpApiKey = consent;"
	  "window.webkit.messageHandlers.consent.postMessage(jsonObject); };"
	  "var cmpToSDK_showConsentLayer = function(open) { window.webkit.messageHandlers.open.postMessage(open);};"
	  "window.onerror = function(error) { window.webkit.messageHandlers.error.postMessage(error); };";
  WKUserScript *consentScript =
	  [[WKUserScript alloc] initWithSource:consentScriptString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];

  WKUserContentController *contentController = [[WKUserContentController alloc] init];
  [contentController addUserScript:consentScript];
  [contentController addScriptMessageHandler:self name:@"consent"];
  [contentController addScriptMessageHandler:self name:@"open"];
  [contentController addScriptMessageHandler:self name:@"error"];

  if ([CmpUtils isNetworkAvailable] && !error) {
	WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
	[configuration setUserContentController:contentController];
	_webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
	_webView.navigationDelegate = self;
	_webView.scrollView.scrollEnabled = YES;
	_webView.accessibilityViewIsModal = FALSE;
	NSURLRequest *request = [self getCmpLayerRequest:10];
	_isMessageSent = NO;
	_isOpen = NO;
	_timedOut = NO;
	if (request) {
	  [_webView loadRequest:request];
	}
  } else {
	if (_networkErrorListener) {
	  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	  dispatch_async(queue, ^{
		self->_networkErrorListener(@"The Network is not reachable to show the WebView");
	  });

	}
	[_activityIndicatorView removeFromSuperview];
	error = true;
	NSLog(@"Network is not reachable");
  }

}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
  [Logger debug:TAG :[NSString stringWithFormat:@"js message call: %@", message.name]];
  if ([message.name isEqualToString:@"open"]) {
	if ([self.delegate respondsToSelector:@selector(didFinishedLoading:)] && !_timedOut) {
	  [self.delegate didFinishedLoading:self];
	}
  }
  if ([message.name isEqualToString:@"consent"]) {
	[self dismissViewControllerAnimated:YES completion:nil];
	NSDictionary * data = message.body;
	CmpConsentDto *dto = [CmpConsentDto fromJSON:data];
	if ([self.delegate respondsToSelector:@selector(didReceivedConsentDto::)]) {
	  [self.delegate didReceivedConsentDto:self :dto];
	}
  }
  if([message.name isEqualToString:@"error"]) {
	[Logger debug:TAG :[NSString stringWithFormat:@"error: %@", [message.body description]]];
  }
  _timedOut = NO;
}

- (void)layoutWebView {
  _webView.translatesAutoresizingMaskIntoConstraints = NO;

  if (@available(iOS 11, *)) {
	UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
	[NSLayoutConstraint activateConstraints:@[
		[self.webView.topAnchor constraintEqualToAnchor:guide.topAnchor],
		[self.webView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
		[self.webView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
		[self.webView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor]
	]];
  } else {
	id topAnchor = self.view.safeAreaLayoutGuide.topAnchor;
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_webView, topAnchor);

	[self.view addConstraints:[NSLayoutConstraint
		constraintsWithVisualFormat:@"V:[topGuide]-[_webView]-0-|"
							options:NSLayoutFormatDirectionLeadingToTrailing
							metrics:nil
							  views:viewsDictionary]];

	[self.view addConstraints:[NSLayoutConstraint
		constraintsWithVisualFormat:@"H:|-0-[_webView]-0-|"
							options:NSLayoutFormatDirectionLeadingToTrailing
							metrics:nil
							  views:viewsDictionary]];
  }
}

- (void)initActivityIndicator {
  _activityIndicatorView = [[CMPActivityIndicatorView alloc] initWithFrame:self.view.frame];
  _activityIndicatorView.userInteractionEnabled = NO;
  [self.view addSubview:_activityIndicatorView];
  [_activityIndicatorView startAnimating];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(
	WKNavigationActionPolicy))decisionHandler {

  NSURLRequest *request = navigationAction.request;
  [Logger debug:TAG :[NSString stringWithFormat:@"Navigation Request: %@", request.URL.absoluteURL.absoluteString]];

  if([request.URL.absoluteString.lowercaseString hasPrefix:@"consent://"]) {
	if ([self.delegate respondsToSelector:@selector(cancelConsentLayer:)]) {
	  [self.delegate cancelConsentLayer:self];
	}
	decisionHandler(WKNavigationActionPolicyAllow);
  }

  if (request.URL.absoluteString.lowercaseString.length > 0
	  && ![CmpUtils validateCmpLayerUrl:request.URL]
	  && ![request.URL.absoluteString containsString:@"about:blank"]) {
	[[UIApplication sharedApplication] openURL:request.URL options:@{} completionHandler:nil];
	decisionHandler(WKNavigationActionPolicyCancel);
  } else {
	decisionHandler(WKNavigationActionPolicyAllow);
  }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  [self.view addSubview:_webView];
  [self layoutWebView];
  if (_networkErrorListener) {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
	  self->_networkErrorListener(@"Timeout has been reached");
	});
  }
}

- (NSURLRequest *)getCmpLayerRequest:(long)timeout {
  NSString *consentString = [CmpConsentService getCmpApiKey];
  NSURL *url = [CmpUtils getCmpLayerUrl:consentString :_justOpenView];

  if (!url) {
	[Logger error:TAG :@"Error during creating consent layer request"];
	return nil;
  }
  [Logger debug:TAG :[NSString stringWithFormat:@"generate cmp Layer request with url: %@", url.absoluteString]];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  request.timeoutInterval = timeout;
  return request;
}

- (void)reset {
  _timedOut = NO;
  _isMessageSent = NO;
  _isOpen = NO;
}

@end
