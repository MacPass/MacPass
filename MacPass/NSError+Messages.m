//
//  NSError+Messages.m
//  MacPass
//
//  Created by Michael Starke on 04.09.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
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

#import "NSError+Messages.h"

NSString *const MPDefaultErrorDomain       = @"com.hicknhack.macpass.error";
NSString *const MPAutotypeErrorDomain      = @"com.hicknhack.macpass.error.autotype";

@implementation NSError (Messages)

- (NSString *)descriptionForErrorCode {
  return [NSString stringWithFormat:@"%@ (%ld)", self.localizedDescription, self.code ];
}

+ (NSError *)errorInDomain:(NSString *)domain withCode:(NSInteger)code description:(NSString *)description {
  return [[NSError alloc] initWithDomain:domain code:code userInfo:@{ NSLocalizedDescriptionKey: description }];
}

+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description {
  return [NSError errorInDomain:MPDefaultErrorDomain withCode:code description:description];

}
@end
