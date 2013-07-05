//
//  KdbTree+MPAdditions.m
//  MacPass
//
//  Created by michael starke on 20.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbTree+MPAdditions.h"
#import "KdbGroup+MPTreeTools.h"

#import "Kdb3Node.h"
#import "Kdb4Node.h"

@implementation KdbTree (MPAdditions)

- (NSArray *)allGroups {
  return [self.root childGroups];
}

- (NSArray *)allEntries {
  return [self.root childEntries];
}

- (void)addAttachment:(NSURL *)location toEntry:(KdbEntry *)anEntry {
  NSError *error = nil;
  NSString *fileName = [NSString stringWithFormat:@"%@.%@", [location lastPathComponent], [location pathExtension]];
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
  }
  if( [anEntry isKindOfClass:[Kdb4Entry class]]) {
    Kdb4Entry *entry = (Kdb4Entry *)anEntry;
    Kdb4Tree *tree = (Kdb4Tree *)self;
    NSString *fileData = [NSString stringWithContentsOfURL:location usedEncoding:0 error:&error];
    if(!fileData) {
      [NSApp presentError:error];
      fileData = nil;
      error = nil;
      return; // failed
    }
    Binary *binary = [[Binary alloc] init];
    binary.binaryId = [self nextBinaryId];
    binary.compressed = (tree.compressionAlgorithm == KPLCompressionGzip);
    if(binary.compressed ) {
      
    }
    binary.data = fileData;
    
    [tree.binaries addObject:binary];
    BinaryRef *ref = [[BinaryRef alloc] init];
    ref.key = fileName;
    [entry.binaries addObject:ref];
  }
}

- (void)saveAttachment:(BinaryRef *)reference toLocation:(NSURL *)location {
  
}

- (void)saveAttachmentFromEntry:(KdbEntry *)entry toLocation:(NSURL *)location {

}

- (NSUInteger)nextBinaryId {
  Kdb4Tree *tree = (Kdb4Tree *)self;
  NSUInteger maxKey = 0;
  for(Binary *binary in tree.binaries) {
    maxKey = MAX(binary.binaryId, maxKey);
  }
  return (maxKey + 1);
}

@end
