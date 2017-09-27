//
//  MPSavePanelAccessoryViewController.m
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

#import "MPSavePanelAccessoryViewController.h"
#import "MPDocument.h"
#import "MPConstants.h"

#import "KeePassKit/KeePassKit.h"

@interface MPSavePanelAccessoryViewController ()
@property (readwrite, assign) KPKDatabaseFormat selectedVersion;
@end

@implementation MPSavePanelAccessoryViewController

- (NSString *)nibName {
  return @"SavePanelAccessoryView";
}

- (void)viewDidLoad {
  NSArray *types = [self.document writableTypesForSaveOperation:NSSaveOperation];
  NSMenu *menu = [[NSMenu alloc] init];
  for (NSString *uti in types ) {
    NSString *description = CFBridgingRelease(UTTypeCopyDescription((__bridge CFStringRef)(uti)));
    NSString *extension = [self.document fileNameExtensionForType:uti saveOperation:NSSaveOperation];
    NSString *title = [NSString stringWithFormat:@"%@ (%@)", description, extension];
    [menu addItemWithTitle:title action:@selector(setFileType:) keyEquivalent:@""];
    NSMenuItem *item = menu.itemArray.lastObject;
    item.target =  self;
    item.representedObject = uti;
  }
  self.fileTypePopupButton.menu = menu;
  self.infoTextField.hidden = YES;
  [self updateView];
}

- (IBAction)setFileType:(id)sender {
  NSString *uti = self.fileTypePopupButton.selectedItem.representedObject;
  if([uti isEqualToString:MPKdbDocumentUTI]) {
    self.selectedVersion = KPKDatabaseFormatKdb;
  }
  else if([uti isEqualToString:MPKdbxDocumentUTI]) {
    self.selectedVersion = KPKDatabaseFormatKdbx;
  }
  NSAssert(uti != nil, @"UTI cannot be nil");
  [self _updateNote];
  self.savePanel.allowedFileTypes = @[uti];
}

- (void)setDocument:(MPDocument *)document {
  if(_document != document) {
    _document = document;
    [self updateView];
  }
}

- (void)updateView {
  /*
   Access view at least once to make sure it is properly loaded
   */
  NSView *view = self.view;
  NSAssert(view != nil, @"View has to be loaded at this point");
  switch(self.document.formatForFileType) {
    case KPKDatabaseFormatKdb:
      [self.fileTypePopupButton selectItemAtIndex:1];
      break;
    case KPKDatabaseFormatKdbx:
      [self.fileTypePopupButton selectItemAtIndex:0];
      break;
    default:
      NSAssert(NO, @"Minimum Version should always be valid");
      break;
  }
  [self setFileType:self.fileTypePopupButton];
  [self _updateNote];
}

- (void)_updateNote {
  NSString *uti = self.fileTypePopupButton.selectedItem.representedObject;
  BOOL showInfoText = ([uti isEqualToString:MPKdbDocumentUTI] &&
                       (self.document.tree.minimumVersion.format == KPKDatabaseFormatKdbx) &&
                       [self.document.fileType isEqualToString:MPKdbxDocumentUTI]);
  self.infoTextField.hidden = !showInfoText;
}

@end
