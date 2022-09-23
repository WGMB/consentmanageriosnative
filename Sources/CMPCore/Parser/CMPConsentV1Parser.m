//
//  CMPConsentV1Parser.m
//  GDPR
//

#import "CMPConsentV1Parser.h"
#import "CMPConsentV1Constant.h"
#import "CmpUtils.h"

@implementation CMPConsentV1Parser

+ (NSString *)parseVendorConsentsFrom:(NSString *)consentString {
  const char *buffer = [CmpUtils binaryConsentFrom:consentString];

  if (!buffer) {
    return nil;
  }

  NSMutableString *vendorConsentString = [NSMutableString new];
  NSInteger maxVendorId =
      [CmpUtils BinaryToDecimal:buffer fromIndex:V1_MAX_VENDOR_ID_BIT_OFFSET length:V1_MAX_VENDOR_ID_BIT_LENGTH];
  if (buffer[V1_ENCODING_TYPE_BIT] == '0') {
    for (int i = 1; i <= (int) maxVendorId; i++) {
      [vendorConsentString appendString:[NSString stringWithFormat:@"%c", buffer[V1_ENCODING_TYPE_BIT + i]]];
    }
  } else {
    NSInteger numEntries =
        [CmpUtils BinaryToDecimal:buffer fromIndex:V1_NUM_ENTRIES_BIT_OFFSET length:V1_NUM_ENTRIES_BIT_LENGTH];
    NSMutableArray *vendorConsentIds = [NSMutableArray new];

    int singleOrRangeStartIndex = V1_NUM_ENTRIES_BIT_OFFSET + V1_NUM_ENTRIES_BIT_LENGTH;
    for (int i = 0; i < (int) numEntries; i++) {
      if (buffer[singleOrRangeStartIndex] == '0') {
        NSInteger singleVendorId = [CmpUtils BinaryToDecimal:buffer fromIndex:singleOrRangeStartIndex
            + 1                                                 length:V1_SINGLE_VENDOR_ID_BIT_LENGTH];
        [vendorConsentIds addObject:@(singleVendorId)];
        singleOrRangeStartIndex += (V1_SINGLE_VENDOR_ID_BIT_LENGTH + 1);
      } else {
        NSInteger startVendorId = [CmpUtils BinaryToDecimal:buffer fromIndex:singleOrRangeStartIndex
            + 1                                                length:V1_START_VENDOR_ID_BIT_LENGTH];
        NSInteger endVendorId =
            [CmpUtils BinaryToDecimal:buffer fromIndex:singleOrRangeStartIndex + V1_START_VENDOR_ID_BIT_LENGTH
                + 1                      length:V1_END_VENDOR_ID_BIT_LENGTH];
        singleOrRangeStartIndex += (V1_START_VENDOR_ID_BIT_LENGTH + V1_END_VENDOR_ID_BIT_LENGTH + 1);
        for (int i = (int) startVendorId; i <= (int) endVendorId; i++) {
          [vendorConsentIds addObject:@(i)];
        }
      }
    }

    for (int i = 1; i <= (int) maxVendorId; i++) {
      if ([vendorConsentIds containsObject:@(i)]) {
        [vendorConsentString appendString:buffer[V1_DEFAULT_CONSENT_BIT] == '0' ? @"1" : @"0"];
      } else {
        [vendorConsentString appendString:buffer[V1_DEFAULT_CONSENT_BIT] == '0' ? @"0" : @"1"];
      }
    }
  }
  free((void *)buffer);
  return vendorConsentString;
}

+ (NSString *)parsePurposeConsentsFrom:(NSString *)consentString {
  const char *buffer = [CmpUtils binaryConsentFrom:consentString];

  if (!buffer) {
    return nil;
  }

  NSMutableString *purposeConsentString = [NSMutableString new];
  for (int i = 1; i <= V1_PURPOSES_ALLOWED_BIT_LENGTH; i++) {
    [purposeConsentString appendString:[[self class] isPurposeAllowedForBinary:buffer atBitPosition:i - 1]];
  }
  free((void *)buffer);
  return purposeConsentString;
}

+ (NSString *)isPurposeAllowedForBinary:(const char *)buffer atBitPosition:(NSInteger)bitPosition {
  const NSInteger purposeStartBit = V1_PURPOSES_ALLOWED_BIT_OFFSET;

  size_t binaryLength = (int) strlen((const char *) buffer);
  NSInteger purposeId = purposeStartBit + bitPosition;

  if (binaryLength <= purposeId || purposeId > purposeStartBit + V1_PURPOSES_ALLOWED_BIT_LENGTH) {
    return @"0";
  }

  return buffer[purposeId] == '1' ? @"1" : @"0";
}

@end
