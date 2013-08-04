//
//  UUID+Pasterboard.m
//  MacPass
//
//  Created by Michael Starke on 04.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "UUID+Pasterboard.h"
#import "MPConstants.h"

@implementation UUID (Pasterboard)

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
  NSData *data = [aDecoder decodeObjectForKey:@"data"];
  self = [self initWithData:data];
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:[self getData] forKey:@"data"];
}

#pragma mark -
#pragma mark NSPasteboardReading

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
  return @[ MPUUIDUTI ];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
  NSAssert([type isEqualToString:MPUUIDUTI], @"Only MPUUID type is supported");
  return NSPasteboardReadingAsKeyedArchive;
}
#pragma mark -
#pragma mark NSPasteboardWriting

- (id)pasteboardPropertyListForType:(NSString *)type {
  NSAssert([type isEqualToString:MPUUIDUTI], @"Only MPUUID type is supported");
  return [NSKeyedArchiver archivedDataWithRootObject:self];
}

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
  return @[ MPUUIDUTI ];
}

@end
