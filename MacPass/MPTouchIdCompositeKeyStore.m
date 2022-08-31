//
//  MPTouchIdCompositeKeyStore.m
//  MacPass
//
//  Created by Julius Zint on 14.03.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//
#import "MPSettingsHelper.h"
#import "MPTouchIdCompositeKeyStore.h"
#import "MPConstants.h"

#import "NSError+Messages.h"

@interface MPTouchIdCompositeKeyStore ()
@property (readonly, strong) NSMutableDictionary* keys;
@end

@implementation MPTouchIdCompositeKeyStore

+ (instancetype)defaultStore {
  static MPTouchIdCompositeKeyStore *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[MPTouchIdCompositeKeyStore alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if(self) {
    _keys = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)saveCompositeKey:(KPKCompositeKey *)compositeKey forDocumentKey:(NSString *)documentKey {
  NSError *error;
  NSData *encryptedCompositeKey = [self encryptedDataForCompositeKey:compositeKey error:&error];
  if(!encryptedCompositeKey) {
    NSLog(@"Unable ot encrypt composite key: %@", error);
    return;
  }
  
  NSInteger touchIdMode = [NSUserDefaults.standardUserDefaults integerForKey:kMPSettingsKeyEntryTouchIdEnabled];
  switch(touchIdMode) {
    case NSControlStateValueMixed:
      [NSUserDefaults.standardUserDefaults removeObjectForKey:documentKey];
      if(nil != encryptedCompositeKey) {
        self.keys[documentKey] = encryptedCompositeKey;
      }
      break;
    case NSControlStateValueOn:
      self.keys[documentKey] = nil;
      if(nil != encryptedCompositeKey) {
        [NSUserDefaults.standardUserDefaults setObject:encryptedCompositeKey forKey:documentKey];
      }
      break;
    default:
      [NSUserDefaults.standardUserDefaults removeObjectForKey:documentKey];
      self.keys[documentKey] = nil;
  }
}
- (NSData *)loadEncryptedCompositeKeyForDocumentKey:(NSString *)documentKey {
  NSInteger touchIdMode = [NSUserDefaults.standardUserDefaults integerForKey:kMPSettingsKeyEntryTouchIdEnabled];
  NSData* transientKey  = self.keys[documentKey];
  NSData* persistentKey =[NSUserDefaults.standardUserDefaults dataForKey:documentKey];
  if(nil == transientKey && nil == persistentKey) {
    return nil;
  }
  if(nil == transientKey || nil == persistentKey) {
    return transientKey == nil ? persistentKey : transientKey;
  }
  if(touchIdMode == NSControlStateValueOn) {
    return persistentKey;
  }
  return transientKey;
}

- (KPKCompositeKey *)compositeKeyForEncryptedKeyData:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error {
  if(nil == data) {
    return nil;
  }
  
  NSData* tag = [MPTouchIdUnlockPrivateKeyTag dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *queryPrivateKey = @{
    (id)kSecClass: (id)kSecClassKey,
    (id)kSecAttrApplicationTag: tag,
    (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
    (id)kSecReturnRef: @YES,
  };
  SecKeyRef privateKey = NULL;
  OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKey);
  if(status != errSecSuccess) {
    if(error != NULL) {
      NSString* description = CFBridgingRelease(SecCopyErrorMessageString(status, NULL));
      *error = [NSError errorWithCode:status description:description];
    }
    if(privateKey) {
      CFRelease(privateKey);
    }
    return nil;
  }
  
  SecKeyAlgorithm algorithm = kSecKeyAlgorithmRSAEncryptionOAEPSHA256AESGCM;
  BOOL canDecrypt = SecKeyIsAlgorithmSupported(privateKey, kSecKeyOperationTypeDecrypt, algorithm);
  if(!canDecrypt) {
    if(error != NULL) {
      *error = [NSError errorWithCode:MPErrorTouchIdUnsupportedKeyForEncrpytion description:NSLocalizedString(@"ERROR_TOUCH_ID_UNSUPPORTED_KEY", @"The key stored for TouchID is not suitable for encrpytion")];
    }
    if(privateKey) {
      CFRelease(privateKey);
    }
    return nil;
  }
  
  CFErrorRef errorRef = NULL; // FIXME: Release?
  NSData* clearText = (NSData*)CFBridgingRelease(SecKeyCreateDecryptedData(privateKey, algorithm, (__bridge CFDataRef)data, &errorRef));
  if(clearText) {
    return [NSKeyedUnarchiver unarchiveObjectWithData:clearText];
  }
  if(error != NULL) {
    *error = CFBridgingRelease(errorRef);
  }
  if(privateKey) {
    CFRelease(privateKey);
  }
  return nil;
}


- (NSData *)encryptedDataForCompositeKey:(KPKCompositeKey *)compositeKey error:(NSError *__autoreleasing  _Nullable *)error {
  NSData* keyData = [NSKeyedArchiver archivedDataWithRootObject:compositeKey];
  NSData* tag = [MPTouchIdUnlockPublicKeyTag dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *getquery = @{
    (id)kSecClass: (id)kSecClassKey,
    (id)kSecAttrApplicationTag: tag,
    (id)kSecReturnRef: @YES,
  };
  SecKeyRef publicKey = NULL;
  OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)getquery, (CFTypeRef *)&publicKey);
  if (status != errSecSuccess) {
    [self _createAndAddRSAKeyPair];
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)getquery, (CFTypeRef *)&publicKey);
    if (status != errSecSuccess) {
      NSString* description = CFBridgingRelease(SecCopyErrorMessageString(status, NULL));
      NSLog(@"Error while trying to query public key from Keychain: %@", description);
      return nil;
    }
  }
  SecKeyAlgorithm algorithm = kSecKeyAlgorithmRSAEncryptionOAEPSHA256AESGCM;
  BOOL canEncrypt = SecKeyIsAlgorithmSupported(publicKey, kSecKeyOperationTypeEncrypt, algorithm);
  NSData *encryptedKey;
  if(canEncrypt) {
    CFErrorRef error = NULL;
    encryptedKey = (NSData*)CFBridgingRelease(SecKeyCreateEncryptedData(publicKey, algorithm, (__bridge CFDataRef)keyData, &error));
    if (!encryptedKey) {
      NSError *err = CFBridgingRelease(error);
      NSLog(@"Error while trying to decrypt the CompositeKey for TouchID unlock: %@", [err description]);
    }
  }
  else {
    NSLog(@"The key retreived from the Keychain is unable to encrypt data");
  }
  if (publicKey)  {
    CFRelease(publicKey);
  }
  return encryptedKey;
}

- (void)_createAndAddRSAKeyPair {
  CFErrorRef error = NULL;
  NSString* publicKeyLabel =  @"MacPass TouchID Feature Public Key";
  NSString* privateKeyLabel = @"MacPass TouchID Feature Private Key";
  NSData* publicKeyTag =  [MPTouchIdUnlockPublicKeyTag  dataUsingEncoding:NSUTF8StringEncoding];
  NSData* privateKeyTag = [MPTouchIdUnlockPrivateKeyTag dataUsingEncoding:NSUTF8StringEncoding];
  SecAccessControlRef access = NULL;
  if (@available(macOS 10.13.4, *)) {
    SecAccessControlCreateFlags flags = kSecAccessControlBiometryCurrentSet;
    if (@available(macOS 10.15, *)) {
      flags |= kSecAccessControlWatch | kSecAccessControlOr;
    }
    access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                             kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                             flags,
                                             &error);
    if(access == NULL) {
      NSError *err = CFBridgingRelease(error);
      NSLog(@"Error while trying to create AccessControl for TouchID unlock feature: %@", [err description]);
      return;
    }
    NSDictionary* attributes = @{
      (id)kSecAttrKeyType:        (id)kSecAttrKeyTypeRSA,
      (id)kSecAttrKeySizeInBits:  @2048,
      (id)kSecAttrSynchronizable: @NO,
      (id)kSecPrivateKeyAttrs:
           @{ (id)kSecAttrIsPermanent:    @YES,
              (id)kSecAttrApplicationTag: privateKeyTag,
              (id)kSecAttrLabel: privateKeyLabel,
              (id)kSecAttrAccessControl:  (__bridge id)access
            },
      (id)kSecPublicKeyAttrs:
           @{ (id)kSecAttrIsPermanent:    @YES,
              (id)kSecAttrApplicationTag: publicKeyTag,
              (id)kSecAttrLabel: publicKeyLabel,
            },
    };
    SecKeyRef result = SecKeyCreateRandomKey((__bridge CFDictionaryRef)attributes, &error);
    if(result == NULL) {
      NSError *err = CFBridgingRelease(error);
      NSLog(@"Error while trying to create a RSA keypair for TouchID unlock feature: %@", [err description]);
    }
    else {
      CFRelease(result);
    }
    CFRelease(access);
  }
  else {
    return;
  }
}


@end
