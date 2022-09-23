//
//  CMPConsentTool.m
//  GDPA
//
//

#import "CMPConsentTool.h"
#import "CMPDataStorageConsentManagerUserDefaults.h"
#import "CMPDataStorageV1UserDefaults.h"
#import "CMPDataStorageV2UserDefaults.h"
#import "CMPDataStoragePrivateUserDefaults.h"
#import "CmpLayerViewController.h"
#import "CmpUtils.h"
#import "CMPConsentV1Parser.h"
#import "CMPConsentV2Parser.h"
#import "ATTrackingHelper.h"
#import "CmpConsentDto.h"
#import "Logger.h"

@interface CMPConsentTool ()<CmpLayerViewControllerDelegate, CmpPlaceholderDelegate>
- (void)openCmpLayer;
@end

@implementation CMPConsentTool

@synthesize closeListener;
@synthesize openListener;
@synthesize networkErrorListener;
@synthesize serverErrorListener;
@synthesize customOpenListener;
@synthesize onCMPNotOpenedListener;

static NSString *TAG = @"[Cmp]ConsentTool";

- (CmpConfig *)cmpConfig {
  return _cmpConfig;
}

- (void)onCMPNotOpenedListener:(void (^)(void))callback {
  onCMPNotOpenedListener = callback;
}

- (void)closeListener:(void (^)(void))listener {
  closeListener = listener;
}

- (void)openListener:(void (^)(void))listener {
  openListener = listener;
}

- (void)customOpenListener:(void (^)(CMPSettings *settings))listener {
  customOpenListener = listener;
}

- (void)networkErrorListener:(void (^)(NSString *error))listener {
  networkErrorListener = listener;
}

- (void)serverErrorListener:(void (^)(NSString *error))listener {
  serverErrorListener = listener;
}

/*
 * @brief manually open Consent Layer
 */
- (void)openCmpConsentToolView {
  [self openCmpLayer];
}

/**
 * ! deprecated
 * @param close_listener Close Listener
 */
- (void)openCmpConsentToolView:(void (^)(void))close_listener {
  [self openCmpLayer];
}

/**
 * @brief verify if Consent Layer needs to be opened
 */
- (void)verifyOpenCmpLayer {
  // initialize ViewController
  CmpLayerViewController *consentToolVC = [[CmpLayerViewController alloc] init];
  /**
   * @attention just Open View is the switch for the VC whether it verifies to open Layer or not
   */
  consentToolVC.justOpenView = NO;
  consentToolVC.delegate = self;
  [consentToolVC initWebView];
}

/**
 * @brief Open Cmp Layer - with force option. This function opens the Layer without verify if it needs to be opened
 * @example if User explicitly wants to open layer to change consent
 */
- (void)openCmpLayer {
  // TODO should be deleted when local data is refactored
  if ([CmpConfig isValid]) {
	[CMPSettings setConsentString:[CMPDataStorageConsentManagerUserDefaults consentString]];
  } else {
	[Logger error:TAG :@"CmpConfig is invalid"];
  }
  // initialize ViewController
  CmpLayerViewController *consentToolVC = [[CmpLayerViewController alloc] init];
  /**
    * @attention just Open View is the switch for the VC whether it verifies to open Layer or not
    */
  consentToolVC.justOpenView = YES;
  consentToolVC.timedOut = NO;
  consentToolVC.delegate = self;
  [consentToolVC initWebView];
}

#pragma mark CMPConsentToolViewController delegate
/**
 * @brief Delegate Method to get callback from ViewController with the desired consent String
 * @param cmpLayerViewController Consent Layer ViewController
 * @param consentString consentString
 * ! deprecated instead use didReceivedConsentDto when possible
 */
- (void)didReceivedConsentString:(CmpLayerViewController *)cmpLayerViewController consentString:(NSString *)consentString {
  [Logger warning:TAG :@"Use fo deprecated method"];
  [self parseConsentManagerString:consentString];
  if (self.closeListener) {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
	  self.closeListener();
	});
  }
}

/**
 * @brief Delegate Method to get callback from ViewController with the desired consent String
 * @param cmpLayerViewController ViewController
 * @param cmpUserConsentDto Consent Object
 */
- (void)didReceivedConsentDto:(CmpLayerViewController *)cmpLayerViewController :(CmpConsentDto *)cmpUserConsentDto {
  if(![CmpConsentService userAcceptedConsent:cmpUserConsentDto]) {
	cmpLayerViewController.isOpen = NO;
	cmpLayerViewController.isMessageSent = YES;
	[cmpLayerViewController dismissViewControllerAnimated:YES completion:nil];
  }
  [self handleCloseEvent];
}

/**
 * @brief Preloading the WebView to increase UX, delegate to get feedback from ViewController when WebView is finished
 * @param cmpLayerViewController consent Layer View Controller
 */
- (void)didFinishedLoading:(CmpLayerViewController *)cmpLayerViewController {
  if (!cmpLayerViewController.isOpen && !cmpLayerViewController.isMessageSent)  {
	cmpLayerViewController.isOpen = YES ;
	[CmpConsentService consentLayerOpened];
	[self.viewController presentViewController:cmpLayerViewController animated:YES completion:nil];
  } else {
	[Logger warning:TAG :@"The Consent Layer has Problems to open the View. Please try again later"];
	[self handleNetworkErrorEvent:@"The Consent Layer has Problems to open the View. Please try again later"];
  }
}

- (void)cancelConsentLayer:(CmpLayerViewController *)cmpLayerViewController {
	[cmpLayerViewController dismissViewControllerAnimated:YES completion:nil];
	[cmpLayerViewController reset];
}

#pragma mark handling callback Events

/**
 * @brief handle Event callback on Close
 */
- (void)handleCloseEvent {
  if (closeListener) {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
	  self.closeListener();
	});
  }
}

/**
 * @brief handle Event callback on Consent Layer opened
 */
- (void)handleLayerOpenedEvent {
  if (self.openListener) {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
	  self.openListener();
	});
  }

  if (self.customOpenListener) {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
	  self.customOpenListener([CMPSettings self]);
	});
	return;
  }
}

/**
 * @brief handle Event callback on Consent Layer *NOT* opened
 */
- (void)handleLayerNotOpenedEvent {
  if (onCMPNotOpenedListener) {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
	  self.onCMPNotOpenedListener();
	});
  }
}

/**
 * @brief handling Event callback on Error
 * @param message Error message
 */
- (void)handleErrorEvent:(NSString *)message {
  if (serverErrorListener) {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
	  self.serverErrorListener(message);
	});

  } else {
	UIAlertController *alert =
		[UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction *cancel =
		[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
	[alert addAction:cancel];
	[self.viewController presentViewController:alert animated:YES completion:nil];
  }
}

- (void)handleNetworkErrorEvent:(NSString *)message {
  if (networkErrorListener) {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
	  self.networkErrorListener(message);
	});
  }
}



#pragma mark helper methods

- (void)parseConsentManagerString:(NSString *)consentString {
  [Logger debug:TAG :[NSString stringWithFormat:@"parse Consent: %@", consentString]];
  [CMPDataStorageV1UserDefaults setCmpPresent:NO];

  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd"];
  [CMPDataStoragePrivateUserDefaults setNeedsAcceptance:NO];

  @try {
	if (consentString != NULL && consentString.length > 0
		&& ![consentString isEqualToString:@"null"] && ![consentString isEqualToString:@"nil"]
		&& ![consentString isEqualToString:@""]) {
	  [CMPDataStorageConsentManagerUserDefaults setConsentString:consentString];
	  NSString *base64Decoded = [CmpUtils binaryStringConsentFrom:consentString];
	  [Logger debug:TAG :[NSString stringWithFormat:@"decoded base64: %@", base64Decoded]];
	  NSArray *splits = [base64Decoded componentsSeparatedByString:@"#"];

	  if (splits.count > 3) {
		[Logger debug:TAG :[NSString stringWithFormat:@"%@, ConsentManager String detected: %@", TAG, splits[0] ]];
		[self proceedConsentString:splits[0]];
		[self proceedConsentManagerValues:splits];
	  } else {
		[CMPDataStorageV1UserDefaults clearContents];
		[CMPDataStorageV2UserDefaults clearContents];
	  }
	} else {
	  [CMPDataStorageV1UserDefaults clearContents];
	  [CMPDataStorageV2UserDefaults clearContents];
	}
  }
  @catch (NSException *e) {
	[CMPDataStorageV1UserDefaults clearContents];
	[CMPDataStorageV2UserDefaults clearContents];
  }
}

- (BOOL)importCMPData:(NSString *)cmpData {
  [CmpConsentService userImportedConsent:cmpData];
  [self parseConsentManagerString:cmpData];
  return YES;
}

+ (NSString *)exportCMPData {
  return [CMPDataStorageConsentManagerUserDefaults consentString];
}

- (void)proceedConsentString:(NSString *)consentS {
  [Logger debug:TAG :[NSString stringWithFormat:@"proceed Consent String: %@", consentS]];
  if ([[consentS substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"B"]) {
	[Logger debug:TAG :@"V1 String detected"];
	[CMPDataStorageV2UserDefaults clearContents];
	[CMPDataStorageV1UserDefaults setConsentString:consentS];
	[CMPDataStorageV1UserDefaults setParsedVendorConsents:[CMPConsentV1Parser parseVendorConsentsFrom:consentS]];
	[CMPDataStorageV1UserDefaults setParsedPurposeConsents:[CMPConsentV1Parser parsePurposeConsentsFrom:consentS]];
  } else {
	[Logger debug:TAG :@"V2 String detected"];
	[CMPDataStorageV1UserDefaults clearContents];
	[CMPDataStorageV2UserDefaults setTcString:consentS];
	(void)[[CMPConsentV2Parser alloc] init:consentS];
  }
}

- (void)saveConsentValuesFromDto:(CmpConsentDto *)cmpUserConsentDto {
  [CmpConsentLocalRepository saveCmpUserConsent:cmpUserConsentDto];

}

- (void)proceedConsentManagerValues:(NSArray *)splits {
  if (splits.count > 1) {
	[CMPDataStorageConsentManagerUserDefaults setParsedPurposeConsents:splits[1]];
	[Logger debug:TAG :[NSString stringWithFormat:@"ParsedPurposeConsents:%@", splits[1]]];
  }
  if (splits.count > 2) {
	[CMPDataStorageConsentManagerUserDefaults setParsedVendorConsents:splits[2]];
	[Logger debug:TAG :[NSString stringWithFormat:@"ParsedVendorConsents:%@", splits[2]]];
  }
  if (splits.count > 3) {
	[CMPDataStorageConsentManagerUserDefaults setUsPrivacyString:splits[3]];
	[Logger debug:TAG :[NSString stringWithFormat:@"ParsedUSPrivacy:%@", splits[3]]];
  }
  if (splits.count > 4) {
	[CMPDataStorageConsentManagerUserDefaults setGoogleACString:splits[4]];
	[Logger debug:TAG :[NSString stringWithFormat:@"GoogleACString:%@", splits[4]]];
  }
}

- (NSString *)getVendorsString {
  return [CMPDataStorageConsentManagerUserDefaults parsedVendorConsents];
}

- (NSString *)getPurposesString {
  return [CMPDataStorageConsentManagerUserDefaults parsedPurposeConsents];
}

- (NSString *)getUSPrivacyString {
  return [CMPDataStorageConsentManagerUserDefaults usPrivacyString];
}

- (NSString *)getGoogleACString {
  return [CMPDataStorageConsentManagerUserDefaults googleACString];
}

- (BOOL)hasVendorConsent:(NSString *)vendorId vendorIsV1orV2:(BOOL)isIABVendor {
	CmpConsentDto *consentDto = [CmpConsentLocalRepository fetchCmpUserConsent];
	return [consentDto hasVendor:vendorId];
}

/**
 * @brief Passes a purpose ID of Version 1 or 2 . Version 1 is deprecated
 * @param purposeId V1 or V2 purpose
 * @param isIABPurpose boolean if the Purpose is an IAB Purpose
 * @return boolean if the user gives consent about the purpose
 */
- (BOOL)hasPurposeConsent:(NSString *)purposeId purposeIsV1orV2:(BOOL)isIABPurpose {
  CmpConsentDto *consentDto = [CmpConsentLocalRepository fetchCmpUserConsent];
  return [consentDto hasPurpose:purposeId];
}

- (BOOL)hasPurposeConsent:(int)purposeId forVendor:(int)vendorId {
  NSNumber *purposeIdInt = @(purposeId);
  PublisherRestriction *pr = [CMPDataStorageV2UserDefaults publisherRestriction:purposeIdInt];
  return [pr hasVendor:vendorId];
}

# pragma mark constructor methods
- (id)init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController {
  return [self init:domain addId:userId addAppName:appName addLanguage:language addViewController:viewController autoupdate:TRUE];
}

- (id)init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController addOpenListener:(void (^)(
	void))openListener {
  return [self init:domain addId:userId addAppName:appName addLanguage:language addViewController:viewController autoupdate:TRUE addOpenListener:openListener];
}

- (id)init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController addCloseListener:(void (^)(
	void))closeListener {
  return [self init:domain addId:userId addAppName:appName addLanguage:language addViewController:viewController autoupdate:TRUE addCloseListener:closeListener];
}

- (id)                             init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController addOpenListener:(void (^)(
	void))openListener addCloseListener:(void (^)(void))closeListener {
  return [self init:domain addId:userId addAppName:appName addLanguage:language addViewController:viewController autoupdate:TRUE addOpenListener:openListener addCloseListener:closeListener];
}

- (id)                             init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addIDFA:(NSString *)idfa addViewController:(UIViewController *)viewController addOpenListener:(void (^)(
	void))openListener addCloseListener:(void (^)(void))closeListener {
  return [self init:domain addId:userId addAppName:appName addLanguage:language addIDFA:idfa addViewController:viewController autoupdate:TRUE addOpenListener:openListener addCloseListener:closeListener];
}

- (id)init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOpenListener:(void (^)(
	void))openListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:openListener];
}

- (id)init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addCloseListener:(void (^)(
	void))closeListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addCloseListener:closeListener];
}

- (id)                             init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOpenListener:(void (^)(
	void))openListener addCloseListener:(void (^)(void))closeListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:openListener addCloseListener:closeListener];
}

- (id)                             init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addIDFA:(NSString *)idfa addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOpenListener:(void (^)(
	void))openListener addCloseListener:(void (^)(void))closeListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  [CmpConfig setIDFA:idfa];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:openListener addCloseListener:closeListener];
}

- (id)init:(CmpConfig *)config withViewController:(UIViewController *)viewController {
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:TRUE];
}

- (id)init:(CmpConfig *)config withViewController:(UIViewController *)viewController addOpenListener:(void (^)(void))openListener {
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:TRUE addOpenListener:openListener];
}

- (id)init:(CmpConfig *)config withViewController:(UIViewController *)viewController addCloseListener:(void (^)(void))closeListener {
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:TRUE addCloseListener:closeListener];
}

- (id)init:(CmpConfig *)config withViewController:(UIViewController *)viewController addOpenListener:(void (^)(void))openListener addCloseListener:(void (^)(
	void))closeListener {
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:TRUE addOpenListener:openListener addCloseListener:closeListener];
}

- (id)init:(CmpConfig *)config withViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate {
  return [self init:config withViewController:viewController autoupdate:autoupdate addOpenListener:nil addCloseListener:nil];
}

- (id)init:(CmpConfig *)config withViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOpenListener:(void (^)(
	void))openListener {
  return [self init:config withViewController:viewController autoupdate:autoupdate addOpenListener:openListener addCloseListener:nil];
}

- (id)init:(CmpConfig *)config withViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addCloseListener:(void (^)(
	void))closeListener {
  return [self init:config withViewController:viewController autoupdate:autoupdate addOpenListener:nil addCloseListener:closeListener];
}


// Initialize without autoupdate part:

/// init with following parameters
/// @param domain cmp Domain
/// @param userId <#userId description#>
/// @param appName <#appName description#>
/// @param language <#language description#>
/// @param viewController <#viewController description#>
/// @param openListener <#openListener description#>
/// @param onCMPNotOpenedListener <#onCMPOpenedListener description#>
- (id)                                      init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController addOpenListener:(void (^)(
	void))openListener addOnCMPNotOpenedListener:(void (^)(void))onCMPNotOpenedListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:TRUE addOpenListener:openListener addCloseListener:nil addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

/// init with following parameters
/// @param domain cmp Domain
/// @param userId <#userId description#>
/// @param appName <#appName description#>
/// @param language <#language description#>
/// @param viewController <#viewController description#>
/// @param openListener <#openListener description#>
/// @param closeListener <#closeListener description#>
/// @param onCMPNotOpenedListener <#onCMPOpenedListener description#>
- (id)                             init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController addOpenListener:(void (^)(
	void))openListener addCloseListener:(void (^)(void))closeListener addOnCMPNotOpenedListener:(void (^)(void))onCMPNotOpenedListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:TRUE addOpenListener:openListener addCloseListener:closeListener addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

/// init with following parameters
/// @param domain cmp Domain
/// @param userId <#userId description#>
/// @param appName <#appName description#>
/// @param language <#language description#>
/// @param viewController <#viewController description#>
/// @param onCMPNotOpenedListener <#onCMPOpenedListener description#>
- (id)init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController addOnCMPNotOpenedListener:(void (^)(
	void))onCMPNotOpenedListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:TRUE addOpenListener:nil addCloseListener:nil addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

/// init with following parameters
/// @param domain cmp Domain
/// @param userId <#userId description#>
/// @param appName <#appName description#>
/// @param language <#language description#>
/// @param idfa <#idfa description#>
/// @param viewController <#viewController description#>
/// @param autoupdate <#autoupdate description#>
/// @param openListener <#openListener description#>
/// @param closeListener <#closeListener description#>
/// @param onCMPNotOpenedListener <#onCMPOpenedListener description#>
- (id)                             init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addIDFA:(NSString *)idfa addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOpenListener:(void (^)(
	void))openListener addCloseListener:(void (^)(void))closeListener addOnCMPNotOpenedListener:(void (^)(void))onCMPNotOpenedListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  [CmpConfig setIDFA:idfa];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:openListener addCloseListener:closeListener addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

- (id)                                      init:(CmpConfig *)config withViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOpenListener:(void (^)(
	void))openListener addOnCMPNotOpenedListener:(void (^)(void))onCMPNotOpenedListener {
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:openListener addCloseListener:nil addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

- (id)init:(CmpConfig *)config withViewController:(UIViewController *)viewController addOpenListener:(void (^)(void))openListener addOnCMPNotOpenedListener:(void (^)(
	void))onCMPNotOpenedListener {
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:TRUE addOpenListener:openListener addCloseListener:nil addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

- (id)init:(CmpConfig *)config withViewController:(UIViewController *)viewController addCloseListener:(void (^)(void))closeListener addOnCMPNotOpenedListener:(void (^)(
	void))onCMPNotOpenedListener {
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:TRUE addOpenListener:nil addCloseListener:closeListener addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

- (id)                                       init:(CmpConfig *)config withViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addCloseListener:(void (^)(
	void))closeListener addOnCMPNotOpenedListener:(void (^)(void))onCMPNotOpenedListener {
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:nil addCloseListener:closeListener addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

- (id)                             init:(CmpConfig *)config withViewController:(UIViewController *)viewController addOpenListener:(void (^)(
	void))openListener addCloseListener:(void (^)(void))closeListener addOnCMPNotOpenedListener:(void (^)(void))onCMPNotOpenedListener {
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:TRUE addOpenListener:openListener addCloseListener:closeListener addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

/// <#Description#>
/// @param domain <#domain description#>
/// @param userId <#userId description#>
/// @param appName <#appName description#>
/// @param language <#language description#>
/// @param idfa <#idfa description#>
/// @param viewController <#viewController description#>
/// @param autoupdate <#autoupdate description#>
/// @param openListener <#openListener description#>
/// @param onCMPNotOpenedListener <#onCMPOpenedListener description#>
- (id)                                      init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addIDFA:(NSString *)idfa addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOpenListener:(void (^)(
	void))openListener addOnCMPNotOpenedListener:(void (^)(void))onCMPNotOpenedListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  [CmpConfig setIDFA:idfa];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:openListener addCloseListener:nil addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

/// <#Description#>
/// @param domain <#domain description#>
/// @param userId <#userId description#>
/// @param appName <#appName description#>
/// @param language <#language description#>
/// @param idfa <#idfa description#>
/// @param viewController <#viewController description#>
/// @param autoupdate <#autoupdate description#>
/// @param onCMPNotOpenedListener onCMPOpenedListener description
- (id)init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addIDFA:(NSString *)idfa addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOnCMPNotOpenedListener:(void (^)(
	void))onCMPNotOpenedListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  [CmpConfig setIDFA:idfa];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:nil addCloseListener:nil addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

/**
 Creates a new instance of this CMPConsentTool.
 @param config <#config description#>
 @param viewController <#viewController description#>
 @param autoupdate <#autoupdate description#>
 @param onCMPNotOpenedListener onCMPOpenedListener  event
 */
- (id)init:(CmpConfig *)config withViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOnCMPNotOpenedListener:(void (^)(
	void))onCMPNotOpenedListener {
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:nil addCloseListener:nil addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

/// <#Description#>
/// @param domain <#domain description#>
/// @param userId <#userId description#>
/// @param appName <#appName description#>
/// @param language <#language description#>
/// @param idfa <#idfa description#>
/// @param viewController <#viewController description#>
/// @param autoupdate <#autoupdate description#>
/// @param closeListener <#closeListener description#>
/// @param onCMPNotOpenedListener <#onCMPOpenedListener description#>
- (id)                                       init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addIDFA:(NSString *)idfa addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addCloseListener:(void (^)(
	void))closeListener addOnCMPNotOpenedListener:(void (^)(void))onCMPNotOpenedListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  [CmpConfig setIDFA:idfa];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:nil addCloseListener:closeListener addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

- (id)                             init:(CmpConfig *)config withViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOpenListener:(void (^)(
	void))openListener addCloseListener:(void (^)(void))closeListener addOnCMPNotOpenedListener:(void (^)(void))onCMPNotOpenedListener {
  self.cmpConfig = config;
  self.viewController = viewController;
  self.closeListener = closeListener;
  self.openListener = openListener;
  self.onCMPNotOpenedListener = onCMPNotOpenedListener;

  [self checkAndProceedConsentUpdate];

  if (autoupdate) {
	[[NSNotificationCenter defaultCenter] addObserver:self.viewController
											 selector:@selector(onApplicationDidBecomeActive:)
												 name:@"NSApplicationDidBecomeActiveNotification"
											   object:nil];
  }

  return self;
}

/// <#Description#>
/// @param domain <#domain description#>
/// @param userId <#userId description#>
/// @param appName <#appName description#>
/// @param language <#language description#>
/// @param idfa <#idfa description#>
/// @param viewController <#viewController description#>
/// @param closeListener <#closeListener description#>
/// @param onCMPNotOpenedListener <#onCMPOpenedListener description#>
- (id)                                       init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addIDFA:(NSString *)idfa addViewController:(UIViewController *)viewController addCloseListener:(void (^)(
	void))closeListener addOnCMPNotOpenedListener:(void (^)(void))onCMPNotOpenedListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  [CmpConfig setIDFA:idfa];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:TRUE addOpenListener:nil addCloseListener:closeListener addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

/// <#Description#>
/// @param domain <#domain description#>
/// @param userId <#userId description#>
/// @param appName <#appName description#>
/// @param language <#language description#>
/// @param viewController <#viewController description#>
/// @param closeListener <#closeListener description#>
/// @param onCMPNotOpenedListener <#onCMPOpenedListener description#>
- (id)                                       init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController addCloseListener:(void (^)(
	void))closeListener addOnCMPNotOpenedListener:(void (^)(void))onCMPNotOpenedListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:TRUE addOpenListener:nil addCloseListener:closeListener addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

- (id)                             init:(CmpConfig *)config withViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOpenListener:(void (^)(
	void))openListener addCloseListener:(void (^)(void))closeListener {
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:openListener addCloseListener:closeListener addOnCMPNotOpenedListener:nil];
}


//----------------------- PART Initialize with autoupdate (8) -------------------------------------

- (id)init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate];
}

- (id)init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOnCMPNotOpenedListener:(void (^)(
	void))onCMPNotOpenedListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:nil addCloseListener:nil addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

- (id)                                      init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOpenListener:(void (^)(
	void))openListener addOnCMPNotOpenedListener:(void (^)(void))onCMPNotOpenedListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:openListener addCloseListener:nil addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

- (id)                                       init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addCloseListener:(void (^)(
	void))closeListener addOnCMPNotOpenedListener:(void (^)(void))onCMPNotOpenedListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:nil addCloseListener:closeListener addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}

- (id)                             init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOpenListener:(void (^)(
	void))openListener addCloseListener:(void (^)(void))closeListener addOnCMPNotOpenedListener:(void (^)(void))onCMPNotOpenedListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:openListener addCloseListener:closeListener addOnCMPNotOpenedListener:onCMPNotOpenedListener];
}


//----------------------- PART Initialize with IDFA and autoupdate (8) -------------------------------------

- (id)init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addIDFA:(NSString *)idfa addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  [CmpConfig setIDFA:idfa];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:nil addCloseListener:nil addOnCMPNotOpenedListener:nil];
}

- (id)init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addIDFA:(NSString *)idfa addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addOpenListener:(void (^)(
	void))openListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  [CmpConfig setIDFA:idfa];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:openListener addCloseListener:nil addOnCMPNotOpenedListener:nil];
}

- (id)init:(NSString *)domain addId:(NSString *)userId addAppName:(NSString *)appName addLanguage:(NSString *)language addIDFA:(NSString *)idfa addViewController:(UIViewController *)viewController autoupdate:(BOOL)autoupdate addCloseListener:(void (^)(
	void))closeListener {
  [CmpConfig setValues:domain addCmpId:userId addAppName:appName addLanguage:language];
  [CmpConfig setIDFA:idfa];
  return [self init:[CmpConfig self] withViewController:viewController autoupdate:autoupdate addOpenListener:nil addCloseListener:closeListener addOnCMPNotOpenedListener:nil];
}

//----------------------- Class functions -------------------------------------

#pragma mark instance Methods
- (void)onApplicationDidBecomeActive:(NSNotification *)notification {
  [self checkAndProceedConsentUpdate];
}

- (void)checkAndProceedConsentUpdate {
  // check if ATT is activated
  if (@available(iOS 14.0, *)) {
	if ([CmpConfig getAutoAppleTracking]) { //@available(iOS 13.0, *)
	  [ATTrackingHelper requestATTPermission];
	}
  }
  if ([self needsServerUpdate]) {
	[self verifyOpenCmpLayer];
  } else {
	[Logger info:TAG :@"No update needed. Server was already requested today and Consent was given."];
  }

}

- (BOOL)needsServerUpdate {
  return ![self calledThisDay] || ![self isConsentValid];
}
- (BOOL)isConsentValid {
  return [CmpConsentService validConsent];
}

- (BOOL)needsConsentAcceptance {
  return [self needsAcceptance];
}

- (CMPServerResponse *)proceedServerRequest {
  return [CmpUtils getAndSaveServerResponse:networkErrorListener
						serverErrorListener:serverErrorListener
								withConsent:[CMPDataStorageConsentManagerUserDefaults consentString]];
}

- (void)proceedConsentUpdate:(CMPServerResponse *)cmpServerResponse {
  [self proceedConsentUpdate:cmpServerResponse withOpening:TRUE];
}

- (void)proceedConsentUpdate:(CMPServerResponse *)cmpServerResponse withOpening:(BOOL)opening {
  switch ([cmpServerResponse.status intValue]) {
	case 0:return;
	case 1:
	  if (opening) {
		[CMPDataStoragePrivateUserDefaults setNeedsAcceptance:TRUE];
		[self verifyOpenCmpLayer];
	  }
	  return;
	default:[self handleErrorEvent:cmpServerResponse.message];
	  break;
  }
}

- (BOOL)calledThisDay {
  NSString *last = [self getCalledLast];
  if (last) {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSString *now = [dateFormatter stringFromDate:[NSDate date]];
	return [now isEqualToString:last];
  }
  return FALSE;
}

- (BOOL)needsAcceptance {
  return [CMPDataStoragePrivateUserDefaults needsAcceptance];
}

- (NSString *)getCalledLast {
  return [CMPDataStoragePrivateUserDefaults lastRequested];
}

+ (void)reset {
  [CMPDataStorageV1UserDefaults clearContents];
  [CMPDataStorageV2UserDefaults clearContents];
  [CMPDataStoragePrivateUserDefaults clearContents];
  [CMPDataStorageConsentManagerUserDefaults clearContents];
}

#pragma mark - Placeholder functions

- (CmpPlaceholderView *)createPlaceholder:(CGRect)frame :(CmpPlaceholderParams *)placeholderParams {
  CmpPlaceholderView *view = [[CmpPlaceholderView alloc] initWithPlaceholderParams:placeholderParams];
  view.delegate = self;

  return [view createPreview:frame];
}

/**
 *
 * @param placeholderView UI View
 * @param consent_string ConsentString
 * @attention Old Api from consent://
 */
- (void)receivedConsentString:(CmpPlaceholderView *)placeholderView :(NSString *)consent_string {
  [Logger debug:TAG :@"Received Consent of Placeholder"];
  [self parseConsentManagerString:consent_string];
  if (self.closeListener) {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
	  self.closeListener();
	});
  }
  if ([placeholderView.vendorDelegate respondsToSelector:@selector(vendorAccepted:)]) {
	[placeholderView.vendorDelegate vendorAccepted:placeholderView];
  }
}

#pragma mark - debug

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@"
									"Object %@"">", @"CmpConsentTool", [CmpConsentLocalRepository fetchCmpUserConsent].description];
}

@end
