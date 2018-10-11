//
//  MPPluginBrowserTableCellView.m
//  MacPass
//
//  Created by Michael Starke on 11.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPPluginBrowserTableCellView.h"

@implementation MPPluginBrowserTableCellView

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
  super.backgroundStyle = backgroundStyle;
  switch(backgroundStyle) {
    case NSBackgroundStyleNormal:
    case NSBackgroundStyleLowered:
      self.statusTextField.textColor = NSColor.controlTextColor;
      break;
    case NSBackgroundStyleRaised:
    case NSBackgroundStyleEmphasized:
      self.statusTextField.textColor = NSColor.selectedControlTextColor;
      break;
  }
}

@end
