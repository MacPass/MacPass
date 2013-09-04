//
//  NSError+Messages.m
//  MacPass
//
//  Created by Michael Starke on 04.09.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "NSError+Messages.h"
#import "KPKErrors.h"

@implementation NSError (Messages)

- (NSString *)descriptionForErrorCode {
  switch ([self code]) {
    case KPKErrorUnknownFileFormat:
    case KPKErrorUnsupportedDatabaseVersion:
    case KPKErrorNoData:
    case KPKErrorHeaderCorrupted:
    case KPKErrorWriteFailed:
    case KPKErrorEncryptionFaild:
    case KPKErrorDecryptionFaild:
    case KPKErrorDatabaseParsingFailed:
    case KPKerrorXMLKeyUnsupportedVersion:
    case KPKErrorXMLKeyKeyElementMissing:
    case KPKErrorXMLKeyDataElementMissing:
    case KPKErrorXMLKeyDataParsingError:
    case KPKErrorUnsupportedCipher:
    case KPKErrorUnsupportedCompressionAlgorithm:
    case KPKErrorUnsupportedRandomStream:
    case KPKErrorPasswordAndOrKeyfileWrong:
    case KPKErrorIntegrityCheckFaild:
    case KPKErrorXMLKeePassFileElementMissing:
    case KPKErrorXMLRootElementMissing:
    case KPKErrorXMLMetaElementMissing:
    case KPKErrorXMLGroupElementMissing:
    case KPKErrorXMLInvalidHeaderFieldSize:
    case KPKErrorXMLInvalidHeaderFieldType:
    case KPKErrorLegacyInvalidFieldType:
    case KPKErrorLegacyInvalidFieldSize:
    case KPKErrorLegacyHeaderHashCorrupted:
    case KPKErrorLegacyCorruptTree:
    default: {
      return [NSString stringWithFormat:@"%@ (%ld)", [self localizedDescription], [self code] ];
    }
  }
}
@end
