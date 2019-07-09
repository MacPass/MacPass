//
//  MPAppDelegate.h
//  MacPass
//
//  Created by Michael Starke on 19.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
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

APPKIT_EXTERN NSString *const MPDidChangeStoredKeyFilesSettings;

@class MPEntryContextMenuDelegate;

@interface MPAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>

@property (strong) IBOutlet NSMenuItem *saveMenuItem;
@property (strong) IBOutlet NSMenuItem *fixAutotypeMenuItem;
@property (strong) IBOutlet NSMenuItem *fileNewMenuItem;
@property (strong) IBOutlet NSMenu *itemMenu;
@property (strong) IBOutlet NSMenu *importMenu;

@property (strong, readonly) MPEntryContextMenuDelegate *itemActionMenuDelegate;

@property (nonatomic, assign) BOOL isAllowedToStoreKeyFile;

- (IBAction)checkForUpdates:(id)sender;
- (IBAction)showPreferences:(id)sender;
- (IBAction)showPluginPrefences:(id)sender;
- (IBAction)showPasswordCreator:(id)sender;
- (IBAction)showAutotypeDoctor:(id)sender;
- (IBAction)createNewDatabase:(id)sender;
- (IBAction)openDatabase:(id)sender;
- (IBAction)showHelp:(id)sender;
/**
 *  Clears the stored key files for any documents.
 *  @param sender sender of this action
 */
- (IBAction)clearRememberdKeyFiles:(id)sender;

- (void)lockAllDocuments;

- (void)showWelcomeWindow;
- (void)hideWelcomeWindow;

@end
