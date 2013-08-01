//
//  MPDocument+Attachments.m
//  MacPass
//
//  Created by Michael Starke on 05.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"

#import "NSMutableData+Base64.h"
#import "NSData+Gzip.h"

#import "Kdb3Node.h"
#import "Kdb3Entry+KVOAdditions.h"
#import "Kdb4Node.h"
#import "Kdb4Entry+KVOAdditions.h"

@implementation MPDocument (Attachments)

- (void)addAttachment:(NSURL *)location toEntry:(KdbEntry *)anEntry {
  NSError *error = nil;
  NSDictionary *resourceKeys = [location resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
  if([resourceKeys[ NSURLIsDirectoryKey ] boolValue] == YES ) {
    return; // We do not add whol directories
  }
  NSString *fileName = [location lastPathComponent];
  if([anEntry isKindOfClass:[Kdb3Entry class]]) {
    Kdb3Entry *entry = (Kdb3Entry *)anEntry;
    NSData *binaryData = [NSData dataWithContentsOfURL:location options:NSDataReadingUncached error:&error];
    if(!binaryData) {
      [NSApp presentError:error];
      binaryData = nil;
      error = nil;
      return; // failed
    }
    entry.binary = binaryData;
    entry.binaryDesc = fileName;
    [entry insertObject:@"" inBinariesAtIndex:1];
  }
  if( [anEntry isKindOfClass:[Kdb4Entry class]]) {
    Kdb4Entry *entry = (Kdb4Entry *)anEntry;
    NSData *fileData = [NSData dataWithContentsOfURL:location options:NSDataReadingMappedIfSafe error:&error];
    if(!fileData) {
      [NSApp presentError:error];
      fileData = nil;
      error = nil;
      return; // failed
    }
    Binary *binary = [[Binary alloc] init];
    NSUInteger nextId = [self nextBinaryId];
    if(nextId == NSNotFound) {
      binary = nil;
      return; // No id found. Something went wrong
    }
    binary.binaryId = nextId;
    binary.compressed = (self.treeV4.compressionAlgorithm != KPLCompressionNone);
    NSData *encodedData;
    if(binary.compressed) {
      switch(self.treeV4.compressionAlgorithm) {
        case KPLCompressionGzip: {
          NSData *compressedData = [fileData gzipDeflate];
          encodedData = [NSMutableData mutableDataWithBase64EncodedData:compressedData];
          break;
        }
        default:
          NSAssert(NO, @"Unsupported Compression Algorithm");
          binary = nil;
          encodedData = nil;
          fileData = nil;
          return;
      }
    }
    else {
      encodedData = fileData;
    }
    binary.data = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
    
    [self.treeV4.binaries addObject:binary];
    BinaryRef *ref = [[BinaryRef alloc] init];
    ref.key = fileName;
    ref.ref = binary.binaryId;
    [entry insertObject:ref inBinariesAtIndex:[entry.binaries count]];
  }
}

- (void)removeAttachment:(BinaryRef *)reference fromEntry:(KdbEntry *)anEntry {
  if(self.version != MPDatabaseVersion4) {
    return; // Wrong Database version;
  }
  Binary *binary = [self findBinary:reference];
  Kdb4Entry *entry = (Kdb4Entry *)anEntry;
  NSUInteger index = [entry.binaries indexOfObject:reference];
  if(index == NSNotFound) {
    return; // No Reference for this entry found
  }
  [entry removeObjectFromBinariesAtIndex:index];
  [self.treeV4.binaries removeObject:binary];
}

- (void)removeAttachmentFromEntry:(KdbEntry *)anEntry {
  if(self.version != MPDatabaseVersion3) {
    return;
  }
  Kdb3Entry *entry = (Kdb3Entry *)anEntry;
  [entry removeObjectFromBinariesAtIndex:0];
}

- (Binary *)findBinary:(BinaryRef *)reference {
  if(self.version != MPDatabaseVersion4) {
    return nil;
  }
  NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
    Binary *binaryFile = evaluatedObject;
    return (binaryFile.binaryId == reference.ref);
  }];
  NSArray *filteredBinary = [self.treeV4.binaries filteredArrayUsingPredicate:filterPredicate];
  return [filteredBinary lastObject];
}

- (void)saveAttachmentForItem:(id)item toLocation:(NSURL *)location {
  if([item isKindOfClass:[Kdb3Entry class]]) {
    Kdb3Entry *entry = (Kdb3Entry *)item;
    NSError *error = nil;
    if(! [entry.binary writeToURL:location options:NSDataWritingAtomic error:&error] ) {
      [NSApp presentError:error];
    }
  }
  else if([item isKindOfClass:[BinaryRef class]]) {
    Binary *binary = [self findBinary:item];
    NSData *rawData = nil;
    if(binary) {
      if(binary.compressed) {
        rawData = [NSMutableData mutableDataWithBase64DecodedData:[binary.data dataUsingEncoding:NSUTF8StringEncoding]];
        rawData = [rawData gzipInflate];
      }
      else {
        rawData = [NSMutableData mutableDataWithBase64DecodedData:[binary.data dataUsingEncoding:NSUTF8StringEncoding]];
      }
      NSError *error = nil;
      if( ![rawData writeToURL:location options:NSDataWritingAtomic error:&error] ) {
        [NSApp presentError:error];
      }
    }
  }
  else {
    NSAssert(NO, @"Item is neither BinaryRef nor Kdb3Entry");
    return;
  }
}

- (NSUInteger)nextBinaryId {
  if(self.version != MPDatabaseVersion4) {
    return NSNotFound;
  }
  NSUInteger maxKey = 0;
  for(Binary *binary in self.treeV4.binaries) {
    maxKey = MAX(binary.binaryId, maxKey);
  }
  return (maxKey + 1);
}

@end
