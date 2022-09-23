//
//  PublisherRestriction.m
//  GDPR
//

#import "PublisherRestriction.h"

@implementation PublisherRestriction

@synthesize restrictionTypes;
@synthesize purposeId;

- (id)init:(int)pId type:(PublisherRestrictionTypeValue *)rtype {
  purposeId = pId;
  restrictionTypes = [NSMutableArray array];
  [restrictionTypes addObject:rtype];
  return self;
}

- (id)init:(int)pId restrictionTypesString:(NSString *)rtypes {
  purposeId = pId;
  restrictionTypes = [NSMutableArray array];
  for (int i = 1; i <= 3; i++) {
    if ([rtypes containsString:[NSString stringWithFormat:@"%d", i]]) {
      NSString *data = [rtypes copy];
      for (int r = 1; r <= 3; r++) {
        if (r != i) {
          data = [data stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%d", r] withString:@"0"];
        }
      }
      PublisherRestrictionTypeValue *rtv = [[PublisherRestrictionTypeValue alloc] init:i vendors:data];
      [restrictionTypes addObject:rtv];
    }
  }
  return self;
}

- (int)purposeId {
  return purposeId;
}

- (NSArray<PublisherRestrictionTypeValue *> *)restrictionTypes {
  return restrictionTypes;
}

- (void)setPurposeId:(int)pId {
  purposeId = pId;
}

- (void)addRestrictionType:(PublisherRestrictionTypeValue *)rType {
  [restrictionTypes addObject:rType];
}

- (NSString *)getVendorsAsNSUSerDefaultsString {
  NSMutableString *defStr = [[NSMutableString alloc] init];
  int maxlength = 0;
  for (NSUInteger i = 0; i < restrictionTypes.count; i++) {
    if ([restrictionTypes[i].vendorIds length] > maxlength) {
      maxlength = (int) [restrictionTypes[i].vendorIds length];
    }
  }

  for (int v = 1; v <= maxlength; v++) {
    BOOL found = NO;
    for (int i = 0; i < restrictionTypes.count; i++) {
      if ([restrictionTypes[i] hasVendorId:v]) {
        [defStr appendString:[NSString stringWithFormat:@"%d", restrictionTypes[i].restrictionType]];
        found = YES;
        i = (int) restrictionTypes.count;
      }
    }
    if (!found) {
      [defStr appendString:@"0"];
    }
  }

  return defStr;
}

- (BOOL)hasVendor:(int)vendorId {
  for (int i = 0; i < restrictionTypes.count; i++) {
    if ([restrictionTypes[i] hasVendorId:vendorId]) {
      return YES;
    }
  }
  return NO;
}
- (NSString *)description {
  NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
  [description appendFormat:@"self.purposeId=%i", self.purposeId];
  [description appendFormat:@", self.restrictionTypes=%@", self.restrictionTypes];
  [description appendString:@">"];
  return description;
}

@end
