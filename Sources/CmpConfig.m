//
//  CmpConfig.m
//  GDPR
//

#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import "CmpConfig.h"
#import "Logger.h"

NSString *const ConsentToolURLUnformatted = @"https://%@/delivery/appjson.php?id=%@&name=%@&consent=%@&idfa=%@&l=%@";

@interface CmpConfig ()
+ (NSInteger)getAttStatus:(NSUInteger)status;
@end
@implementation CmpConfig
static NSString *cmpId = nil;
static NSString *consentToolAppName = nil;
static NSString *consentToolDomain = nil;
static NSString *consentToolLanguage = nil;
static BOOL attActive = FALSE;
static NSInteger verboseLevel = 0;
static NSInteger *attStatus = 0;
API_AVAILABLE(ios(14))
static ATTrackingManager *atTrackingManager = nil;
NSString *idfa = nil;

+ (void)setValues:(NSString *)domain addCmpId:(NSString *)addCmpId addAppName:(NSString *)appName addLanguage:(NSString *)language {
  cmpId = addCmpId;
  consentToolAppName =
      [appName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
  consentToolDomain = domain;
  consentToolLanguage = language;
}

+ (void)setConsentToolDomain:(NSString *)ctd {
  consentToolDomain = ctd;
}

+ (NSString *)consentToolDomain {
  return consentToolDomain;
}

+ (void)setConsentToolId:(NSString *)cti {
  cmpId = cti;
}

+ (NSString *)consentToolId {
  return cmpId;
}

+ (void)setConsentToolAppName:(NSString *)ctan {
  consentToolAppName =
      [ctan stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

+ (NSString *)consentToolAppName {
  return consentToolAppName;
}

+ (void)setConsentToolLanguage:(NSString *)ctl {
  consentToolLanguage = ctl;
}

+ (NSString *)consentToolLanguage {
  return consentToolLanguage;
}

+ (BOOL)isValid {
  return consentToolDomain && consentToolAppName && cmpId && consentToolLanguage;
}

+ (void)setIDFA:(NSString *)setIDFA {
  idfa = setIDFA;
}

+ (void)setAppleTrackingStatus:(NSUInteger)status  API_AVAILABLE(ios(14)){
    attStatus = (NSInteger *)[self getAttStatus:status];
}

+ (void)setAutoAppleTracking:(BOOL)addAttActive {
  attActive = addAttActive;
}

+ (BOOL)getAutoAppleTracking {
  return attActive;
}
+ (NSInteger)getVerboseLevel {
   return verboseLevel;
}
+ (void)setVerboseLevel:(NSInteger)level {
  verboseLevel = level;
}

+ (NSString *)getIdfa {
  if (idfa != nil) {
    return idfa;
  } else {
    return @"";
  }
}

+ (NSString *)getConsentToolURLString:(NSString *)consent {
  [Logger debug:@"Config" :[NSString stringWithFormat:@"added Status %@", [NSValue valueWithPointer:attStatus]]];
  if (consent && ![consent containsString:@"null"]) {
    return [NSString stringWithFormat:ConsentToolURLUnformatted, consentToolDomain, cmpId, consentToolAppName, consent, [CmpConfig getIdfa], consentToolLanguage];
  } else {
    return [NSString stringWithFormat:ConsentToolURLUnformatted, consentToolDomain, cmpId, consentToolAppName, @"", [CmpConfig getIdfa], consentToolLanguage];
  }
}
+ (NSInteger)getAttStatus:(NSUInteger)status {
/**
 * notDetermined = 0
 * restricted = 1
 * denied = 2
 * authorized = 3
 */
  switch (status) {
    case 0:
      return 0;
    case 1:
      return 2;
    case 2:
      return 2;
    case 3:
      return 1;
    default:
      return 0;
  }
}
+ (NSInteger)getAppleTrackingStatus {
  return (NSInteger)attStatus;
}

+ (NSString *)description {
  return [NSString stringWithFormat:@"{\r"
                                    "cmpId: %@,\r"
                                    "domain: %@,\r"
                                    "appName: %@,\r"
                                    "idfa: %@,\r"
                                    "isAttActive: %@,\r"
                                    "attStatus: %@,\r"
                                    "}", cmpId, consentToolDomain, consentToolAppName, idfa, @(attActive), @((NSInteger)attStatus)];
}

@end
