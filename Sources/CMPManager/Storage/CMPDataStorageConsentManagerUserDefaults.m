//
//  CMPDataStorageConsentManagerUserDefaults.m
//  GDPR
//

#import "CMPDataStorageConsentManagerUserDefaults.h"

NSString *const US_PRIVACY = @"IABUSPrivacy_String";
NSString *const VENDORS = @"CMConsent_ParsedVendorConsents";
NSString *const PURPOSES = @"CMConsent_ParsedPurposeConsents";
NSString *const CONSENT_STRING = @"CMConsent_ConsentString";
NSString *const GOOGLE_AC = @"IABTCF_AddtlConsent";

@implementation CMPDataStorageConsentManagerUserDefaults

static NSUserDefaults *userDefaults = nil;

+ (NSString *)usPrivacyString {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:US_PRIVACY];
}

+ (void)setUsPrivacyString:(NSString *)usPrivacyString {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:usPrivacyString forKey:US_PRIVACY];
  [userDefaults synchronize];
}

+ (NSString *)consentString {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:CONSENT_STRING];
}

+ (void)setConsentString:(NSString *)consentString {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:consentString forKey:CONSENT_STRING];
  [userDefaults synchronize];
}

+ (NSString *)parsedVendorConsents {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:VENDORS];
}

+ (void)setParsedVendorConsents:(NSString *)parsedVendorConsents {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:parsedVendorConsents forKey:VENDORS];
  [userDefaults synchronize];
}

+ (NSString *)parsedPurposeConsents {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:PURPOSES];
}

+ (void)setParsedPurposeConsents:(NSString *)parsedPurposeConsents {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:parsedPurposeConsents forKey:PURPOSES];
  [userDefaults synchronize];
}

+ (NSString *)googleACString {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:GOOGLE_AC];
}

+ (void)setGoogleACString:(NSString *)googleACString {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:googleACString forKey:GOOGLE_AC];
  [userDefaults synchronize];
}

+ (void)clearContents {
  NSLog(@"cleaning the userDefaults ConsentManager");
  [self setParsedPurposeConsents:@""];
  [self setParsedVendorConsents:@""];
  [self setUsPrivacyString:@""];
  [self setConsentString:@""];
}

+ (NSUserDefaults *)getUserDefaults {
  if (userDefaults == nil) {
    userDefaults = [NSUserDefaults standardUserDefaults];
  }
  return userDefaults;

}
+ (NSString *)description {
  return [NSString stringWithFormat:@"{"
                                    "%@: %@,"
                                    "%@: %@,"
                                    "%@: %@,"
                                    "%@: %@,"
                                    "%@: %@,"
                                    "}",
                                    US_PRIVACY, [self usPrivacyString],
                                    VENDORS, [self parsedVendorConsents],
                                    PURPOSES, [self parsedPurposeConsents],
                                    CONSENT_STRING, [self consentString],
                                    GOOGLE_AC, [self googleACString]];
}

@end
