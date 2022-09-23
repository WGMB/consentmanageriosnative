//
//  CMPConsentV2Parser.m
//  GDPR
//

#import "CMPConsentV2Parser.h"
#import "CMPConsentV2Constant.h"
#import "CmpUtils.h"
#import "CMPDataStorageV2UserDefaults.h"
#import "Logger.h"

@implementation CMPConsentV2Parser

@synthesize cmpSdkId;
@synthesize cmpSdkVersion;
@synthesize gdprApplies;
@synthesize purposeOneTreatment;
@synthesize useNoneStandardStacks;
@synthesize publisherCC;
@synthesize vendorConsents;
@synthesize vendorLegitimateInterests;
@synthesize purposeConsents;
@synthesize purposeLegitimateInterests;
@synthesize specialFeaturesOptIns;
@synthesize publisherRestrictions;
@synthesize publisherConsent;
@synthesize publisherLegitimateInterests;
@synthesize publisherCustomPurposesConsent;
@synthesize publisherCustomPurposesLegitimateInterests;
@synthesize policyVersion;
@synthesize cmpAllowedVendors;
@synthesize cmpDisclosedVendors;
@synthesize version;
@synthesize created;
@synthesize lastUpdated;
@synthesize consentScreen;
@synthesize consentLanguage;
@synthesize vendorListVersion;
@synthesize isServiceSpecific;

static NSString *TAG = @"[Cmp]ConsentV2Parser";

- (id)init:(NSString *)consentString {
  NSArray *splits = [consentString componentsSeparatedByString:@"."];

  NSString *coreString = splits[0];
  NSString *disclosedVendors = nil;
  NSString *allowedVendors = nil;
  NSString *publisherTC = nil;

  for (NSUInteger i = 1; i < splits.count; i++) {
    const char *buffer = [CmpUtils binaryConsentFrom:splits[i]];
    if (!buffer) {
      return self;
    }
    NSInteger segmentType =
        [CmpUtils BinaryToDecimal:buffer fromIndex:SEGMENT_TYPE_BIT_OFFSET length:SEGMENT_TYPE_BIT_LENGTH];
    switch (segmentType) {
      case 1:disclosedVendors = splits[i];
        break;
      case 2:allowedVendors = splits[i];
        break;
      case 3:publisherTC = splits[i];
        break;
      default:NSLog(@"Found unrecognisable SegmentType%@", splits[i]);
        break;
    }
  }
  const char *buffer = [CmpUtils binaryConsentFrom:coreString];

  if (!buffer) {
    return self;
  }
  //NSLog(@"BufferString:%s", buffer);
  version = [CmpUtils BinaryToNumber:buffer fromIndex:VERSION_BIT_OFFSET length:VERSION_BIT_LENGTH];
  //NSLog(@"Version:%@", version);
  created = [CmpUtils BinaryToNumber:buffer fromIndex:CREATED_BIT_OFFSET length:CREATED_BIT_LENGTH];
  //NSLog(@"Created:%@", created);
  lastUpdated =
      [CmpUtils BinaryToNumber:buffer fromIndex:LAST_UPDATED_BIT_OFFSET length:LAST_UPDATED_BIT_LENGTH];
  //NSLog(@"Last Updated:%@", lastUpdated);
  cmpSdkId = [CmpUtils BinaryToNumber:buffer fromIndex:CMP_ID_BIT_OFFSET length:CMP_ID_BIT_LENGTH];
  //NSLog(@"CMPSdkId:%@", cmpSdkId);
  cmpSdkVersion =
      [CmpUtils BinaryToNumber:buffer fromIndex:V2_CMP_VERSION_BIT_OFFSET length:V2_CMP_VERSION_BIT_LENGTH];
  //NSLog(@"CMP SDK Version:%@", cmpSdkVersion);
  consentScreen =
      [CmpUtils BinaryToNumber:buffer fromIndex:CONSENT_SCREEN_BIT_OFFSET length:CONSENT_SCREEN_BIT_LENGTH];
  //NSLog(@"consentScreen:%@", consentScreen);
  consentLanguage =
      [CmpUtils BinaryToLanguage:buffer fromIndex:CONSENT_LANGUAGE_BIT_OFFSET length:CONSENT_LANGUAGE_BIT_LENGTH];
  //NSLog(@"consentLanguage:%@", consentLanguage);
  vendorListVersion =
      [CmpUtils BinaryToNumber:buffer fromIndex:VENDOR_LIST_VERSION_BIT_OFFSET length:VENDOR_LIST_VERSION_BIT_LENGTH];
  //NSLog(@"vendorListVersion:%@", vendorListVersion);
  policyVersion =
      [CmpUtils BinaryToNumber:buffer fromIndex:TCF_POLICY_VERSION_BIT_OFFSET length:TCF_POLICY_VERSION_BIT_LENGTH];
  //NSLog(@"policyVersion:%@", policyVersion);
  isServiceSpecific =
      [CmpUtils BinaryToNumber:buffer fromIndex:IS_SERVICE_SPECIFIC_BIT_OFFSET length:IS_SERVICE_SPECIFIC_BIT_LENGTH];
  //NSLog(@"isServiceSpecific:%@", isServiceSpecific);
  useNoneStandardStacks =
      [CmpUtils BinaryToNumber:buffer fromIndex:USE_NON_STANDARD_STACK_BIT_OFFSET length:USE_NON_STANDARD_STACK_BIT_LENGTH];
  //NSLog(@"useNoneStandardStacks:%@", useNoneStandardStacks);
  specialFeaturesOptIns =
      [CmpUtils BinaryToString:buffer fromIndex:SPECIAL_FEATURE_OPT_INS_BIT_OFFSET length:SPECIAL_FEATURE_OPT_INS_BIT_LENGTH];
  //NSLog(@"specialFeaturesOptIns:%@", specialFeaturesOptIns);
  purposeConsents = [CmpUtils BinaryToString:buffer fromIndex:PURPOSE_CONSENT_BIT_OFFSET
                                                length:PURPOSE_CONSENT_BIT_LENGTH];
  //NSLog(@"purposeConsents:%@", purposeConsents);
  purposeLegitimateInterests =
      [CmpUtils BinaryToString:buffer fromIndex:PURPOSE_LI_TRANSPARENCY_BIT_OFFSET length:PURPOSE_LI_TRANSPARENCY_BIT_LENGTH];
  //NSLog(@"purposeLegitimateInterests:%@", purposeLegitimateInterests);
  purposeOneTreatment =
      [CmpUtils BinaryToNumber:buffer fromIndex:PURPOSE_ONE_TREATMENT_BIT_OFFSET length:PURPOSE_ONE_TREATMENT_BIT_LENGTH];
  //NSLog(@"purposeOneTreatment:%@", purposeOneTreatment);
  publisherCC =
      [CmpUtils BinaryToLanguage:buffer fromIndex:PUPBLISHER_CC_BIT_OFFSET length:PUPBLISHER_CC_BIT_LENGTH];
  //NSLog(@"publisherCC:%@", publisherCC);

  NSInteger maxVendor =
      [CmpUtils BinaryToDecimal:buffer fromIndex:MAX_VENDOR_BIT_OFFSET length:MAX_VENDOR_BIT_LENGTH];
  //NSLog(@"maxVendorConsents:%ld", (long)maxVendor);

  NSInteger isRangeEncoded =
      [CmpUtils BinaryToDecimal:buffer fromIndex:MAX_VENDOR_IS_RANGE_ENCODED_BIT_OFFSET length:MAX_VENDOR_IS_RANGE_ENCODED_BIT_LENGTH];
  //NSLog(@"isRangeEncoded:%ld", (long)isRangeEncoded);

  NSInteger offset = MAX_VENDOR_IS_RANGE_ENCODED_BIT_OFFSET + MAX_VENDOR_IS_RANGE_ENCODED_BIT_LENGTH;

  if (isRangeEncoded == 0) {
    vendorConsents = [CmpUtils BinaryToString:buffer fromIndex:(int) offset length:(int) maxVendor];
    offset += maxVendor;
    //NSLog(@"vendorConsents:%@", vendorConsents);
  } else {
    vendorConsents = [CMPConsentV2Parser extractRangeFieldSection:buffer fromIndex:(int) offset offset:&offset];

    //NSLog(@"vendorConsents:%@", vendorConsents);
  }

  maxVendor = [CmpUtils BinaryToDecimal:buffer fromIndex:(int) offset length:MAX_VENDOR_BIT_LENGTH];
  //NSLog(@"maxVendorLegitimateInterests:%ld", (long)maxVendor);
  offset += MAX_VENDOR_BIT_LENGTH;
  isRangeEncoded =
      [CmpUtils BinaryToDecimal:buffer fromIndex:(int) offset length:MAX_VENDOR_IS_RANGE_ENCODED_BIT_LENGTH];
  //NSLog(@"isRangeEncoded:%ld", (long)isRangeEncoded);
  offset += MAX_VENDOR_IS_RANGE_ENCODED_BIT_LENGTH;

  if (isRangeEncoded == 0) {
    vendorLegitimateInterests =
        [CmpUtils BinaryToString:buffer fromIndex:(int) offset length:(int) maxVendor];
    //NSLog(@"vendorLegitimateInterests:%@", vendorLegitimateInterests);
    offset += maxVendor;
  } else {
    vendorLegitimateInterests =
        [CMPConsentV2Parser extractRangeFieldSection:buffer fromIndex:(int) offset offset:&offset];
    //NSLog(@"vendorLegitimateInterests:%@", vendorLegitimateInterests);
  }

  NSInteger numPubRestrictions =
      [CmpUtils BinaryToDecimal:buffer fromIndex:(int) offset length:NUM_PUB_RESTRICTIONS_BIT_LENGTH];
  //NSLog(@"numPubRestrictions:%ld", (long)numPubRestrictions);
  offset += NUM_PUB_RESTRICTIONS_BIT_LENGTH;
  NSMutableArray<PublisherRestriction *> *pRestrictions = [NSMutableArray array];

  for (int i = 0; i < numPubRestrictions; i++) {
    NSInteger
        purposeId = [CmpUtils BinaryToDecimal:buffer fromIndex:(int) offset length:PURPOSE_ID_BIT_LENGTH];
    //NSLog(@"purposeId:%ld", (long)purposeId);
    offset += PURPOSE_ID_BIT_LENGTH;

    NSInteger restrictionType =
        [CmpUtils BinaryToDecimal:buffer fromIndex:(int) offset length:RESTRICTION_TYPE_BIT_LENGTH];
    //NSLog(@"restrictionType:%ld", (long)restrictionType);
    offset += RESTRICTION_TYPE_BIT_LENGTH;
    NSString *vendorIds = [CMPConsentV2Parser extractRangeFieldSection:buffer fromIndex:(int) offset offset:&offset];
    NSLog(@"vendorIds:%@", vendorIds);
    int index = [CMPConsentV2Parser indexOfPurpose:(int) purposeId inArray:pRestrictions];

    PublisherRestrictionTypeValue
        *rtv = [[PublisherRestrictionTypeValue alloc] init:(int) restrictionType vendors:vendorIds];
    if (index < 0) {
      [pRestrictions addObject:[[PublisherRestriction alloc] init:(int) purposeId type:rtv]];
    } else {
      [pRestrictions[(NSUInteger)index] addRestrictionType:rtv];
    }

  }

  publisherRestrictions = pRestrictions;

  if (allowedVendors != nil) {
    const char *bufferAllowedVendors = [CmpUtils binaryConsentFrom:allowedVendors];

    if (!bufferAllowedVendors) {
      return self;
    }
    offset = 3;
    maxVendor = [CmpUtils BinaryToDecimal:bufferAllowedVendors fromIndex:(int) offset length:MAX_VENDOR_BIT_LENGTH];
    offset += MAX_VENDOR_BIT_LENGTH;
    isRangeEncoded =
        [CmpUtils BinaryToDecimal:bufferAllowedVendors fromIndex:(int) offset length:MAX_VENDOR_IS_RANGE_ENCODED_BIT_LENGTH];
    offset += MAX_VENDOR_IS_RANGE_ENCODED_BIT_LENGTH;

    if (isRangeEncoded == 0) {
      cmpAllowedVendors = [CmpUtils BinaryToString:bufferAllowedVendors fromIndex:(int) offset length:(int) maxVendor];
      offset += maxVendor;
    } else {
      cmpAllowedVendors = [CMPConsentV2Parser extractRangeFieldSection:bufferAllowedVendors fromIndex:(int) offset offset:&offset];
    }
  }

  if (disclosedVendors != nil) {
    const char *bufferDisclosedVendors = [CmpUtils binaryConsentFrom:disclosedVendors];

    if (!bufferDisclosedVendors) {
      return self;
    }

    offset = 3;
    maxVendor = [CmpUtils BinaryToDecimal:bufferDisclosedVendors fromIndex:(int) offset length:MAX_VENDOR_BIT_LENGTH];
    offset += MAX_VENDOR_BIT_LENGTH;
    isRangeEncoded =
        [CmpUtils BinaryToDecimal:bufferDisclosedVendors fromIndex:(int) offset length:MAX_VENDOR_IS_RANGE_ENCODED_BIT_LENGTH];
    offset += MAX_VENDOR_IS_RANGE_ENCODED_BIT_LENGTH;

    if (isRangeEncoded == 0) {
      cmpDisclosedVendors = [CmpUtils BinaryToString:bufferDisclosedVendors fromIndex:(int) offset length:(int) maxVendor];
      offset += maxVendor;
    } else {
      cmpDisclosedVendors = [CMPConsentV2Parser extractRangeFieldSection:bufferDisclosedVendors fromIndex:(int) offset offset:&offset];
    }
  }

  if (publisherTC != nil) {
    const char *bufferDisclosedVendors = [CmpUtils binaryConsentFrom:disclosedVendors];

    if (!bufferDisclosedVendors) {
      return self;
    }
    publisherConsent =
        [CmpUtils BinaryToString:bufferDisclosedVendors fromIndex:PUB_PURPOSE_CONSENTS_BIT_OFFSET length:PUB_PURPOSE_CONSENTS_BIT_LENGTH];
    publisherLegitimateInterests =
        [CmpUtils BinaryToString:bufferDisclosedVendors fromIndex:PUB_PURPOSE_LI_TRANSPARENCY_BIT_OFFSET length:PUB_PURPOSE_LI_TRANSPARENCY_BIT_LENGTH];

    NSInteger numCustomPupose =
        [CmpUtils BinaryToDecimal:bufferDisclosedVendors fromIndex:NUM_CUSTOM_PURPOSES_BIT_OFFSET length:NUM_CUSTOM_PURPOSES_BIT_LENGTH];

    int offset = NUM_CUSTOM_PURPOSES_BIT_OFFSET + NUM_CUSTOM_PURPOSES_BIT_LENGTH;
    publisherCustomPurposesConsent =
        [CmpUtils BinaryToString:bufferDisclosedVendors fromIndex:offset length:(int) numCustomPupose];

    offset += numCustomPupose;
    publisherCustomPurposesLegitimateInterests =
        [CmpUtils BinaryToString:bufferDisclosedVendors fromIndex:offset length:(int) numCustomPupose];
  }
  [CMPDataStorageV2UserDefaults setCmpSdkId:cmpSdkId];
  [CMPDataStorageV2UserDefaults setCmpSdkVersion:cmpSdkVersion];
  [CMPDataStorageV2UserDefaults setPurposeOneTreatment:purposeOneTreatment];
  [CMPDataStorageV2UserDefaults setUseNoneStandardStacks:useNoneStandardStacks];
  [CMPDataStorageV2UserDefaults setPublisherCC:publisherCC];
  [CMPDataStorageV2UserDefaults setVendorConsents:vendorConsents];
  [CMPDataStorageV2UserDefaults setVendorLegitimateInterests:vendorLegitimateInterests];
  [CMPDataStorageV2UserDefaults setPurposeConsents:purposeConsents];
  [CMPDataStorageV2UserDefaults setPurposeLegitimateInterests:purposeLegitimateInterests];
  [CMPDataStorageV2UserDefaults setSpecialFeaturesOptIns:specialFeaturesOptIns];
  [CMPDataStorageV2UserDefaults setPublisherRestrictions:publisherRestrictions];
  [CMPDataStorageV2UserDefaults setPublisherConsent:publisherConsent];
  [CMPDataStorageV2UserDefaults setPurposeLegitimateInterests:purposeLegitimateInterests];
  [CMPDataStorageV2UserDefaults setPublisherCustomPurposesConsent:publisherCustomPurposesConsent];
  [CMPDataStorageV2UserDefaults setPublisherCustomPurposesLegitimateInterests:publisherCustomPurposesLegitimateInterests];
  [CMPDataStorageV2UserDefaults setPolicyVersion:policyVersion];
  [Logger debug:TAG :[NSString stringWithFormat:@"%@",self.description]];
  return self;
}

+ (int)indexOfPurpose:(int)purposeId inArray:(NSArray<PublisherRestriction *> *)prArray {
  for (int i = 0; i < prArray.count; i++) {
    if ([prArray[i] purposeId] == purposeId) {
      return i;
    }
  }
  return -1;
}

+ (NSString *)extractRangeFieldSection:(const char *)buffer fromIndex:(int)startIndex offset:(NSInteger *)offset {

  NSInteger
      entries = [CmpUtils BinaryToDecimal:buffer fromIndex:(int) startIndex length:RANGE_ENTRIES_BIT_LENGTH];
  startIndex += RANGE_ENTRIES_BIT_LENGTH;
  //NSLog(@"Range Entries:%ld", (long)entries);
  NSMutableString *value = [NSMutableString new];
  for (int i = 0; i < entries; i++) {
    NSInteger isARange = [CmpUtils BinaryToDecimal:buffer fromIndex:(int) startIndex length:1];
    startIndex += 1;
    NSInteger startOrOnlyVendorId = [CmpUtils BinaryToDecimal:buffer fromIndex:(int) startIndex length:16];
    //NSLog(@"startOrOnlyVendorId:%ld", (long)startOrOnlyVendorId);
    startIndex += 16;
    if (isARange == 1) {
      NSInteger endVendorId = [CmpUtils BinaryToDecimal:buffer fromIndex:(int) startIndex length:16];
      //NSLog(@"endVendorId:%ld", (long)endVendorId);
      //Its possible to catch Errors in Consent String here
      startIndex += 16;
      [value appendString:[CMPConsentV2Parser getBitRangeExtension:value fromIndex:(int) startOrOnlyVendorId toIndex:(int) endVendorId]];

    } else {
      [value appendString:[CMPConsentV2Parser getBitExtension:value toIndex:(int) startOrOnlyVendorId]];
    }
  }
  *offset = startIndex;

  return value;
}

+ (NSString *)getBitExtension:(NSMutableString *)value toIndex:(int)toIndex {
  NSMutableString *extract = [NSMutableString new];
  int characterCount = (int) [value length];
  for (int i = characterCount; i < toIndex - 1; i++) {
    [extract appendString:@"0"];
  }
  [extract appendString:@"1"];
  return extract;
}

+ (NSString *)getBitRangeExtension:(NSMutableString *)value fromIndex:(int)fromIndex toIndex:(int)toIndex {

  NSMutableString *extract = [NSMutableString new];
  if ([value length] <= fromIndex) {
    [extract appendString:[CMPConsentV2Parser getBitExtension:value toIndex:(int) fromIndex]];
  }

  for (int i = fromIndex; i <= toIndex; i++) {
    [extract appendString:@"1"];
  }

  if ([value length] <= fromIndex) {
    return extract;
  }
  return [CMPConsentV2Parser placeBitExtension:extract into:value atIndex:(int) fromIndex];
}

+ (NSString *)placeBitExtension:(NSString *)extract into:(NSMutableString *)value atIndex:(int)atIndex {
  [value replaceCharactersInRange:NSMakeRange(atIndex, [extract length]) withString:extract];
  return value;
}

- (NSNumber *)cmpSdkId {
  return cmpSdkId;
}

- (NSNumber *)cmpSdkVersion {
  return cmpSdkVersion;
}

- (NSNumber *)gdprApplies {
  return gdprApplies;
}

- (NSNumber *)purposeOneTreatment {
  return purposeOneTreatment;
}

- (NSNumber *)useNoneStandardStacks {
  return useNoneStandardStacks;
}

- (NSString *)publisherCC {
  return publisherCC;
}

- (NSString *)vendorConsents {
  return vendorConsents;
}

- (NSString *)vendorLegitimateInterests {
  return vendorLegitimateInterests;
}

- (NSString *)purposeConsents {
  return purposeConsents;
}

- (NSString *)purposeLegitimateInterests {
  return purposeLegitimateInterests;
}

- (NSString *)specialFeaturesOptIns {
  return specialFeaturesOptIns;
}

- (NSArray<PublisherRestriction *> *)publisherRestrictions {
  return publisherRestrictions;
}

- (NSString *)publisherConsent {
  return publisherConsent;
}

- (NSString *)puplisherLegitimateInterests {
  return publisherLegitimateInterests;
}

- (NSString *)publisherCustomPurposesConsent {
  return publisherCustomPurposesConsent;
}

- (NSString *)publisherCustomPurposesLegitimateInterests {
  return publisherCustomPurposesLegitimateInterests;
}

- (NSNumber *)policyVersion {
  return policyVersion;
}

- (NSString *)cmpAllowedVendors {
  return cmpAllowedVendors;
}

- (NSString *)cmpDisclosedVendors {
  return cmpDisclosedVendors;
}

- (NSNumber *)version {
  return version;
}

- (NSNumber *)created {
  return created;
}

- (NSNumber *)lastUpdated {
  return lastUpdated;
}

- (NSNumber *)consentScreen {
  return consentScreen;
}

- (NSString *)consentLanguage {
  return consentLanguage;
}

- (NSNumber *)vendorListVersion {
  return vendorListVersion;
}

- (NSNumber *)isServiceSpecific {
  return isServiceSpecific;
}

- (NSString *)description {
  NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
  [description appendFormat:@"self.cmpSdkId=%@", self.cmpSdkId];
  [description appendFormat:@", self.cmpSdkVersion=%@", self.cmpSdkVersion];
  [description appendFormat:@", self.gdprApplies=%@", self.gdprApplies];
  [description appendFormat:@", self.purposeOneTreatment=%@", self.purposeOneTreatment];
  [description appendFormat:@", self.useNoneStandardStacks=%@", self.useNoneStandardStacks];
  [description appendFormat:@", self.publisherCC=%@", self.publisherCC];
  [description appendFormat:@", self.vendorConsents=%@", self.vendorConsents];
  [description appendFormat:@", self.vendorLegitimateInterests=%@", self.vendorLegitimateInterests];
  [description appendFormat:@", self.purposeConsents=%@", self.purposeConsents];
  [description appendFormat:@", self.purposeLegitimateInterests=%@", self.purposeLegitimateInterests];
  [description appendFormat:@", self.specialFeaturesOptIns=%@", self.specialFeaturesOptIns];
  [description appendFormat:@", self.publisherRestrictions=%@", self.publisherRestrictions];
  [description appendFormat:@", self.publisherConsent=%@", self.publisherConsent];
  [description appendFormat:@", self.publisherLegitimateInterests=%@", self.publisherLegitimateInterests];
  [description appendFormat:@", self.publisherCustomPurposesConsent=%@", self.publisherCustomPurposesConsent];
  [description appendFormat:@", self.publisherCustomPurposesLegitimateInterests=%@", self.publisherCustomPurposesLegitimateInterests];
  [description appendFormat:@", self.cmpDisclosedVendors=%@", self.cmpDisclosedVendors];
  [description appendFormat:@", self.cmpAllowedVendors=%@", self.cmpAllowedVendors];
  [description appendFormat:@", self.version=%@", self.version];
  [description appendFormat:@", self.created=%@", self.created];
  [description appendFormat:@", self.lastUpdated=%@", self.lastUpdated];
  [description appendFormat:@", self.consentScreen=%@", self.consentScreen];
  [description appendFormat:@", self.consentLanguage=%@", self.consentLanguage];
  [description appendFormat:@", self.vendorListVersion=%@", self.vendorListVersion];
  [description appendFormat:@", self.isServiceSpecific=%@", self.isServiceSpecific];
  [description appendFormat:@", self.policyVersion=%@", self.policyVersion];
  [description appendString:@">"];
  return description;
}

@end
