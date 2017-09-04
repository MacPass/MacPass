//
//  MPWindowTitleMenuDelegate.m
//  MacPass
//
//  Created by Michael Starke on 04/12/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
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

#import "MPWindowTitleComboBoxDelegate.h"

@implementation MPWindowTitleComboBoxDelegate

- (void)comboBoxWillPopUp:(NSNotification *)notification {
  NSComboBox *comboBox = notification.object;
  if(!comboBox) {
    return;
  }
  [comboBox removeAllItems];
  [comboBox addItemsWithObjectValues:[self _currentWindowTitles]];
  comboBox.numberOfVisibleItems = MIN(5, comboBox.numberOfItems);
}

- (NSArray *)_currentWindowTitles {
  static NSArray *ownerSkipList;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ownerSkipList = @[ @"SystemUIServer", @"Window Server", @"Dock" ];
  });
  NSArray *currentWindows = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements, kCGNullWindowID));
  NSMutableArray *windowTitles = [[NSMutableArray alloc] initWithCapacity:MAX(1,currentWindows.count)];
  for(NSDictionary *windowDict in currentWindows) {
    NSString *windowName = windowDict[(NSString *)kCGWindowName];
    if(windowName.length <= 0) {
      continue; // No title, skip
    }
    NSString *ownerName = windowDict[(NSString *)kCGWindowOwnerName];
    if([ownerSkipList containsObject:ownerName]) {
      continue; // We do not want to insert some system windows (Dock, Menubars)
    }
    [windowTitles addObject:windowDict[(NSString *)kCGWindowName]];
  }
  return windowTitles;
}

@end
