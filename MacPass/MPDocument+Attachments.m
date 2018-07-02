//
//  MPDocument+Attachments.m
//  MacPass
//
//  Created by Michael Starke on 05.07.13.
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

#import "MPDocument.h"

#import "KeePassKit/KeePassKit.h"

@implementation MPDocument (Attachments)

- (void)addAttachment:(NSURL *)location toEntry:(KPKEntry *)anEntry {
  NSError *error = nil;
  NSDictionary *resourceKeys = [location resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
  if([resourceKeys[ NSURLIsDirectoryKey ] boolValue] == YES ) {
    return; // We do not add whole directories
  }
  KPKBinary *binary = [[KPKBinary alloc] initWithContentsOfURL:location];
  if(binary) {
    [self willChangeModelProperty];
    [anEntry addBinary:binary];
    [self didChangeModelProperty];
  }
}

@end
