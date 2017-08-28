//
//  MPOSHelper.m
//  MacPass
//
//  Created by Lucas Paul on 28/08/2017.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPOSHelper.h"

@implementation MPOSHelper

+(BOOL)supportsTouchID {
	LAContext *myContext = [LAContext new];

	NSError *authError = nil;

	if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber10_11_4) {
		if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
			if (authError == nil) {
				return YES;
			}
		} else {
			// Could not evaluate policy; look at authError and present an appropriate message to user
			NSLog(@"Could not evaluate authentication policy: %@", authError.localizedDescription);
			if (authError.localizedFailureReason != nil) {
				NSLog(@"Failure Reason: %@", authError.localizedFailureReason);
			}
		}
	}

	return NO;
}

@end
