//
// Created by Skander Ben Abdelmalak on 30.11.21.
//

#import "CmpConsentDto.h"
#import "Logger.h"

@implementation CmpConsentDto {
}
static NSString *TAG = @"[Cmp]ConsentDto";

#pragma mark constructors

+ (CmpConsentDto *)fromJSON:(NSDictionary *)jsonData {
  CmpConsentDto *user_consent = [[CmpConsentDto alloc] init];
  NSArray *purposeList = [jsonData[@"purposeConsents"] allKeys];
  NSArray *vendorList = [jsonData[@"vendorConsents"] allKeys];
  NSArray *googleVendorList = [jsonData[@"googleVendorConsents"] allKeys];

  user_consent.cmpApiKey = jsonData[@"cmpApiKey"];
  user_consent.consentString = jsonData[@"consentstring"];
  user_consent.gdprApplies = (BOOL)jsonData[@"gdprApplies"];
  user_consent.regulation = jsonData[@"regulation"];
  user_consent.regulationKey = jsonData[@"regulationKey"];
  user_consent.tcfCompliant = (BOOL)jsonData[@"tcfcompliant"];
  user_consent.tcfVersion = jsonData[@"tcfversion"];
  user_consent.uspString = jsonData[@"uspstring"];
  user_consent.googleVendorList = googleVendorList;
  user_consent.purposeConsentList = [jsonData[@"purposeConsents"] allKeys];
  user_consent.purposeList = purposeList;
  user_consent.vendorList = vendorList;
  user_consent.hasGlobalScope = (BOOL)jsonData[@"hasGlobalScope"];

  if (![CmpConsentDto isValid:user_consent]) {
	NSLog(@"%@:error during instantiating Consent Data from Json, Consent not valid: %@", TAG, user_consent.cmpApiKey);
  }

  return user_consent;
}

// check more constructors, which apply to business logic.


#pragma mark getter and business Logic

// check other business logic maybe also just internally logic for adding just one vendor etc.
// would like be .. addVendor
// inside of service addVendor Method which gets CmpUserConsent Object from repository
// then calling addVendor and then saving it back to repository
// improved performance if there would be predefined saving cases, like just save vendors to the new value
// CmpUserConsent would just be the data transfer
// service need to handle instantiation of Dto for different cases and command repository what it needs to do.

- (BOOL)hasVendor:(NSString *)vendor {
  if ([_regulation isEqualToNumber:@0]) {
	return YES;
  }
  [Logger debug:TAG :[NSString stringWithFormat:@"Check for vendor %@ on List: %@", vendor, _vendorList]];
  return [_vendorList containsObject:vendor] ? YES : NO;
}

- (BOOL)hasPurpose:(NSString *)purpose {
  if ([_regulation isEqualToNumber:@0]) {
	return YES;
  }
  [Logger debug:TAG :[NSString stringWithFormat:@"Check for purpose %@ on List:", _purposeList]];
  return [_purposeList containsObject:purpose] ? YES : NO;
}

- (NSArray *)getVendorList {
  return _vendorList;
}

- (NSArray *)getPurposeList {
  return _purposeList;
}

- (NSArray *)getGoogleVendorList {
  return _googleVendorList;
}

- (NSString *)getUsPrivacy {
  return _uspString;
}

# pragma mark Logging

- (NSString *)description {
  NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
  [description appendFormat:@"  self.cmpApiKey=%@", _cmpApiKey];
  [description appendFormat:@"  self.consentString=%@", _consentString];
  [description appendFormat:@", self.regulation=%@", _regulation];
  [description appendFormat:@", self.gdprApplies=%d", _gdprApplies];
  [description appendFormat:@", self.regulationKey=%@", _regulationKey];
  [description appendFormat:@", self.tcfVersion=%@", _tcfVersion];
  [description appendFormat:@", self.tcfCompliant=%d", _tcfCompliant];
  [description appendFormat:@", self.uspString=%@", _uspString];
  [description appendFormat:@", self.googleVendorList=%@", [_googleVendorList componentsJoinedByString:@","]];
  [description appendFormat:@", self.purposeConsentList=%@", [_purposeConsentList componentsJoinedByString:@","]];
  [description appendFormat:@", self.purposeList=%@", [_purposeList componentsJoinedByString:@","]];
  [description appendFormat:@", self.vendorList=%@", [_vendorList componentsJoinedByString:@","]];
  [description appendFormat:@", self.hasGlobalScope=%d", _hasGlobalScope];
  [description appendString:@">"];
  return description;
}

+ (bool)isValid:(CmpConsentDto *)dto {

  if (dto == NULL) return NO;

  if ([dto.cmpApiKey isEqualToString:@""] || dto.cmpApiKey == NULL || [dto.cmpApiKey isEqualToString:@"nil"]
	  || [dto.cmpApiKey isEqualToString:@"null"]) {
	return NO;
  }

  if ([dto.consentString isEqualToString:@""] || dto.consentString == NULL || [dto.consentString isEqualToString:@"nil"]
	  || [dto.consentString isEqualToString:@"null"]) {
	return NO;
  }

  return YES;
}

#pragma mark Decoding/Encoding

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:self.cmpApiKey forKey:@"cmpApiKey"];
  [encoder encodeObject:self.consentString forKey:@"consentString"];
  [encoder encodeObject:self.regulation forKey:@"regulation"];
  [encoder encodeObject:self.regulationKey forKey:@"regulationKey"];
  [encoder encodeObject:@(self.gdprApplies) forKey:@"gdprApplies"];
  [encoder encodeObject:self.tcfVersion forKey:@"tcfVersion"];
  [encoder encodeObject:@(self.tcfCompliant) forKey:@"tcfCompliant"];
  [encoder encodeObject:self.uspString forKey:@"uspString"];
  [encoder encodeObject:self.googleVendorList forKey:@"googleVendorList"];
  [encoder encodeObject:self.purposeConsentList forKey:@"purposeConsentList"];
  [encoder encodeObject:self.purposeList forKey:@"purposeList"];
  [encoder encodeObject:self.vendorList forKey:@"vendorList"];
  [encoder encodeObject:@(self.hasGlobalScope) forKey:@"hasGlobalScope"];

}

- (id)initWithCoder:(NSCoder *)decoder {
  if ((self = [super init])) {
	//decode properties, other class vars
	self.cmpApiKey = [decoder decodeObjectForKey:@"cmpApiKey"];
	self.consentString = [decoder decodeObjectForKey:@"consentString"];
	self.regulation = [decoder decodeObjectForKey:@"regulation"];
	self.regulationKey = [decoder decodeObjectForKey:@"regulationKey"];
	self.gdprApplies = [[decoder decodeObjectForKey:@"gdprApplies"] boolValue];
	self.tcfVersion = [decoder decodeObjectOfClass:[NSNumber class] forKey:@"tcfVersion"];
	self.tcfCompliant = [[decoder decodeObjectForKey:@"tcfCompliant"] boolValue];
	self.uspString = [decoder decodeObjectForKey:@"uspString"];
	self.googleVendorList = [decoder decodeObjectForKey:@"googleVendorList"];
	self.purposeConsentList = [decoder decodeObjectForKey:@"purposeConsentList"];
	self.purposeList = [decoder decodeObjectForKey:@"purposeList"];
	self.vendorList = [decoder decodeObjectForKey:@"vendorList"];
	self.hasGlobalScope = [[decoder decodeObjectForKey:@"hasGlobalScope"] boolValue];
  }

  if (![CmpConsentDto isValid:self]) {
	NSLog(@"%@:error during instantiating Consent Data from User defaults, Consent not valid: %@", TAG, self.cmpApiKey);
  }

  return self;
}

+ (BOOL)supportsSecureCoding {
  return YES;
}
@end
