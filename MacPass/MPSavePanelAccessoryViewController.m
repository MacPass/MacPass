//
//  MPSavePanelAccessoryViewController.m
//  MacPass
//
//  Created by Michael Starke on 10.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPSavePanelAccessoryViewController.h"
#import "MPDocument.h"
#import "MPConstants.h"

#import "KeePassKit/KeePassKit.h"

@interface MPSavePanelAccessoryViewController ()
@property (readwrite, assign) KPKDatabaseType selectedVersion;
@end

@implementation MPSavePanelAccessoryViewController

- (NSString *)nibName {
  return @"SavePanelAccessoryView";
}

- (void)didLoadView {
  NSArray *types = [self.document writableTypesForSaveOperation:NSSaveOperation];
  NSMenu *menu = [[NSMenu alloc] init];
  for (NSString *uti in types ) {
    NSString *description = CFBridgingRelease(UTTypeCopyDescription((__bridge CFStringRef)(uti)));
    NSString *extension = [self.document fileNameExtensionForType:uti saveOperation:NSSaveOperation];
    NSString *title = [NSString stringWithFormat:@"%@ (%@)", description, extension];
    [menu addItemWithTitle:title action:@selector(setFileType:) keyEquivalent:@""];
    NSMenuItem *item = [[menu itemArray] lastObject];
    item.target =  self;
    item.representedObject = uti;
  }
  self.fileTypePopupButton.menu = menu;
  self.infoTextField.hidden = YES;
  [self updateView];
}

- (IBAction)setFileType:(id)sender {
  NSString *uti = self.fileTypePopupButton.selectedItem.representedObject;
  if([uti isEqualToString:MPLegacyDocumentUTI]) {
    self.selectedVersion = KPKDatabaseTypeBinary;
  }
  else if([uti isEqualToString:MPXMLDocumentUTI]) {
    self.selectedVersion = KPKDatabaseTypeXml;
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
  switch(self.document.versionForFileType) {
    case KPKDatabaseTypeBinary:
      [self.fileTypePopupButton selectItemAtIndex:1];
      break;
    case KPKDatabaseTypeXml:
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
  NSString *uti = [[self.fileTypePopupButton selectedItem] representedObject];
  BOOL showInfoText = (self.document.tree.minimumType == KPKDatabaseTypeXml && [uti isEqualToString:MPLegacyDocumentUTI]);
  self.infoTextField.hidden = !showInfoText;
}

@end
