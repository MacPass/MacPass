//
//  MPPluginTabelCellView.m
//  MacPass
//
//  Created by Michael Starke on 17.11.17.
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

#import "MPPluginTabelCellView.h"

@implementation MPPluginTabelCellView

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
  super.backgroundStyle = backgroundStyle;
  switch(backgroundStyle) {
    case NSBackgroundStyleNormal:
    case NSBackgroundStyleLowered:
      self.addionalTextField.textColor = NSColor.disabledControlTextColor;
      break;
    case NSBackgroundStyleRaised:
    case NSBackgroundStyleEmphasized:
      self.addionalTextField.textColor = NSColor.selectedControlTextColor;
      break;
  }
}

@end
