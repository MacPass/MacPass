//
//  MPDocumentController.m
//  MacPass
//
//  Created by Michael Starke on 31.10.14.
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


#import "MPDocumentController.h"
#import "MPConstants.h"
#import "MPSettingsHelper.h"
#import "MPAppDelegate.h"

#import "HNHUi/HNHUi.h"

#import "KeePassKit/KeePassKit.h"
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
  self.openPanel.allowedFileTypes = @[MPKdbDocumentUTI, MPKdbxDocumentUTI];
  self.allowAllCheckBox.state = NSOffState;
  self.showHiddenCheckBox.state = NSOffState;
  self.openPanel.accessoryView = self.accessoryView;
  [super beginOpenPanel:openPanel forTypes:inTypes completionHandler:completionHandler];
}

- (void)toggleAllowAllFiles:(id)sender {
  NSButton *button = (NSButton *)sender;
  BOOL allowAllFiles = HNHUIBoolForState(button.state);
  /* Toggle hidden to force a refresh */
  self.openPanel.showsHiddenFiles = !self.openPanel.showsHiddenFiles;
  self.openPanel.allowedFileTypes = allowAllFiles ? nil : @[MPKdbDocumentUTI, MPKdbxDocumentUTI];
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

- (void)addDocument:(NSDocument *)document {
  [((MPAppDelegate *)NSApp.delegate) hideWelcomeWindow];
  [super addDocument:document];
}

- (BOOL)reopenLastDocument {
  if(self.documents.count > 0) {
    return YES; // The document is already open
  }
  NSURL *documentUrl = nil;
  if(self.recentDocumentURLs.count > 0) {
    documentUrl = self.recentDocumentURLs.firstObject;
  }
  else {
    NSString *lastPath = [NSUserDefaults.standardUserDefaults stringForKey:kMPSettingsKeyLastDatabasePath];
    documentUrl =[NSURL URLWithString:lastPath];
  }
  BOOL isFileURL = documentUrl.fileURL;
  if(isFileURL) {
    [self openDocumentWithContentsOfURL:documentUrl
                                display:YES
                      completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
                        
                        if(error != nil){
                          NSAlert *alert = [[NSAlert alloc] init];
                          alert.messageText = NSLocalizedString(@"FILE_OPEN_ERROR", "Error while reopening last known documents");
                          alert.informativeText = error.localizedDescription;
                          alert.alertStyle = NSAlertStyleCritical;
                          [alert runModal];
                        }
                        
                        if(document == nil){
                          [(MPAppDelegate *)NSApp.delegate showWelcomeWindow];
                        }
                      }];
  }
  return isFileURL;
}

@end
