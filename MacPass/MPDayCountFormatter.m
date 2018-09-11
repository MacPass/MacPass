//
//  MPDayCountFormatter.m
//  MacPass
//
//  Created by Michael Starke on 15.10.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
