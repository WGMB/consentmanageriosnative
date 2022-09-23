//
// Created by Skander Ben Abdelmalak on 03.01.22.
//

#import "Logger.h"
#import "CmpConfig.h"


@implementation Logger {

}

static NSInteger const L_DEBUG = 4;
static NSInteger const L_WARNING = 3;
static NSInteger const L_INFO = 2;
static NSInteger const L_ERROR = 1;

+ (void)log:(NSString *)tag :(NSString *)message {
  if(CmpConfig.getVerboseLevel > 0) {
  	NSLog(@"%@:%@", tag, message);
  }
}
+ (void)debug:(NSString *)tag :(NSString *)message {
  if(CmpConfig.getVerboseLevel >= L_DEBUG) {
	NSLog(@"%@:%@", tag, message);
  }
}
+ (void)info:(NSString *)tag :(NSString *)message {
  if(CmpConfig.getVerboseLevel >= L_INFO) {
	NSLog(@"%@:%@", tag, message);
  }
}
+ (void)warning:(NSString *)tag :(NSString *)message {
  if(CmpConfig.getVerboseLevel >= L_WARNING) {
	NSLog(@"%@:%@", tag, message);
  }
}
+ (void)error:(NSString *)tag :(NSString *)message {
  if(CmpConfig.getVerboseLevel >= L_ERROR) {
	NSLog(@"%@:%@", tag, message);
  }
}

@end