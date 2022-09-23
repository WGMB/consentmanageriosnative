//
// Created by Skander Ben Abdelmalak on 18.11.21.
//

/*! Class to wrap query parameters for placeholder Api call */
#import "CmpPlaceholderParams.h"
#import "CmpConfig.h"

NSString *const apiURL = @"https://%@/delivery/apppreview.php?id=%@&vendor=%@";

@implementation CmpPlaceholderParams

- (instancetype)initWithVendorId:(NSString *)vendorId {
  self = [super init];
  if (self) {
	self.vendorId = vendorId;
  }

  return self;
}

+ (instancetype)paramsWithVendorId:(NSString *)vendorId {
  return [[self alloc] initWithVendorId:vendorId];
}

- (void)setCustomPlaceholderText:(NSString *)headline :(NSString *)text :(NSString *)buttonText :(NSString *)checkboxText {
  _headline = headline;
  _text = text;
  _buttonText = buttonText;
  _checkboxText = checkboxText;
}

/**
 * @brief get Request URL
 * @param consent consentString
 * @return URL Parameter
 */
- (NSURL *)getRequestURL:(NSString *)consent {
  NSMutableString *urlAsString =
	  [NSMutableString stringWithFormat:apiURL, [CmpConfig consentToolDomain], [CmpConfig consentToolId], _vendorId];

  // Setting Optional Parameter
  if (_buttonText != nil) {
	[urlAsString appendString:[NSString stringWithFormat:@"&btn=%@", _buttonText]];
  }
  if (_checkboxText != nil) {
	[urlAsString appendString:[NSString stringWithFormat:@"&check=%@", _buttonText]];
  }
  if (_text != nil) {
	[urlAsString appendString:[NSString stringWithFormat:@"&txt=%@", _buttonText]];
  }
  if (_headline != nil) {
	[urlAsString appendString:[NSString stringWithFormat:@"&hl=%@", _buttonText]];
  }
  if (_imageUrl != nil) {
	[urlAsString appendString:[NSString stringWithFormat:@"&img=%@", _imageUrl]];
  }
  return [NSURL URLWithString:urlAsString];
}

@end
