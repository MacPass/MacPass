//
//  MPDocument+BiometricEncryptionSupport.h
//  MacPass
//
//  Created by Michael Starke on 22.08.22.
//  Copyright © 2022 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPDocument (BiometricEncryptionSupport)
@property (nonatomic, readonly, copy, nullable) NSString *biometricKey;
@property (nonatomic, readonly, copy, nullable) NSData *encryptedKeyData;

@end

NS_ASSUME_NONNULL_END
