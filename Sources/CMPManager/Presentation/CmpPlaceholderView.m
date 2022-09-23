//
//  CmpPlaceholderView.m
//  consentmanager
//
//  Created by Skander Ben Abdelmalak on 17.11.21.
//
#import "CmpPlaceholderView.h"
#import "CMPSettings.h"
#import "Logger.h"
NSString *const CONSENT_PREFIX = @"consent://";
@interface CmpPlaceholderView ()<WKNavigationDelegate>

@end

@implementation CmpPlaceholderView

static NSString *TAG = @"[Cmp]PlaceholderView";

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (instancetype)initWithPlaceholderParams:(CmpPlaceholderParams *)placeholderParams {
  self = [super init];
  self.backgroundColor = UIColor.grayColor;
  if (self) {
    self.placeholderParams = placeholderParams;
  }
  return self;
}

- (void)createWebView {
  WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
  _webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
  _webView.navigationDelegate = self;
  _webView.scrollView.scrollEnabled = YES;
  NSURL *url = [_placeholderParams getRequestURL:[CMPSettings consentString]];
  [Logger debug:TAG :[NSString stringWithFormat:@"Url request: %@", [url absoluteString]]];
  [_webView loadRequest:[[NSURLRequest alloc] initWithURL:url]];
}

+ (instancetype)viewWithPlaceholderParams:(CmpPlaceholderParams *)placeholderParams {
  return [[self alloc] initWithPlaceholderParams:placeholderParams];
}

- (CmpPlaceholderView *)createPreview:(CGRect)frame {
  self.frame = frame;
  [self createWebView];
  [self addSubview:_webView];
  [self bringSubviewToFront:_webView];
  return self;
}


#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(
	WKNavigationActionPolicy))decisionHandler {
  NSURLRequest *request = navigationAction.request;
  [Logger debug:TAG :[NSString stringWithFormat:@"Placeholder Navigation Request: %@", request.URL.absoluteURL.absoluteString]];
  if(!request) {
	decisionHandler(WKNavigationActionPolicyCancel);
	return;
  }

  //TODO old API
  // TODO passed to ConsentToolViewController - Instead delegate to dedicated placeholder controller ?
  if ([request.URL.absoluteString.lowercaseString hasPrefix:CONSENT_PREFIX]) {
	NSString *newConsentString = [self getConsentStringFromRequest:request];
	[Logger debug:TAG :[NSString stringWithFormat:@"consent detected: %@", newConsentString]];
	if ([self.delegate respondsToSelector:@selector(receivedConsentString::)]) {
	  [self.delegate receivedConsentString:self:newConsentString ];
	}
	decisionHandler(WKNavigationActionPolicyAllow);
	return;
  }
  if ([request.URL.absoluteString containsString:@"apppreview.php"]) {
	decisionHandler(WKNavigationActionPolicyAllow);
  } else {
	decisionHandler(WKNavigationActionPolicyCancel);
  }
}

- (NSString *)getConsentStringFromRequest:(NSURLRequest *)request {
  NSRange consentStringRange = [request.URL.absoluteString rangeOfString:CONSENT_PREFIX options:NSBackwardsSearch];
  if (consentStringRange.location != NSNotFound) {
	NSString *responseString = [request.URL.absoluteString substringFromIndex:consentStringRange.location + consentStringRange.length];
	NSArray *response = [responseString componentsSeparatedByString:@"/"];
	NSString *consentString = response.firstObject;
	return consentString;
  }
  return nil;
}

@end
