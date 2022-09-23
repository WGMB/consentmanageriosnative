//
//  CMPDataStorageV2UserDefaults.m
//  GDPR
//

#import "CMPDataStorageV2UserDefaults.h"

NSString *const CMP_SDK_ID = @"IABTCF_CmpSdkID";
NSString *const CMP_SDK_VERSION = @"IABTCF_CmpSdkVersion";
NSString *const POLICY_VERSION = @"IABTCF_PolicyVersion";
NSString *const GDPR_APPLIES = @"IABTCF_gdprApplies";
NSString *const PUBLISHER_CC = @"IABTCF_PublisherCC";
NSString *const TC_STRING = @"IABTCF_TCString";
NSString *const VENDOR_CONSENTS = @"IABTCF_VendorConsents";
NSString *const VENDOR_LEGITIMATE_INTERESTS = @"IABTCF_VendorLegitimateInterests";
NSString *const PURPOSE_CONSENTS = @"IABTCF_PurposeConsents";
NSString *const PURPOSE_LEGITIMATE_INTERESTS = @"IABTCF_PurposeLegitimateInterests";
NSString *const SPECIAL_FEATURES_OPT_INS = @"IABTCF_SpecialFeaturesOptIns";
NSString *const PUBLISHER_RESTRICTIONS = @"IABTCF_PublisherRestrictions%d"; // %d = Purpose ID
NSString *const PUBLISHER_CONSENT = @"IABTCF_PublisherConsent";
NSString *const PUBLISHER_LEGITIMATE_INTERESTS = @"IABTCF_PublisherLegitimateInterests";
NSString *const PUBLISHER_CUSTOM_PURPOSES_CONSENTS = @"IABTCF_PublisherCustomPurposesConsents";
NSString *const PUBLISHER_CUSTOM_PURPOSES_LEGITIMATE_INTERESTS = @"IABTCF_PublisherCustomPurposesLegitimateInterests";
NSString *const PURPOSE_ONE_TREATMENT = @"IABTCF_PurposeOneTreatment";
NSString *const USE_NONE_STANDARD_STACKS = @"IABTCF_UseNoneStandardStacks";

NSString *const CMP_REGULATION_STATUS = @"IABTCF_RegulationStatus";

@implementation CMPDataStorageV2UserDefaults

static NSUserDefaults *userDefaults = nil;

+ (NSNumber *)cmpSdkId {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return @((int)[userDefaults integerForKey:CMP_SDK_ID]);
}

+ (void)setCmpSdkId:(NSNumber *)cmpSdkId {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setInteger:[cmpSdkId intValue] forKey:CMP_SDK_ID];
  [userDefaults synchronize];
}

+ (NSNumber *)cmpSdkVersion {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return @((int)[userDefaults integerForKey:CMP_SDK_VERSION]);
}

+ (void)setCmpSdkVersion:(NSNumber *)cmpSdkVersion {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setInteger:[cmpSdkVersion intValue] forKey:CMP_SDK_VERSION];
  [userDefaults synchronize];
}

+ (NSNumber *)policyVersion {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return @((int)[userDefaults integerForKey:POLICY_VERSION]);
}

+ (void)setPolicyVersion:(NSNumber *)policyVersion {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setInteger:[policyVersion intValue] forKey:POLICY_VERSION];
  [userDefaults synchronize];
}

+ (NSNumber *)gdprApplies {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return @((int)[userDefaults integerForKey:GDPR_APPLIES]);
}

+ (void)setGdprApplies:(NSNumber *)gdprApplies {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setInteger:[gdprApplies intValue] forKey:GDPR_APPLIES];
  [userDefaults synchronize];
}

+ (NSString *)publisherCC {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:PUBLISHER_CC];
}

+ (void)setPublisherCC:(NSString *)publisherCC {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:publisherCC forKey:PUBLISHER_CC];
  [userDefaults synchronize];
}

+ (NSString *)tcString {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:TC_STRING];
}

+ (void)setTcString:(NSString *)tcString {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:tcString forKey:TC_STRING];
  [userDefaults synchronize];
}

+ (NSString *)vendorConsents {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:VENDOR_CONSENTS];
}

+ (void)setVendorConsents:(NSString *)vendorConsents {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:vendorConsents forKey:VENDOR_CONSENTS];
  [userDefaults synchronize];
}

+ (NSString *)vendorLegitimateInterests {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:VENDOR_LEGITIMATE_INTERESTS];
}

+ (void)setVendorLegitimateInterests:(NSString *)vendorLegitimateInterests {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:vendorLegitimateInterests forKey:VENDOR_LEGITIMATE_INTERESTS];
  [userDefaults synchronize];
}

+ (NSString *)purposeConsents {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:PURPOSE_CONSENTS];
}

+ (void)setPurposeConsents:(NSString *)purposeConsents {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:purposeConsents forKey:PURPOSE_CONSENTS];
  [userDefaults synchronize];
}

+ (NSString *)purposeLegitimateInterests {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:PURPOSE_LEGITIMATE_INTERESTS];
}

+ (void)setPurposeLegitimateInterests:(NSString *)purposeLegitimateInterests {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:purposeLegitimateInterests forKey:PURPOSE_LEGITIMATE_INTERESTS];
  [userDefaults synchronize];
}

+ (NSString *)specialFeaturesOptIns {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:SPECIAL_FEATURES_OPT_INS];
}

+ (void)setSpecialFeaturesOptIns:(NSString *)specialFeaturesOptIns {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:specialFeaturesOptIns forKey:SPECIAL_FEATURES_OPT_INS];
  [userDefaults synchronize];
}

+ (NSArray<PublisherRestriction *> *)publisherRestrictions {
  int i = 0;
  NSMutableArray *pRestrictions = [NSMutableArray array];
  while ([self publisherRestriction:@(i)]) {

    [pRestrictions addObject:[CMPDataStorageV2UserDefaults publisherRestriction:@(i)]];
    i++;
  }

  return pRestrictions;
}

+ (void)setPublisherRestrictions:(NSArray<PublisherRestriction *> *)publisherRestrictions {
  for (NSUInteger i = 0; i < publisherRestrictions.count; i++) {
    self.publisherRestriction = publisherRestrictions[i];
  }
}

+ (PublisherRestriction *)publisherRestriction:(NSNumber *)purposeId {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  NSString *key = [NSString stringWithFormat:PUBLISHER_RESTRICTIONS, [purposeId intValue]];
  NSString *cmpString = [userDefaults stringForKey:key];
  return [[PublisherRestriction alloc] init:[purposeId intValue] restrictionTypesString:cmpString];
}

+ (void)setPublisherRestriction:(PublisherRestriction *)publisherRestriction {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  NSString *value = [publisherRestriction getVendorsAsNSUSerDefaultsString];
  NSString *key = [NSString stringWithFormat:PUBLISHER_RESTRICTIONS, (int) [publisherRestriction purposeId]];
  [userDefaults setObject:value forKey:key];
  [userDefaults synchronize];
}

+ (NSString *)publisherConsent {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:PUBLISHER_CONSENT];
}

+ (void)setPublisherConsent:(NSString *)publisherConsent {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:publisherConsent forKey:PUBLISHER_CONSENT];
  [userDefaults synchronize];
}

+ (NSString *)publisherLegitimateInterests {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:PUBLISHER_LEGITIMATE_INTERESTS];
}

+ (void)setPublisherLegitimateInterests:(NSString *)publisherLegitimateInterests {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:publisherLegitimateInterests forKey:PUBLISHER_LEGITIMATE_INTERESTS];
  [userDefaults synchronize];
}

+ (NSString *)publisherCustomPurposesConsent {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:PUBLISHER_CUSTOM_PURPOSES_CONSENTS];
}

+ (void)setPublisherCustomPurposesConsent:(NSString *)publisherCustomPurposesConsent {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:publisherCustomPurposesConsent forKey:PUBLISHER_CUSTOM_PURPOSES_CONSENTS];
  [userDefaults synchronize];
}

+ (NSString *)publisherCustomPurposesLegitimateInterests {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return [userDefaults stringForKey:PUBLISHER_CUSTOM_PURPOSES_LEGITIMATE_INTERESTS];
}

+ (void)setPublisherCustomPurposesLegitimateInterests:(NSString *)publisherCustomPurposesLegitimateInterests {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setObject:publisherCustomPurposesLegitimateInterests forKey:PUBLISHER_CUSTOM_PURPOSES_LEGITIMATE_INTERESTS];
  [userDefaults synchronize];
}

+ (NSNumber *)purposeOneTreatment {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return @((int)[userDefaults integerForKey:PURPOSE_ONE_TREATMENT]);
}

+ (void)setPurposeOneTreatment:(NSNumber *)purposeOneTreatment {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setInteger:[purposeOneTreatment intValue] forKey:PURPOSE_ONE_TREATMENT];
  [userDefaults synchronize];
}

+ (NSNumber *)useNoneStandardStacks {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return @((int)[userDefaults integerForKey:USE_NONE_STANDARD_STACKS]);
}

+ (void)setUseNoneStandardStacks:(NSNumber *)useNoneStandardStacks {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setInteger:[useNoneStandardStacks intValue] forKey:USE_NONE_STANDARD_STACKS];
  [userDefaults synchronize];
}

+ (NSNumber *)regulationStatus {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  return @((int)[userDefaults integerForKey:CMP_REGULATION_STATUS]);
}

+ (void)setRegulationStatus:(NSNumber *)regulationStatus {
  NSUserDefaults *userDefaults = [self getUserDefaults];
  [userDefaults setInteger:[regulationStatus intValue] forKey:CMP_REGULATION_STATUS];
  [userDefaults synchronize];
}

+ (void)clearContents {
  NSLog(@"cleaning the userDefaults V2");
  [self setCmpSdkId:@0];
  [self setCmpSdkVersion:@0];
  [self setPolicyVersion:@0];
  [self setGdprApplies:@0];
  [self setPublisherCC:@""];
  [self setTcString:@""];
  [self setVendorConsents:@""];
  [self setVendorLegitimateInterests:@""];
  [self setPurposeConsents:@""];
  [self setPurposeLegitimateInterests:@""];
  [self setSpecialFeaturesOptIns:@""];
  [self setPublisherRestrictions:[NSArray array]];
  [self setPublisherConsent:@""];
  [self setPublisherLegitimateInterests:@""];
  [self setPublisherCustomPurposesConsent:@""];
  [self setPublisherCustomPurposesLegitimateInterests:@""];
  [self setPurposeOneTreatment:@0];
  [self setUseNoneStandardStacks:@0];
  [self setRegulationStatus:@0];
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
                                    "%@: %@,"
                                    "%@: %@,"
                                    "%@: %@,"
                                    "%@: %@,"
                                    "%@: %@,"
                                    "%@: %@,"
                                    "%@: %@,"
                                    "%@: %@,"
                                    "%@: %@,"
                                    "%@: %@,"
                                    "%@: %@,"
                                    "%@: %@,"
                                    "%@: %@,"
                                    //"%@: %@,"
									"}",
          CMP_SDK_ID, self.cmpSdkId,
          CMP_SDK_VERSION, self.cmpSdkId,
          POLICY_VERSION, self.policyVersion,
          GDPR_APPLIES, self.gdprApplies,
          PUBLISHER_CC, self.publisherCC,
          TC_STRING, self.tcString,
          VENDOR_CONSENTS, self.vendorConsents,
          VENDOR_LEGITIMATE_INTERESTS,self.vendorLegitimateInterests,
          PURPOSE_CONSENTS,self.purposeConsents,
          PURPOSE_LEGITIMATE_INTERESTS,self.purposeLegitimateInterests,
          SPECIAL_FEATURES_OPT_INS,self.specialFeaturesOptIns,
         // PUBLISHER_RESTRICTIONS, [self.publisherRestrictions componentsJoinedByString:@","],
          PUBLISHER_CONSENT,self.publisherConsent,
          PUBLISHER_LEGITIMATE_INTERESTS, self.publisherLegitimateInterests,
          PUBLISHER_CUSTOM_PURPOSES_CONSENTS, self.publisherCustomPurposesConsent,
          PUBLISHER_CUSTOM_PURPOSES_LEGITIMATE_INTERESTS, self.publisherCustomPurposesLegitimateInterests,
          PURPOSE_ONE_TREATMENT, self.purposeOneTreatment,
          USE_NONE_STANDARD_STACKS, self.useNoneStandardStacks,
          CMP_REGULATION_STATUS, self.regulationStatus];
}

@end
