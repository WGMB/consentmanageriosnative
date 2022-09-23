//
//  CmpUtils.m
//  GDPR
//

#import "CmpUtils.h"
#import "CmpReachability.h"
#import "CMPDataStoragePrivateUserDefaults.h"
#import "CMPSettings.h"
#import "Logger.h"

NSString *const RESPONSE_MESSAGE_KEY = @"message";
NSString *const RESPONSE_STATUS_KEY = @"status";
NSString *const RESPONSE_REGULATION_KEY = @"regulation";
NSString *CMP_URL_PATTERN = @"https://%@/delivery/appcmp2.php?id=%@&appname=%@&l=%@&idfa=%@&cmpatt=%d";
NSString *const TAG = @"[CMP]Utils";
@implementation CmpUtils

+ (const char *)NSDataToBinary:(NSData *)decodedData {
  const char *byte = [decodedData bytes];
  NSUInteger length = [decodedData length];
  unsigned long bufferLength = decodedData.length*8 - 1;
  unsigned char *buffer = (unsigned char *)calloc(bufferLength, sizeof(unsigned char));
  int prevIndex = 0;

  for (int byteIndex=0; byteIndex<length; byteIndex++) {
	char currentByte = byte[byteIndex];
	int bufferIndex = 8*(byteIndex+1);

	while(bufferIndex > prevIndex) {
	  if(currentByte & 0x01) {
		buffer[--bufferIndex] = '1';
	  } else {
		buffer[--bufferIndex] = '0';
	  }
	  currentByte >>= 1;
	}

	prevIndex = 8*(byteIndex+1);
  }

  return (const char *)buffer;
}

+ (NSInteger)BinaryToDecimal:(const char *)buffer fromIndex:(int)startIndex toIndex:(int)endIndex {
  return [self BinaryToDecimal:buffer fromIndex:startIndex length:(endIndex - startIndex)];
}

+ (NSInteger)BinaryToDecimal:(const char *)buffer fromIndex:(int)startIndex length:(int)totalOffset {
  int length = (int)strlen((const char *)buffer);

  if (length <= startIndex || length <= startIndex + totalOffset - 1) {
	return 0;
  }

  NSInteger total = 0;
  int from = (startIndex + totalOffset - 1);
  for (int i = from; i >= startIndex; i--) {
	if (buffer[i] == '1') {

	  total += pow(2, abs(from - i));
	}
  }
  return total;
}

+ (NSString *)BinaryToString:(const char *)buffer fromIndex:(int)startIndex length:(int)totalOffset {
  size_t length = (int)strlen((const char *)buffer);

  if (length <= startIndex || length < startIndex + totalOffset) {
	return (NSString *)0;
  }

  NSMutableString *total = [NSMutableString new];

  for (int i = startIndex; i < (startIndex + totalOffset); i++) {
	[total appendString:[NSString stringWithFormat:@"%c", buffer[i]]];
  }

  return total;
}

+ (NSNumber *)BinaryToNumber:(const char *)buffer fromIndex:(int)startIndex length:(int)totalOffset {
  return @([CmpUtils BinaryToDecimal:buffer fromIndex:startIndex length:totalOffset]);
}

+ (NSString *)BinaryToLanguage:(const char *)buffer fromIndex:(int)startIndex length:(int)totalOffset {
  size_t length = (int)strlen((const char *)buffer);

  if (length <= startIndex || length <= startIndex + totalOffset - 1) {
	return @"0";
  }

  NSMutableString *language = [NSMutableString new];

  NSString
	  *first = [self getLetter:[CmpUtils BinaryToDecimal:buffer fromIndex:startIndex length:totalOffset - 6]];
  [language appendString:first];

  NSString *second =
	  [self getLetter:[CmpUtils BinaryToDecimal:buffer fromIndex:startIndex + 6 length:totalOffset - 6]];
  [language appendString:second];

  return language;
}

+ (NSString *)getLetter:(NSInteger)letterNumber {
  switch (letterNumber) {
	case 0:return @"A";
	case 1:return @"B";
	case 2:return @"C";
	case 4:return @"E";
	case 5:return @"F";
	case 6:return @"G";
	case 7:return @"H";
	case 8:return @"I";
	case 9:return @"J";
	case 10:return @"K";
	case 11:return @"L";
	case 12:return @"M";
	case 13:return @"N";
	case 14:return @"O";
	case 15:return @"P";
	case 16:return @"Q";
	case 17:return @"R";
	case 18:return @"S";
	case 19:return @"T";
	case 20:return @"U";
	case 21:return @"V";
	case 22:return @"W";
	case 23:return @"X";
	case 24:return @"Y";
	case 25:return @"Z";
	default:break;
  }
  return @"";
}

//TODO remove due to js object.
+ (NSString *)addPaddingIfNeeded:(NSString *)base64String {
  int padLength = (int)((4 - (base64String.length % 4)) % 4);
  NSString *paddedBase64 = [NSString stringWithFormat:@"%s%.*s", [base64String UTF8String], padLength, "=="];
  return paddedBase64;
}

+ (NSString *)replaceSafeCharacters:(NSString *)consentString {
  NSString *stringReplace = [consentString stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
  stringReplace = [stringReplace stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
  stringReplace = [stringReplace stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
  stringReplace = [stringReplace stringByReplacingOccurrencesOfString:@" " withString:@"+"];
  NSString *finalString = [stringReplace stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
  return finalString;
}

+ (NSString *)safeBase64ConsentString:(NSString *)consentString {
  NSString *safeString = [CmpUtils replaceSafeCharacters:consentString];
  NSString *base64String = [CmpUtils addPaddingIfNeeded:safeString];
  return base64String;
}

+ (BOOL)isNetworkAvailable {
  CmpReachability *networkReachability = [CmpReachability reachabilityForInternetConnection];
  NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
  if (networkStatus == NotReachable) {
	return NO;
  } else {
	return YES;
  }
}

+ (CMPServerResponse *)     getAndSaveServerResponse:(void (^)(NSString *error))networkErrorListener serverErrorListener:(void (^)(
	NSString *error))serverErrorListener withConsent:(NSString *)consent {
  if ([self isNetworkAvailable]) {
	NSDictionary
		*responseDictionary = [self requestSynchronousJSONWithURLString:[CmpConfig getConsentToolURLString:consent]];
	if (responseDictionary != nil) {
	  @try {
		CMPServerResponse *response = [[CMPServerResponse alloc] init];
		response.message = responseDictionary[RESPONSE_MESSAGE_KEY];
		response.status = @([responseDictionary[RESPONSE_STATUS_KEY] intValue]);
		response.regulation =
			@([responseDictionary[RESPONSE_REGULATION_KEY] intValue]);
		[Logger debug:TAG :[NSString stringWithFormat:@"message: %@ status: %@ regulation: %@ url: %@",
													  response.message,
													  response.status,
													  response.regulation,
													  response.url]];
		[CMPSettings setConsentProcessData:response];

		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd"];
		[CMPDataStoragePrivateUserDefaults setLastRequested:[dateFormatter stringFromDate:[NSDate date]]];
		return response;
	  } @catch (id anException) {
		[Logger error:TAG :@"Consentmanager Server response was incorrect"];
		if (serverErrorListener) {
		  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		  dispatch_async(queue, ^{
			serverErrorListener(@"ConsentManager Server response was incorrect. Maybe a wrong url was given.");
		  });

		}
		return nil;
	  }
	} else {
	  [Logger error:TAG :@"ConsentManager Server couldn't be contacted"];
	  if (serverErrorListener) {
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		dispatch_async(queue, ^{
		  serverErrorListener(@"The Server couldn't be contacted, because no Network Connection was found, or the server is down.");
		});

	  }
	  return nil;
	}

  } else {
	[Logger error:TAG :@"Network was not available"];
	if (networkErrorListener) {
	  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	  dispatch_async(queue, ^{
		networkErrorListener(@"The Server couldn't be contacted, because no Network Connection was found");
	  });
	}
	return nil;
  }
}

+ (NSData *)requestSynchronousData:(NSURLRequest *)request {
  __block NSData *data = [[NSData alloc] init];
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData,
																							NSURLResponse *response,
																							NSError *error) {
	data = taskData;
	if (!data) {
	  [Logger error:TAG :[NSString stringWithFormat:@"Error with message: %@", error]];
	}
	dispatch_semaphore_signal(semaphore);

  }];
  [dataTask resume];
  dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
  return data;
}
+ (NSData *)requestSynchronousDataWithURLString:(NSString *)requestString {
  NSURL *url = [NSURL URLWithString:requestString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  return [self requestSynchronousData:request];
}

+ (NSDictionary *)requestSynchronousJSON:(NSURLRequest *)request {
  NSData *data = [self requestSynchronousData:request];
  NSError *e = nil;
  [Logger debug:TAG :[NSString stringWithFormat:@"request of: %@", request]];
  if (data != nil && data.length > 0) {
	NSDictionary
		*jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
	[Logger debug:TAG :[NSString stringWithFormat:@"response of: %@", jsonData]];
	return jsonData;
  } else {
	return nil;
  }
}

+ (NSDictionary *)requestSynchronousJSONWithURLString:(NSString *)requestString {
	NSURL *url = [NSURL URLWithString:requestString];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
															  cachePolicy:NSURLRequestUseProtocolCachePolicy
														  timeoutInterval:5];
	theRequest.HTTPMethod = @"GET";
	[theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	return [self requestSynchronousJSON:theRequest];
}

+ (const char *)binaryConsentFrom:(NSString *)consentString {

  NSString *safeString = [CmpUtils safeBase64ConsentString:consentString];
  NSData *decodedData =
	  [[NSData alloc] initWithBase64EncodedString:safeString options:NSDataBase64DecodingIgnoreUnknownCharacters];

  if (!decodedData) {
	return nil;
  }

  return [CmpUtils NSDataToBinary:decodedData];
}

+ (NSString *)binaryStringConsentFrom:(NSString *)consentString {
  NSString *safeString = [CmpUtils safeBase64ConsentString:consentString];
  NSData *nsData = [safeString
	  dataUsingEncoding:NSUTF8StringEncoding];
  NSData *decodedData = [nsData initWithBase64EncodedString:safeString options:0];
  [Logger debug:TAG :[NSString stringWithFormat:@"decoded String %@", safeString]];
  NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
  return decodedString;
}

+ (NSURL *)getCmpLayerUrl:(NSString *)consentString :(BOOL)forceOpen {
  NSInteger r = arc4random_uniform(9999);
  return [self generateResponseUrlWithStamp:r consentString:consentString :forceOpen];
}

+ (NSURL *)generateResponseUrlWithStamp:(NSInteger)stamp consentString:(NSString *)consentString :(BOOL)forceOpen {
  NSMutableString *urlString = [
	  NSMutableString stringWithFormat:CMP_URL_PATTERN,
									   [CmpConfig consentToolDomain],
									   [CmpConfig consentToolId],
									   [CmpConfig consentToolAppName],
									   [CmpConfig consentToolLanguage],
									   [CmpConfig getIdfa],
									   [CmpConfig getAppleTrackingStatus]
  ];

  if (forceOpen) {
	[urlString appendString:@"&cmpscreen"];
  }

  if(![consentString isEqualToString:@""]) {
	NSDate *currentDate = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"ddMMYYYY"];
	NSString *dateString = [NSString stringWithFormat:@"%@%ld", [dateFormatter stringFromDate:currentDate], (long)stamp];
	[urlString appendString:[NSString stringWithFormat:@"&zt=%@#cmpimport=%@", dateString, consentString ?: @""]];
  }

  return [NSURL URLWithString:urlString];
}

+ (BOOL)validateCmpLayerUrl:(NSURL *)url {
  NSString *host = url.host;
  if ([host isEqualToString:[CmpConfig consentToolDomain]]) {
	return YES;
  }
  return NO;
}

@end
