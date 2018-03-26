//
//  MPNumberFormatter.m
//  MacPass
//
//  Created by Michael Starke on 24/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
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

#import "MPNumberFormatter.h"

@implementation MPNumberFormatter

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  self.minimum = [NSDecimalNumber one];
  self.formatterBehavior = NSNumberFormatterBehavior10_4;
  self.allowsFloats = NO;
  self.alwaysShowsDecimalSeparator = NO;
  return self;
}

- (BOOL)getObjectValue:(out id __nullable * __nullable)obj forString:(NSString *)string errorDescription:(out NSString * __nullable * __nullable)error {
  /* If super can pase without an error, all is fine */
  if([super getObjectValue:obj forString:string errorDescription:error]) {
    return YES;
  }
  /* TODO adhere to minimum/maxiumum? */
  *obj = [self.minimum copy];
  return YES;
}


@end
