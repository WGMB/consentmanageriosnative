//
//  CMPDataStoragePrivateUserDefaults.m
//  GDPR
//

#import "CMPDataStoragePrivateUserDefaults.h"

NSString *const CONSENT_TOOL_URL = @"IABConsent_ConsentToolUrl";
NSString *const CMP_REQUEST = @"IABConsent_CMPRequest";
NSString *const CMP_ACCEPTED = @"IABConsent_CMPAccepted";

@implementation CMPDataStoragePrivateUserDefaults

static NSUserDefaults *userDefaults = nil;

+ (NSString *)consentToolUrl {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:CONSENT_TOOL_URL];
}

+ (void)setConsentToolUrl:(NSString *)consentToolUrl {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:consentToolUrl forKey:CONSENT_TOOL_URL];
  [userDefaults synchronize];
}

+ (NSString *)lastRequested {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:CMP_REQUEST];
}

+ (void)setLastRequested:(NSString *)lastRequested {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:lastRequested forKey:CMP_REQUEST];
  [userDefaults synchronize];
}

+ (BOOL)needsAcceptance {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults boolForKey:CMP_ACCEPTED];
}

+ (void)setNeedsAcceptance:(BOOL)needsAcceptance {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setBool:needsAcceptance forKey:CMP_ACCEPTED];
  [userDefaults synchronize];
}

+ (void)clearContents {
  NSLog(@"cleaning the userDefaults Private Storage");
  [self setConsentToolUrl:@""];
  [self setLastRequested:@""];
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
									"%@: %@"
									"}", CONSENT_TOOL_URL, [self consentToolUrl], CMP_REQUEST, [self lastRequested], CMP_ACCEPTED, @([self needsAcceptance])];
}

@end
