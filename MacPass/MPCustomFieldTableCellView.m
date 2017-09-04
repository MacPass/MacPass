//
//  MPCustomFieldTableCellView.m
//  MacPass
//
//  Created by Michael Starke on 28.06.13.
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

#import "MPCustomFieldTableCellView.h"
#import "MPDocument.h"

@implementation MPCustomFieldTableCellView

- (void)objectDidBeginEditing:(id)editor {
  [self.window.windowController.document objectDidBeginEditing:editor];
}

- (void)objectDidEndEditing:(id)editor {
  [self.window.windowController.document objectDidEndEditing:editor];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
  super.backgroundStyle = NSBackgroundStyleLight;
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
  if([keyPath hasPrefix:@"objectValue."]) {
    [self.observer willChangeModelProperty];
    [super setValue:value forKeyPath:keyPath];
    [self.observer didChangeModelProperty];
  }
  else {
    [super setValue:value forKeyPath:keyPath];
  }
}

@end
