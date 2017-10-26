//
//  MPDayCountFormatter.m
//  MacPass
//
//  Created by Michael Starke on 15.10.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPDayCountFormatter.h"

@implementation MPDayCountFormatter

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if(self) {
    [self _setupDefaults];
  }
  return self;
}

- (instancetype)init  {
  self = [super init];
  if(self) {
    [self _setupDefaults];
  }
  return self;
}

- (void)_setupDefaults {
  self.valueFormat = NSLocalizedString(@"%ld_DAYS", @"Display format for days. Should contain a long decimal placeholder!");
}

- (NSString *)stringForObjectValue:(id)obj {
  NSAssert([obj isKindOfClass:NSNumber.class], @"Unsupporded object class. Only NSNumber objects are allowed!");
  NSNumber *number = obj;
  return [NSString stringWithFormat:self.valueFormat, number.integerValue];
}

- (BOOL)getObjectValue:(out id  _Nullable __autoreleasing *)obj forString:(NSString *)string errorDescription:(out NSString *__autoreleasing  _Nullable *)error {
  NSAssert(NO,@"Value from string extraction not supported!");
  return NO;
}

@end
