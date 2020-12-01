//
//  KPKEntry+OTP.h
//  MacPass
//
//  Created by Michael Starke on 25.11.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import <KeePassKit/KeePassKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KPKEntry (OTP)

@property (readonly, assign, nonatomic) BOOL hasTOTP;

@end

NS_ASSUME_NONNULL_END
