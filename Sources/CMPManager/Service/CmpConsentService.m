//
// Created by Skander Ben Abdelmalak on 20.11.21.
//

#import "CmpConsentService.h"
#import "CmpConsentDto.h"
#import "CMPDataStorageV1UserDefaults.h"
#import "CMPDataStorageV2UserDefaults.h"
#import "CMPDataStorageConsentManagerUserDefaults.h"
#import "CMPDataStoragePrivateUserDefaults.h"
#import "CmpUtils.h"
#import "CMPConsentV1Parser.h"
#import "CMPConsentV2Parser.h"
#import "Logger.h"

@implementation CmpConsentService {

}
static NSString *TAG = @"[Cmp]ConsentService";

+ (bool)userAcceptedConsent:(CmpConsentDto *)consentDto {
  //validate consentString
  if (![CmpConsentDto isValid:consentDto]) {
	[Logger error:TAG :@"Consent String is not valid"];
	[self errorDuringAcceptingConsent];
	return NO;
  }
  @try {
	[self parseConsentManagerString:consentDto.cmpApiKey];
	[CmpConsentLocalRepository saveCmpUserConsent:consentDto];
  }
  @catch (id anException){
	[Logger error:TAG :anException];
	return NO;
  }
  [Logger debug:TAG :[NSString stringWithFormat:@"written V2User defaults: %@", [CMPDataStorageV2UserDefaults description]]];
  [Logger info:TAG :@"User Accepted a new Consent"];
  return YES;
}

+ (void)errorDuringAcceptingConsent {

}

+ (void)userOpenedConsentLayer {

}

+ (void)cmpManagerOpenedConsentLayer {

}

+ (void)updateUserConsent:(NSString *)consentString {

}

+ (void)userImportedConsent:(NSString *)data {
  [Logger debug:TAG :[NSString stringWithFormat:@"consent passed to import: %@", data]];
}

+ (NSString *)getCmpApiKey {
  NSString *cmpApiKey = [CmpConsentLocalRepository getCmpApiKey];
  return  cmpApiKey;
}

+ (void)resetConsent {
  [CmpConsentLocalRepository removeCmpConsent];
  [CMPDataStorageV2UserDefaults clearContents];
  [CMPDataStorageConsentManagerUserDefaults clearContents];
}

+ (void)consentLayerOpened {
  //TODO refactor to dedicated state Repository
  [CMPDataStorageV1UserDefaults setCmpPresent:YES];
}

#pragma mark helper

+ (void)proceedConsentString:(NSString *)consentS {
  if ([[consentS substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"B"]) {
	[Logger debug:TAG :[NSString stringWithFormat:@"deprecated V1 String detected"]];
	[CMPDataStorageV2UserDefaults clearContents];
	[CMPDataStorageV1UserDefaults setConsentString:consentS];
	[CMPDataStorageV1UserDefaults setParsedVendorConsents:[CMPConsentV1Parser parseVendorConsentsFrom:consentS]];
	[CMPDataStorageV1UserDefaults setParsedPurposeConsents:[CMPConsentV1Parser parsePurposeConsentsFrom:consentS]];
  } else {
	[Logger debug:TAG :[NSString stringWithFormat:@"V2 String detected"]];
	[CMPDataStorageV1UserDefaults clearContents];
	[CMPDataStorageV2UserDefaults setTcString:consentS];
	(void)[[CMPConsentV2Parser alloc] init:consentS];
  }
}

+ (void)parseConsentManagerString:(NSString *)consentString {
  [Logger debug:TAG :[NSString stringWithFormat:@"%@:parse ConsentApiKey: %@",TAG,  consentString]];
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
	  [Logger debug:TAG :[NSString stringWithFormat:@"decoded base64 consent String: %@", base64Decoded]];
	  NSArray *splits = [base64Decoded componentsSeparatedByString:@"#"];

	  if (splits.count > 3) {
		[Logger debug:TAG :[NSString stringWithFormat:@"ConsentManager String detected: %@", splits[0]]];
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

+ (void)proceedConsentManagerValues:(NSArray *)splits {
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

+ (BOOL)validConsent {
  return [CMPDataStorageConsentManagerUserDefaults consentString] != nil || [CMPDataStorageConsentManagerUserDefaults consentString].length>0;
}
@end