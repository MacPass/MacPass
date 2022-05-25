//
//  MPHotkey.h
//  MacPass
//
//  Created by George Snow on 7.1.2022.
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

#import <Foundation/Foundation.h>

@class DDHotKey;
/**
 *  The hotkey  is responsible for registering the global hotkey and to to show/hide MacPass
 */
@interface MPHotkeyDaemon : NSObject

@property (strong) IBOutlet NSWindow *matchSelectionWindow;
@property (weak) IBOutlet NSPopUpButton *matchSelectionButton;
@property (readonly, strong) DDHotKey *registredHotKey;
@property (readonly, strong, class) MPHotkeyDaemon *hotkeyDaemon;


@end
