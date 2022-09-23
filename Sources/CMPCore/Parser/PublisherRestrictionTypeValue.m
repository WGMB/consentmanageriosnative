//
//  PublisherRestrictionTypeValue.m
//  GDPR
//

#import "PublisherRestrictionTypeValue.h"

@implementation PublisherRestrictionTypeValue

@synthesize restrictionType;
@synthesize vendorIds;

- (id)init:(int)rType vendors:(NSString *)vIds {
  restrictionType = rType;
  vendorIds = vIds;
  return self;
}

- (NSString *)vendorIds {
  return vendorIds;
}

- (int)restrictionType {
  return restrictionType;
}

- (void)setVendorIds:(NSString *)vId {
  vendorIds = vId;
}

- (void)setRestrictionType:(int)rType {
  restrictionType = rType;
}

- (BOOL)hasVendorId:(int)vId {
  if ([vendorIds length] < vId || vId <= 0) {
    return NO;
  }
  if (![[vendorIds substringWithRange:NSMakeRange((vId - 1), 1)] isEqualToString:@"0"]) {
    return YES;
  }
  return NO;
}

- (NSString *)description {
  NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
  [description appendFormat:@"self.restrictionType=%i", self.restrictionType];
  [description appendFormat:@", self.vendorIds=%@", self.vendorIds];
  [description appendString:@">"];
  return description;
}

@end
