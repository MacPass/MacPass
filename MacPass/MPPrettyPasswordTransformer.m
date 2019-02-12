//
//  MPPrettyPasswordTransformer.m
//  MacPass
//
//  Created by Michael Starke on 01.12.17.
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

#import "MPPrettyPasswordTransformer.h"
#import "NSString+MPPrettyPasswordDisplay.h"

NSString *const MPPrettyPasswordTransformerName = @"com.hicknhack.macpass.MPPrettyPasswordTransformerName";

@implementation MPPrettyPasswordTransformer

+ (Class)transformedValueClass {
  return NSAttributedString.class;
}

+ (BOOL)allowsReverseTransformation {
  return YES;
}

+ (void)registerTransformer {
 MPPrettyPasswordTransformer *transformer = [[MPPrettyPasswordTransformer alloc] init];
  [NSValueTransformer setValueTransformer:transformer
                                  forName:MPPrettyPasswordTransformerName];
}

- (id)transformedValue:(id)value {
  if([value isKindOfClass:NSString.class]) {
    return ((NSString *)value).passwordPrettified;
  }
  if([value isKindOfClass:NSAttributedString.class]) {
    return ((NSAttributedString *)value).string;
  }
  return nil;
}


@end
