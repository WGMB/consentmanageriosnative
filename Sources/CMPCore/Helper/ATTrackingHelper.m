//
// Created by Skander Ben Abdelmalak on 20.11.21.
//

#import "ATTrackingHelper.h"
#import "CmpConfig.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@implementation ATTrackingHelper

+ (void)requestATTPermission {
  if (@available(iOS 14.0, *)) {
	[ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        [CmpConfig setAppleTrackingStatus:status];
	}];
  }
}
@end
