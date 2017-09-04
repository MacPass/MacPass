//
//  MPDuplicateEntryOptionsWindowController.m
//  MacPass
//
//  Created by Michael Starke on 08.06.17.
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

#import "MPDuplicateEntryOptionsWindowController.h"

@interface MPDuplicateEntryOptionsWindowController ()

@property BOOL referencePassword;
@property BOOL referenceUsername;
@property BOOL duplicateHistory;

@property (weak) IBOutlet NSButton *referenceUsernameCheckButton;
@property (weak) IBOutlet NSButton *referencePasswordCheckButton;
@property (weak) IBOutlet NSButton *duplicateHistoryCheckButton;

@end

@implementation MPDuplicateEntryOptionsWindowController

- (instancetype)initWithWindow:(NSWindow *)window {
  self = [super initWithWindow:window];
  if(self) {
    _referencePassword = NO;
    _referenceUsername = NO;
    _duplicateHistory = NO;
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    _referencePassword = NO;
    _referenceUsername = NO;
    _duplicateHistory = NO;
  }
  return self;
}

- (NSString *)windowNibName {
  return @"DuplicateEntryOptionsWindow";
}

- (void)windowDidLoad {
  [super windowDidLoad];
  [self.referencePasswordCheckButton bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(referencePassword)) options:nil];
  [self.referenceUsernameCheckButton bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(referenceUsername)) options:nil];
  [self.duplicateHistoryCheckButton bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(duplicateHistory)) options:nil];
}
- (IBAction)duplicateEntry:(id)sender {
  [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (IBAction)cancel:(id)sender {
  [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}

@end
