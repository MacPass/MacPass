//
//  MPGeneralDatabaseSettingsViewController.m
//  MacPass
//
//  Created by Michael Starke on 18.11.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//

#import "MPGeneralDatabaseSettingsViewController.h"

#import "MPDocument.h"

#import <KeePassKit/KeePassKit.h>

@interface MPGeneralDatabaseSettingsViewController ()

@property (weak) IBOutlet NSTextField *databaseNameTextField;
@property (weak) IBOutlet NSPopUpButton *databaseCompressionPopupButton;
@property (weak) IBOutlet NSTextView *databaseDescriptionTextView;
@property (weak) IBOutlet NSColorWell *databaseColorColorWell;
@property (weak) IBOutlet NSTextField *fileVersionTextField;

@end

@implementation MPGeneralDatabaseSettingsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
}

#pragma mark Private Helper
- (void)_setupView {
  MPDocument *document = (MPDocument *)self.view.window.windowController.document;

  KPKTree *tree = document.tree;
  
  if(!tree) {
    return; // nothing to read from
  }
  
  self.databaseNameTextField.stringValue = tree.metaData.databaseName;
  self.databaseDescriptionTextView.string = tree.metaData.databaseDescription;
  [self.databaseCompressionPopupButton selectItemAtIndex:tree.metaData.compressionAlgorithm];
  self.databaseColorColorWell.color = tree.metaData.color ? tree.metaData.color : NSColor.clearColor;
  
  
  NSData *fileData = [NSData dataWithContentsOfURL:document.fileURL];
  if(!fileData) {
    self.fileVersionTextField.stringValue = NSLocalizedString(@"UNKNOWN_FORMAT_FILE_NOT_SAVED_YET", "Database format is unknown since the file is not saved yet");
  }
  else {
    KPKFileVersion version = [[KPKFormat sharedFormat] fileVersionForData:fileData];
    NSDictionary *nameMappings = @{
                                   @(KPKDatabaseFormatKdb): @"Kdb",
                                   @(KPKDatabaseFormatKdbx): @"Kdbx",
                                   @(KPKDatabaseFormatUnknown): NSLocalizedString(@"UNKNOWN_FORMAT", "Unknown database format.")
                                   };
    
    NSUInteger mayor = (version.version >> 16);
    NSUInteger minor = (version.version & 0xFFFF);
    
    self.fileVersionTextField.stringValue = [NSString stringWithFormat:@"%@ (Version %ld.%ld)", nameMappings[@(version.format)], mayor, minor];
  }
}

@end
