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

#import "KPKUTIs.h"
#import "KPKTree.h"

@interface MPSavePanelAccessoryViewController ()
@property (readwrite, assign) KPKVersion selectedVersion;
@end

@implementation MPSavePanelAccessoryViewController

- (id)init {
  self = [super initWithNibName:@"SavePanelAccessoryView" bundle:nil];
  if(self) {
  }
  return self;
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
    [item setTarget:self];
    [item setRepresentedObject:uti];
    
  }
  [self.fileTypePopupButton setMenu:menu];
  [self.infoTextField setHidden:YES];
  [self _updateView];
}

- (IBAction)setFileType:(id)sender {
  NSString *uti = [[self.fileTypePopupButton selectedItem] representedObject];
  if([uti isEqualToString:MPLegacyDocumentUTI]) {
    self.selectedVersion = KPKLegacyVersion;
  }
  else if([uti isEqualToString:MPLegacyDocumentUTI]) {
    self.selectedVersion = KPKXmlVersion;
  }
  BOOL showInfoText = (self.document.tree.minimumVersion == KPKLegacyVersion && [uti isEqualToString:MPLegacyDocumentUTI]);
  [self.infoTextField setHidden:!showInfoText];
  [self.savePanel setAllowedFileTypes:@[uti]];
}

- (void)setDocument:(MPDocument *)document {
  if(_document != document) {
    _document = document;
    [self _updateView];
  }
}

- (void)_updateView {
  switch(self.document.tree.minimumVersion) {
    case KPKLegacyVersion:
      [self.fileTypePopupButton selectItemAtIndex:1];
      break;
    case KPKXmlVersion:
      [self.fileTypePopupButton selectItemAtIndex:0];
      break;
    case KPKUnknownVersion:
      NSAssert(NO, @"Minimum Version should always be valid");
      break;
  }
}

@end
