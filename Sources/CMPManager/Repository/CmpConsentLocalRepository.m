//
// Created by Skander Ben Abdelmalak on 22.11.21.
//

#import "CmpConsentLocalRepository.h"
#import "CmpConsentDto.h"

static NSString *CMP_USER_CONSENT_KEY = @"cmp_user_consent";
@implementation CmpConsentLocalRepository {

}

+ (void)saveCmpUserConsent:(CmpConsentDto *)userConsent {
  NSError *error;
  NSData
	  *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:userConsent requiringSecureCoding:NO error:&error];
  if (error) {
	[NSException raise:@"Error during saving User Consent values" format:@"Error Message: %@", error];
  }
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:encodedObject forKey:CMP_USER_CONSENT_KEY];
  [defaults synchronize];
}

+ (CmpConsentDto *)fetchCmpUserConsent {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSData *encodedObject = [defaults objectForKey:CMP_USER_CONSENT_KEY];
  NSSet *allowedClasses =
	  [NSSet setWithObjects:[CmpConsentDto class], [NSString class], [NSNumber class], [NSArray class], nil];

  NSError *error = nil;
  CmpConsentDto *cmpUserConsentDto =
	  [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:encodedObject error:&error];
  if (error) {
	NSLog(@"%@", error.localizedDescription);
  }
  return cmpUserConsentDto;
}

+ (NSString *)getCmpApiKey {
	CmpConsentDto *dto = self.fetchCmpUserConsent;
	return dto.cmpApiKey;
}

+ (void)removeCmpConsent {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:CMP_USER_CONSENT_KEY];
}
@end
