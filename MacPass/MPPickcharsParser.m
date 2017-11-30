//
//  MPPickcharParser.m
//  MacPass
//
//  Created by Michael Starke on 29.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPPickcharsParser.h"
#import <KeePassKit/KeePassKit.h>

@interface MPPickcharsParser ()

@property NSUInteger pickCount; // count to pick
@property NSUInteger checkboxOffset;
@property BOOL convertToDownArrows;
@property BOOL hideCharacters;
@property (copy) NSString *checkboxFormat;

@end

@implementation MPPickcharsParser

- (instancetype)init {
  self = [self initWithOptions:nil];
  return self;
}

- (instancetype)initWithOptions:(NSString *)options {
  self = [super init];
  if(self) {
    _pickCount = 0;
    _checkboxOffset = 0;
    _convertToDownArrows = NO;
    _hideCharacters = YES;
    [self _parseOptions:options];
  }
  return self;
}

- (NSString *)processPickedString:(NSString *)string {
  return string;
}

/*
 {PICKCHAR:Field:Options}

 Options allow to convert picked character to be typed into drop-down-boxes.
 E.g. select digits or letters
 Options:
 
 ID=id (id for multiple pickchars in a field will not get processed
 Conv=D If set, convert values to down arrow presses
 Conv-Offset= Offset for conversion of characters, will be added to all arrow presses
 
 Conv-Fmt= Format of the check-box
 
  0 - Numbers 0129456789
  1 - NUmber 1234567890
  a - lowercase characters
  A - uppercase characters
  ? - skip combobox item
 
 -> combine for layout e.g. 0a or 0aA 0?aA
 */
- (void)_parseOptions:(NSString *)options {
  for(NSString *option in [options componentsSeparatedByString:kKPKPlaceholderPickCharsOptionDelemiter]) {
    NSArray <NSString *>*keyValuePair = [option componentsSeparatedByString:@"="];
    if(![self _parseOptionKeyValuePair:keyValuePair]) {
      NSLog(@"Invalid Option: %@", option);
      continue;
    };
  }
}

- (BOOL)_parseOptionKeyValuePair:(NSArray <NSString *> *)optionPair {
  if(optionPair.count != 2) {
    return NO;
  }
  NSString *key = [optionPair.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *option = [optionPair.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if(NSOrderedSame == [key compare:kKPKPlaceholderPickCharsOptionCount options:NSCaseInsensitiveSearch]
     || NSOrderedSame == [key compare:kKPKPlaceholderPickCharsOptionCountShort options:NSCaseInsensitiveSearch]) {
    NSScanner *scanner = [[NSScanner alloc] initWithString:option];
    NSInteger count;
    if([scanner scanInteger:&count]) {
      if(count != INT_MIN && count != INT_MAX) {
        self.pickCount = MAX(0,count);
        return YES;
      }
    }
    return NO;
  }
 /*
  FOUNDATION_EXPORT NSString *const kKPKPlaceholderPickCharsOptionConvertFormat;
  */
  if(NSOrderedSame == [key compare:kKPKPlaceholderPickCharsOptionHide options:NSCaseInsensitiveSearch]) {
    if(NSOrderedSame == [option compare:@"false" options:NSCaseInsensitiveSearch]) {
      self.hideCharacters = NO;
      return YES;
    }
    if(NSOrderedSame == [option compare:@"true" options:NSCaseInsensitiveSearch]) {
      self.hideCharacters = YES;
      return YES;
    }
    return NO;
  }
  if(NSOrderedSame == [key compare:kKPKPlaceholderPickCharsOptionConvert options:NSCaseInsensitiveSearch]) {
    if(NSOrderedSame == [option compare:@"D" options:NSCaseInsensitiveSearch]) {
      self.convertToDownArrows = YES;
      return YES;
    }
    return NO;
  }
  if(NSOrderedSame == [key compare:kKPKPlaceholderPickCharsOptionConvertOffset options:NSCaseInsensitiveSearch]) {
    NSScanner *scanner = [[NSScanner alloc] initWithString:option];
    NSInteger offset;
    if([scanner scanInteger:&offset]) {
      if(offset != INT_MIN && offset != INT_MAX) {
        self.checkboxOffset = MAX(0,offset);
        return YES;
      }
    }
    return NO;
  }
  if(NSOrderedSame == [key compare:kKPKPlaceholderPickCharsOptionConvertFormat options:NSCaseInsensitiveSearch]) {
    self.checkboxFormat = option;
    return YES;
  }
  return NO;
}

@end
