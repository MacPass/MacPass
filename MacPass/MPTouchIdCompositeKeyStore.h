//
//  MPTouchIdCompositeKeyStore.h
//  MacPass
//
//  Created by Julius Zint on 14.03.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//

#ifndef MPTouchIdCompositeKeyStore_h
#define MPTouchIdCompositeKeyStore_h

static NSMutableDictionary* touchIDSecuredPasswords;

@interface MPTouchIdCompositeKeyStore : NSObject
  @property (class, strong, readonly) MPTouchIdCompositeKeyStore *defaultStore;

  - (void) save:(NSData*) encryptedCompositeKey forDocumentKey:(NSString*) documentKey;
  - (bool) load:(NSData**) encryptedCompositeKey forDocumentKey:(NSString*) documentKey;
@end

#endif /* MPTouchIdCompositeKeyStore_h */
