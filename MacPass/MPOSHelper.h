//
//  MPOSHelper.h
//  MacPass
//
//  Created by Lucas Paul on 28/08/2017.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@import LocalAuthentication;

@interface MPOSHelper : NSObject

+(BOOL)supportsTouchID;

@end
