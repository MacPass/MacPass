//
//  MPDocument+BiometricEncryptionSupport.m
//  MacPass
//
//  Created by Michael Starke on 22.08.22.
//  Copyright © 2022 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument+BiometricEncryptionSupport.h"
#import "MPTouchIdCompositeKeyStore.h"
#import "NSString+MPHash.h"


@implementation MPDocument (BiometricEncryptionSupport)

@dynamic biometricKey;

- (NSString *)biometricKey {
  return [self.fileURL.lastPathComponent sha1HexDigest];
}

- (NSData *)encryptedKeyData {
  NSString *documentKey = self.biometricKey;
  if(nil == documentKey) {
    return nil;
  }
  return [MPTouchIdCompositeKeyStore.defaultStore loadEncryptedCompositeKeyForDocumentKey:documentKey];
}

@end
