//
//  MPTreeDelegate.m
//  MacPass
//
//  Created by Michael Starke on 01/09/14.
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

#import "MPTreeDelegate.h"

#import "MPDocument.h"
#import "MPSettingsHelper.h"
#import "MPPickcharsViewController.h"
#import "MPPickfieldViewController.h"
#import "MPPickcharsParser.h"

@interface MPTreeDelegate ();

@property (weak) MPDocument *document;

@end

@implementation MPTreeDelegate

- (instancetype)initWithDocument:(MPDocument *)document {
  self = [super init];
  if(self) {
    self.document = document;
  }
  return self;
}

- (NSString *)defaultAutotypeSequenceForTree:(KPKTree *)tree {
  return [[NSUserDefaults standardUserDefaults] stringForKey:kMPSettingsKeyDefaultGlobalAutotypeSequence];
}

- (BOOL)shouldEditTree:(KPKTree *)tree {
  return !self.document.isReadOnly;
}

- (NSUndoManager *)undoManagerForTree:(KPKTree *)tree {
  return self.document.undoManager;
}

- (NSString *)tree:(KPKTree *)tree resolvePlaceholder:(NSString *)placeholder forEntry:(KPKEntry *)entry {
  if([placeholder isEqualToString:kKPKPlaceholderDatabasePath]) {
    return self.document.fileURL.path;
  }
  if([placeholder isEqualToString:kKPKPlaceholderDatabaseFolder]) {
    return self.document.fileURL.path;
  }
  if([placeholder isEqualToString:kKPKPlaceholderDatabaseBasename]) {
    return @"";
  }
  if([placeholder isEqualToString:kKPKPlaceholderDatabaseFileExtension]) {
    return self.document.fileURL.pathExtension;
  }
  if([placeholder isEqualToString:kKPKPlaceholderSelectedGroup]) {
    return self.document.selectedGroups.firstObject.title;
  }
  if([placeholder isEqualToString:kKPKPlaceholderSelectedGroupPath]) {
    return self.document.selectedGroups.firstObject.breadcrumb;
  }
  if([placeholder isEqualToString:kKPKPlaceholderSelectedGroupNotes]) {
    return self.document.selectedGroups.firstObject.notes;
  }
  return @"";
}

- (NSString *)tree:(KPKTree *)tree resolvePickFieldPlaceholderForEntry:(KPKEntry *)entry {
  MPPickfieldViewController *pickFieldViewController = [[MPPickfieldViewController alloc] init];
  
  pickFieldViewController.representedObject = entry;
  
  NSPanel *panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 100, 100)
                                              styleMask:NSWindowStyleMaskNonactivatingPanel|NSWindowStyleMaskTitled|NSWindowStyleMaskResizable
                                                backing:NSBackingStoreRetained
                                                  defer:YES];
  panel.level = NSScreenSaverWindowLevel;
  panel.contentViewController = pickFieldViewController;
  panel.title = NSLocalizedString(@"PICKFIELD_WINDOW_TITLE", @"Window displayed to the user to pick an amout of characters");
  [panel center];
  NSModalResponse response = [NSApp runModalForWindow:panel];
  [panel orderOut:nil];
  return (response == NSModalResponseOK) ? pickFieldViewController.pickedValue : @"";
}

- (NSString *)tree:(KPKTree *)tree resolvePickCharsPlaceholderForValue:(NSString *)value options:(NSString *)options {
  if(value.length == 0) {
    return @"";
  }
  MPPickcharsParser *parser = [[MPPickcharsParser alloc] initWithOptions:options];
  MPPickcharsViewController *pickCharViewController = [[MPPickcharsViewController alloc] init];
  
  pickCharViewController.sourceValue = value;
  pickCharViewController.minimumCharacterCount = parser.pickCount;
  pickCharViewController.hidePickedCharacters = parser.hideCharacters;
  
  NSPanel *panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 100, 100)
                                              styleMask:NSWindowStyleMaskNonactivatingPanel|NSWindowStyleMaskTitled|NSWindowStyleMaskResizable
                                                backing:NSBackingStoreRetained
                                                  defer:YES];
  panel.level = NSScreenSaverWindowLevel;
  panel.contentViewController = pickCharViewController;
  panel.title = NSLocalizedString(@"PICKCHAR_WINDOW_TITLE", @"Window displayed to the user to pick an amout of characters");
  [panel center];
  NSModalResponse response = [NSApp runModalForWindow:panel];
  [panel orderOut:nil];
  return (response == NSModalResponseOK) ? pickCharViewController.pickedValue : @"";
}
@end
