//
//  MPTouchIdCompositeKeyStore.m
//  MacPass
//
//  Created by Julius Zint on 14.03.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//
#import "MPSettingsHelper.h"
#import "MPTouchIdCompositeKeyStore.h"

@implementation MPTouchIdCompositeKeyStore

+ (instancetype)defaultStore {
  static MPTouchIdCompositeKeyStore *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[MPTouchIdCompositeKeyStore alloc] init];
    if(touchIDSecuredPasswords == NULL) {
      touchIDSecuredPasswords = [[NSMutableDictionary alloc]init];
    }
  });
  return instance;
}

- (void) save: (NSData*) encryptedCompositeKey forDocumentKey:(NSString*) documentKey {
  long touchIdMode = [NSUserDefaults.standardUserDefaults integerForKey:kMPSettingsKeyEntryTouchIdEnabled];
  if (touchIdMode == NSControlStateValueMixed) {
    [NSUserDefaults.standardUserDefaults removeObjectForKey:documentKey];
    if(encryptedCompositeKey != NULL) {
      [touchIDSecuredPasswords setObject:encryptedCompositeKey forKey:documentKey];
    }
  }
  else if(touchIdMode == NSControlStateValueOn) {
    [touchIDSecuredPasswords removeObjectForKey:documentKey];
    if(encryptedCompositeKey != NULL) {
      [NSUserDefaults.standardUserDefaults setObject:encryptedCompositeKey forKey:documentKey];
    }
  }
  else {
    [NSUserDefaults.standardUserDefaults removeObjectForKey:documentKey];
    [touchIDSecuredPasswords removeObjectForKey:documentKey];
  }
}

- (bool) load: (NSData**) encryptedCompositeKey forDocumentKey: (NSString*) documentKey {
  long touchIdMode = [NSUserDefaults.standardUserDefaults integerForKey:kMPSettingsKeyEntryTouchIdEnabled];
  NSData* transientKey  = [touchIDSecuredPasswords valueForKey:documentKey];
  NSData* persistentKey =[NSUserDefaults.standardUserDefaults dataForKey:documentKey];
  if(transientKey == NULL && persistentKey == NULL) {
    return false;
  }
  if(transientKey == NULL || persistentKey == NULL) {
    *encryptedCompositeKey = transientKey == NULL ? persistentKey : transientKey;
    return true;
  }
  if(touchIdMode == NSControlStateValueOn) {
    *encryptedCompositeKey = persistentKey;
    return true;
  }
  *encryptedCompositeKey = transientKey;
  return true;
}

@end
