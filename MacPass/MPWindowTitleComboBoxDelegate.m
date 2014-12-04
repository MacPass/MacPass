//
//  MPWindowTitleMenuDelegate.m
//  MacPass
//
//  Created by Michael Starke on 04/12/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
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
  NSArray *currentWindows = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID));
  NSMutableArray *windowTitles = [[NSMutableArray alloc] initWithCapacity:MAX(1,currentWindows.count)];
  for(NSDictionary *windowDict in currentWindows) {
    NSString *windowName = windowDict[(NSString *)kCGWindowName];
    if([windowName length] <= 0) {
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
