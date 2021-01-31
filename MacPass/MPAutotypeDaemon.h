//
//  MPAutotypeDaemon.h
//  MacPass
//
//  Created by Michael Starke on 26.10.13.
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

#import <Foundation/Foundation.h>

@class DDHotKey;
@class KPKEntry;
@class MPAutotypeContext;
@class MPAutotypeEnvironment;
/**
 *  The autotype daemon is responsible for registering the global hotkey and to perform any autotype actions
 */
@interface MPAutotypeDaemon : NSObject

@property (strong) IBOutlet NSWindow *matchSelectionWindow;
@property (weak) IBOutlet NSPopUpButton *matchSelectionButton;
@property (readonly, strong) DDHotKey *registredHotKey;
@property (readonly, strong, class) MPAutotypeDaemon *defaultDaemon;

- (instancetype)init NS_UNAVAILABLE;

- (void)performAutotypeForEntry:(KPKEntry *)entry;
- (void)performAutotypeForEntry:(KPKEntry *)entry overrideSequence:(NSString *)sequence;
- (void)selectAutotypeContext:(MPAutotypeContext *)context forEnvironment:(MPAutotypeEnvironment *)environment;
- (void)cancelAutotypeContextSelectionForEnvironment:(MPAutotypeEnvironment *)environment;

@end
