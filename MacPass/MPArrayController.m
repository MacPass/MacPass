//
//  MPArrayController.m
//  MacPass
//
//  Created by Michael Starke on 30/08/16.
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

#import "MPArrayController.h"
#import "MPModelChangeObserving.h"

@implementation MPArrayController

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
  if([keyPath hasPrefix:@"selection."]) {
    [self.observer willChangeModelProperty];
    [super setValue:value forKeyPath:keyPath];
    [self.observer didChangeModelProperty];
  }
  else {
    [super setValue:value forKeyPath:keyPath];
  }
}

@end
