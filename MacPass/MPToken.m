//
//  MPToken.m
//  MacPass
//
//  Created by Michael Starke on 07.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPToken.h"

#import <KeePassKit/KeePassKit.h>
#import <Carbon/Carbon.h>

@interface NSString (MPTokenExtension)
@property (nonatomic, readonly) BOOL isOpenCurlyBraket;
@property (nonatomic, readonly) BOOL isClosingCurlyBraket;
@end

@implementation NSString (MPTokenExtension)

- (BOOL)isOpenCurlyBraket {
  return [self isEqualToString:@"{"];
}

- (BOOL)isClosingCurlyBraket {
  return [self isEqualToString:@"}"];
}

@end

@interface MPToken ()

@property (copy) NSString *value;

@end

typedef NS_ENUM(NSInteger, MPTokenizeState) {
  MPTokenizeStateNormal,
  MPTokenizeStateCompoundToken,
  MPTokenizerStateError
};

@implementation MPToken

/**
 *  Mapping for modifier to CGEventFlags.
 *
 *  @return dictionary with commands as keys and CGEventFlags as wrapped values
 */
+ (NSDictionary *)_modifierCommands {
  static NSDictionary *modifierCommands;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    modifierCommands = @{
                         kKPKAutotypeAlt : @(kCGEventFlagMaskAlternate),
                         kKPKAutotypeControl : @(kCGEventFlagMaskControl),
                         kKPKAutotypeShift : @(kCGEventFlagMaskShift)
                         };
  });
  return modifierCommands;
}

+ (NSArray<MPToken *> *)tokenizeString:(NSString *)string {
  if(!string) {
    return nil;
  }
  __block NSMutableString *tokenValue = [[NSMutableString alloc] init];
  __block MPTokenizeState state = MPTokenizeStateNormal;
  __block NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:MAX(1,string.length)];
  [string enumerateSubstringsInRange:NSMakeRange(0, string.length)
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                            switch(state) {
                              case MPTokenizeStateNormal: {
                                if(substring.isOpenCurlyBraket) {
                                  [tokenValue setString:@"{"];
                                  state = MPTokenizeStateCompoundToken;
                                }
                                else if(substring.isClosingCurlyBraket) {
                                  state = MPTokenizerStateError;
                                }
                                else {
                                  MPToken *token = [[MPToken alloc] initWithValue:substring];
                                  if(token) {
                                    [tokens addObject:token];
                                  }
                                  else {
                                    state = MPTokenizerStateError;
                                  }
                                }
                                break;
                              }
                              case MPTokenizeStateCompoundToken: {
                                if(substring.isOpenCurlyBraket) {
                                  state = MPTokenizerStateError;
                                }
                                else if(substring.isClosingCurlyBraket) {
                                  state = MPTokenizeStateNormal;
                                  [tokenValue appendString:@"}"];
                                  MPToken *token = [[MPToken alloc] initWithValue:tokenValue];
                                  if(token) {
                                    [tokens addObject:token];
                                  }
                                  else {
                                    state = MPTokenizerStateError;
                                  }
                                  /* clear tokenvalue */
                                  [tokenValue setString:@""];
                                }
                                else {
                                  [tokenValue appendString:substring];
                                }
                                break;
                              }
                              case MPTokenizerStateError:
                              default:
                                state = MPTokenizerStateError;
                                *stop = YES;
                                break;
                            }
                          }];
  return [tokens copy];
}

- (instancetype)init {
  self = [self initWithValue:@""];
  return self;
}

- (instancetype)initWithValue:(NSString *)value {
  if(!value) {
    [[NSException exceptionWithName:NSInvalidArgumentException reason:@"Token vale cannot be nil!" userInfo:nil] raise];
    self = nil;
    return self;
  }
  self = [super init];
  if(self) {
    _value = [value copy];
  }
  return self;
}

- (NSString *)description {
  return self.value.description;
}

@end
