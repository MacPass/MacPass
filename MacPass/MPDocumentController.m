//
//  MPDocumentController.m
//  MacPass
//
//  Created by Michael Starke on 31.10.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//


#import "MPDocumentController.h"
#import "MPConstants.h"

#import "HNHCommon.h"

#import "KPKFormat.h"
#import "KPKFormat+MPUTIDetection.h"

@interface MPDocumentController ()

@property (strong) IBOutlet NSView *accessoryView;
@property (weak) IBOutlet NSButton *allowAllCheckBox;
@property (weak) IBOutlet NSButton *showHiddenCheckBox;

@property (weak) NSOpenPanel *openPanel;

@end

@implementation MPDocumentController

- (void)beginOpenPanel:(NSOpenPanel *)openPanel forTypes:(NSArray *)inTypes completionHandler:(void (^)(NSInteger))completionHandler {
  self.openPanel = openPanel;
  if(!self.accessoryView) {
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    NSArray *topLevelObjects;
    [myBundle loadNibNamed:@"OpenPanelAccessoryView" owner:self topLevelObjects:&topLevelObjects];
  }
  self.openPanel.allowedFileTypes = @[MPLegacyDocumentUTI, MPXMLDocumentUTI];
  self.allowAllCheckBox.state = NSOffState;
  self.showHiddenCheckBox.state = NSOffState;
  self.openPanel.accessoryView = self.accessoryView;
  [super beginOpenPanel:openPanel forTypes:inTypes completionHandler:completionHandler];
}

- (void)toggleAllowAllFiles:(id)sender {
  NSButton *button = (NSButton *)sender;
  BOOL allowAllFiles = HNHBoolForState(button.state);
  /* Toggle hidden to force a refresh */
  self.openPanel.showsHiddenFiles = !self.openPanel.showsHiddenFiles;
  self.openPanel.allowedFileTypes = allowAllFiles ? nil : @[MPLegacyDocumentUTI, MPXMLDocumentUTI];
  self.openPanel.showsHiddenFiles = !self.openPanel.showsHiddenFiles;
}

- (void)toggleShowHiddenFiles:(id)sender {
  self.openPanel.showsHiddenFiles = !self.openPanel.showsHiddenFiles;
}

- (NSString *)typeForContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing *)outError {
  NSString *detectedType = [[KPKFormat sharedFormat] typeForContentOfURL:url];
  if(nil != detectedType) {
    return detectedType;
  }
  return [super typeForContentsOfURL:url error:outError];
}

@end
