//
//  CmpConfig.m
//  GDPR
//

#import "CMPSettings.h"
#import "CMPDataStorageV1UserDefaults.h"
#import "CMPDataStorageV2UserDefaults.h"
#import "CMPDataStorageConsentManagerUserDefaults.h"

@implementation CMPSettings

+ (void)setConsentString:(NSString *)cs {
  [CMPDataStorageConsentManagerUserDefaults setConsentString:cs];
}

+ (NSString *)consentString {
  return [CMPDataStorageConsentManagerUserDefaults consentString];
}

+ (void)setSubjectToGdpr:(SubjectToGDPR)stg {
  [CMPDataStorageV1UserDefaults setSubjectToGDPR:stg];
  if (stg == SubjectToGDPR_Yes) {
    [CMPDataStorageV2UserDefaults setGdprApplies:@1];
  } else {
    [CMPDataStorageV2UserDefaults setGdprApplies:@0];
  }

}

+ (void)setRegulationStatus:(NSNumber *)regulationStatus {
  [CMPDataStorageV2UserDefaults setRegulationStatus:regulationStatus];
}

+ (SubjectToGDPR)subjectToGdpr {
  return [CMPDataStorageV1UserDefaults subjectToGDPR];
}

+ (void)setConsentProcessData:(CMPServerResponse *)response {
  [self setRegulationStatus:response.regulation];
  [self setSubjectToGdprByRegulationStatus:response.regulation];
}

+ (void)setSubjectToGdprByRegulationStatus:(NSNumber *)regulationStatus {
  switch ([regulationStatus intValue]) {
    case 0:
    case 2:[CMPSettings setSubjectToGdpr:SubjectToGDPR_No];
      break;
    case 1:[CMPSettings setSubjectToGdpr:SubjectToGDPR_Yes];
      break;
    default:[CMPSettings setSubjectToGdpr:SubjectToGDPR_No];
      break;
  }
}

@end
