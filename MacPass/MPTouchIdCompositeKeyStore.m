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
#import "MPSettingsHelper.h"

#import "NSError+Messages.h"

@interface MPTouchIdCompositeKeyStore ()
@property (readonly, strong) NSMutableDictionary* keys;
@property (readonly, strong) NSMutableDictionary* keyDates;
@property (nonatomic) MPTouchIDKeyStorage touchIdEnabledState;
@property (nonatomic) NSUInteger keyTimeOut;
@property (nonatomic) BOOL clearKeysOnSleep;
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
    _keyDates = [[NSMutableDictionary alloc] init];
    [self bind:NSStringFromSelector(@selector(touchIdEnabledState))
      toObject:NSUserDefaultsController.sharedUserDefaultsController
   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyTouchIdEnabled]
       options:nil];
    [self bind:NSStringFromSelector(@selector(keyTimeOut))
      toObject:NSUserDefaultsController.sharedUserDefaultsController
   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyTouchIdKeyTimeOut]
       options:nil];
    [self bind:NSStringFromSelector(@selector(clearKeysOnSleep))
      toObject:NSUserDefaultsController.sharedUserDefaultsController
   withKeyPath:[MPSettingsHelper defaultControllerPathForKey:kMPSettingsKeyClearTouchIdKeysOnSleep]
       options:nil];
  }
  return self;
}

- (void)dealloc {
  [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self];
}

- (void)setTouchIdEnabledState:(MPTouchIDKeyStorage)touchIdEnabledState {
  switch(touchIdEnabledState) {
    case MPTouchIDKeyStorageTransient:
      // clear persistent store
      [self _clearPersistenCompositeKeyData];
      break;
    case MPTouchIDKeyStoragePersistent:
      // clear transient store
      [self _clearTransientCompositeKeyData];
      break;
    default:
      // clear persitent and transient store
      [self _clearPersistenCompositeKeyData];
      [self _clearTransientCompositeKeyData];
  }
  _touchIdEnabledState = touchIdEnabledState;
}

- (void)setClearKeysOnSleep:(BOOL)clearKeysOnSleep {
  if(_clearKeysOnSleep == clearKeysOnSleep) {
    return;
  }
  _clearKeysOnSleep = clearKeysOnSleep;
  if(_clearKeysOnSleep) {
    [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self
                                                       selector:@selector(_clearStoredCompositeKeysForNotification:)
                                                           name:NSWorkspaceWillSleepNotification
                                                         object:nil];
  }
  else {
    [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self name:NSWorkspaceWillSleepNotification object:nil];
  }
}

- (void)clearStoredCompositeKeys {
  [self _clearPersistenCompositeKeyData];
  [self _clearTransientCompositeKeyData];
}

- (void)_clearStoredCompositeKeysForNotification:(NSNotification *)notification {
  [self clearStoredCompositeKeys];
}

- (void)saveCompositeKey:(KPKCompositeKey *)compositeKey forDocumentKey:(NSString *)documentKey {
  if(documentKey.length == 0) {
    return;
  }
  NSError *error;
  NSData *encryptedCompositeKey = [self encryptedDataForCompositeKey:compositeKey error:&error];
  if(!encryptedCompositeKey) {
    NSLog(@"Unable ot encrypt composite key: %@", error);
    return;
  }

  /* The date the password was entered is what the timeout is measured against */
  NSDate *storageDate = NSDate.date;
  switch(self.touchIdEnabledState) {
    case MPTouchIDKeyStorageTransient:
      [self _clearPersistenCompositeKeyData];
      if(nil != encryptedCompositeKey) {
        self.keys[documentKey] = encryptedCompositeKey;
        self.keyDates[documentKey] = storageDate;
      }
      break;
    case MPTouchIDKeyStoragePersistent:
      [self _clearTransientCompositeKeyDataForDocumentKey:documentKey];
      if(nil != encryptedCompositeKey) {
        [self _persistCompositeKeyData:encryptedCompositeKey date:storageDate forDocumentKey:documentKey];
      }
      break;
    case MPTouchIDKeyStorageDisabled:
      [self _clearPersistenCompositeKeyData];
      [self _clearTransientCompositeKeyDataForDocumentKey:documentKey];
      break;
    default:
      NSAssert(NO,@"Unsupported internal touchID preferences value.");
      break;
  }
}
- (NSData *)loadEncryptedCompositeKeyForDocumentKey:(NSString *)documentKey {
  if(documentKey.length == 0) {
    return nil;
  }
  NSInteger touchIdMode = [NSUserDefaults.standardUserDefaults integerForKey:kMPSettingsKeyTouchIdEnabled];
  NSData* transientKey  = self.keys[documentKey];
  NSData* persistentKey = [self _persitentCompositeKeyDataForDocumentKey:documentKey];
  /* Drop timed out keys instead of handing them out. The user has to supply the password again */
  if(nil != transientKey && [self _isTimedOutDate:self.keyDates[documentKey]]) {
    [self _clearTransientCompositeKeyDataForDocumentKey:documentKey];
    transientKey = nil;
  }
  if(nil != persistentKey && [self _isTimedOutDate:[self _persistentDateForDocumentKey:documentKey]]) {
    [self _clearPersistentCompositeKeyDataForDocumentKey:documentKey];
    persistentKey = nil;
  }
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

- (BOOL)_isTimedOutDate:(NSDate *)date {
  NSUInteger timeOut = self.keyTimeOut;
  if(0 == timeOut) {
    return NO; // no timeout configured, keys are kept until they are cleared otherwise
  }
  /* Keys stored before this setting existed carry no date. Without one we cannot tell
     whether they are still inside the timeout, so they are treated as timed out. */
  if(![date isKindOfClass:NSDate.class]) {
    return YES;
  }
  return (-date.timeIntervalSinceNow >= (NSTimeInterval)timeOut);
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

- (NSData *)_persitentCompositeKeyDataForDocumentKey:(NSString *)key {
  if(key.length == 0) {
    return nil;
  }
  return [NSUserDefaults.standardUserDefaults objectForKey:kMPSettingsKeyTouchIdEncryptedKeyStore][key];
}

- (NSDate *)_persistentDateForDocumentKey:(NSString *)key {
  if(key.length == 0) {
    return nil;
  }
  return [NSUserDefaults.standardUserDefaults objectForKey:kMPSettingsKeyTouchIdKeyDateStore][key];
}

- (void)_persistCompositeKeyData:(NSData *)data date:(NSDate *)date forDocumentKey:(NSString *)key {
  if(data.length == 0 || key.length == 0) {
    return;
  }
  [self _updatePersistentStoreForKey:kMPSettingsKeyTouchIdEncryptedKeyStore documentKey:key value:data];
  [self _updatePersistentStoreForKey:kMPSettingsKeyTouchIdKeyDateStore documentKey:key value:date];
}

- (void)_clearPersistenCompositeKeyData {
  [NSUserDefaults.standardUserDefaults removeObjectForKey:kMPSettingsKeyTouchIdEncryptedKeyStore];
  [NSUserDefaults.standardUserDefaults removeObjectForKey:kMPSettingsKeyTouchIdKeyDateStore];
}

- (void)_clearPersistentCompositeKeyDataForDocumentKey:(NSString *)key {
  if(key.length == 0) {
    return;
  }
  [self _updatePersistentStoreForKey:kMPSettingsKeyTouchIdEncryptedKeyStore documentKey:key value:nil];
  [self _updatePersistentStoreForKey:kMPSettingsKeyTouchIdKeyDateStore documentKey:key value:nil];
}

- (void)_updatePersistentStoreForKey:(NSString *)settingsKey documentKey:(NSString *)key value:(id)value {
  NSMutableDictionary *dict = [[NSUserDefaults.standardUserDefaults objectForKey:settingsKey] mutableCopy];
  if(nil == dict) {
    if(nil == value) {
      return;
    }
    dict = [[NSMutableDictionary alloc] init];
  }
  dict[key] = value;
  [NSUserDefaults.standardUserDefaults setObject:[dict copy] forKey:settingsKey];
}

- (void)_clearTransientCompositeKeyData {
  [self.keys removeAllObjects];
  [self.keyDates removeAllObjects];
}

- (void)_clearTransientCompositeKeyDataForDocumentKey:(NSString *)key {
  if(key.length == 0) {
    return;
  }
  [self.keys removeObjectForKey:key];
  [self.keyDates removeObjectForKey:key];
}

@end
