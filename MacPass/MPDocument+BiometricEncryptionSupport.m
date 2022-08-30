//
//  MPDocument+BiometricEncryptionSupport.m
//  MacPass
//
//  Created by Michael Starke on 22.08.22.
//  Copyright © 2022 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument+BiometricEncryptionSupport.h"
#import "MPSettingsHelper.h"
#import "MPTouchIdCompositeKeyStore.h"

@implementation MPDocument (BiometricEncryptionSupport)

@dynamic biometricKey;

- (NSString *)biometricKey {
  if(nil == self.fileURL || nil == self.fileURL.lastPathComponent) {
    return nil;
  }
  return [NSString stringWithFormat:kMPSettingsKeyEntryTouchIdDatabaseEncryptedKeyFormat, self.fileURL.lastPathComponent];
}

- (NSData *)encryptedKeyData {
  NSString *documentKey = self.biometricKey;
  if(nil == documentKey) {
    return nil;
  }
  return [MPTouchIdCompositeKeyStore.defaultStore loadEncryptedCompositeKeyForDocumentKey:documentKey];
}

@end
