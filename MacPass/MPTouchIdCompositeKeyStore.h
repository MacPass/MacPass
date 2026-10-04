//
//  MPTouchIdCompositeKeyStore.h
//  MacPass
//
//  Created by Julius Zint on 14.03.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@class KPKCompositeKey;

@interface MPTouchIdCompositeKeyStore : NSObject

@property (class, strong, readonly) MPTouchIdCompositeKeyStore *defaultStore;

/// Securely stores the provided compoiste key in the key store.
/// The key is encrypted and then stored to the corresponding location (transient or permanent)
/// @param compositeKey the composite key to store
/// @param documentKey the document key to store the composite key for
- (void)saveCompositeKey:(KPKCompositeKey *)compositeKey forDocumentKey:(NSString*)documentKey;

/// Load the encrypted composite key for the given key if anyone is found
/// @param documentKey the key to identify the document. Normally you should use the file name
- (NSData  * _Nullable)loadEncryptedCompositeKeyForDocumentKey:(NSString *)documentKey;

/// Discards every stored composite key, transient as well as persisted ones.
/// The database password has to be entered again before TouchID can be used for any document.
- (void)clearStoredCompositeKeys;

- (KPKCompositeKey * _Nullable)compositeKeyForEncryptedKeyData:(NSData *)data error:(NSError **)error;
- (NSData * _Nullable)encryptedDataForCompositeKey:(KPKCompositeKey *)compositeKey error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
