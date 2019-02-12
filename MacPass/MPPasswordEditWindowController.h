//
//  MPPasswordEditWindowController.h
//  MacPass
//
//  Created by Michael Starke on 10.08.13.
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

#import <Cocoa/Cocoa.h>
#import <HNHUi/HNHUi.h>

@class MPDocument;
@class HNHUISecureTextField;

@protocol MPPasswordEditWindowDelegate <NSObject>

@optional
/**
 *	Get's called on dismissing the password editor.
 *	@param	changedPasswordOrKey	YES if the password and/or key was saved (not necessarily changed!);
 */
- (void)didFinishPasswordEditing:(BOOL)changedPasswordOrKey;

@end

@interface MPPasswordEditWindowController : HNHUISheetWindowController <NSTextFieldDelegate>

@property (weak) IBOutlet HNHUISecureTextField *passwordTextField;
@property (weak) IBOutlet HNHUISecureTextField *passwordRepeatTextField;
@property (weak) IBOutlet NSPathControl *keyfilePathControl;
@property (weak) IBOutlet NSButton *togglePasswordButton;
@property (weak) IBOutlet NSTextField *errorTextField;
@property (weak) IBOutlet NSButton *changePasswordButton;
@property (weak) IBOutlet NSButton *hasPasswordSwitchButton;

- (IBAction)clearKey:(id)sender;
- (IBAction)generateKey:(id)sender;


@end
