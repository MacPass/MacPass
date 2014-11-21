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
@property (weak) NSOpenPanel *openPanel;
@property (strong) id openPanelTableHack;
@property (assign) BOOL allowAllFiles;

@end

@implementation MPDocumentController

- (instancetype)init {
  self = [super init];
  if(self) {
    _allowAllFiles = NO;
  }
  return self;
}

- (void)beginOpenPanel:(NSOpenPanel *)openPanel forTypes:(NSArray *)inTypes completionHandler:(void (^)(NSInteger))completionHandler {
  self.openPanel = openPanel;
  if(!self.accessoryView) {
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    NSArray *topLevelObjects;
    [myBundle loadNibNamed:@"OpenPanelAccessoryView" owner:self topLevelObjects:&topLevelObjects];
  }
  self.openPanel.accessoryView = self.accessoryView;
  [super beginOpenPanel:openPanel forTypes:inTypes completionHandler:completionHandler];
}

- (IBAction)toggleAllowAllFilesButton:(id)sender {
  NSButton *button = (NSButton *)sender;
  self.allowAllFiles = HNHBoolForState(button.state);
  self.openPanel.allowedFileTypes = self.allowAllFiles ? nil : @[MPLegacyDocumentUTI, MPXMLDocumentUTI];
  //[self _refreshOpenPanel];
}

- (NSString *)typeForContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing *)outError {
  NSString *detectedType = [[KPKFormat sharedFormat] typeForContentOfURL:url];
  if(nil != detectedType) {
    return detectedType;
  }
  return [super typeForContentsOfURL:url error:outError];
}

/*
 Hack is from http://stackoverflow.com/users/1564216/eidola at
 http://stackoverflow.com/questions/18192986/nsopenpanel-doesnt-validatevisiblecolumns
 */
#pragma mark NSOpenPanel Refresh Hack
- (id)_openPanelFindTable:(NSArray*)subviews; {
  id table;
  for(id view in subviews) {
    if([[view className] isEqualToString: @"FI_TListView"]) {
      table = view;
      break;
    }
    else {
      table = [self _openPanelFindTable:[view subviews]];
      if (table != nil) {
        break;
      }
    }
  }
  return table;
}


- (void)_refreshOpenPanel {
  if(self.openPanelTableHack == nil) {
    self.openPanelTableHack = [self _openPanelFindTable:[[self.openPanel contentView] subviews]];
  }
  [_openPanelTableHack reloadData];
  [_openPanel validateVisibleColumns];
}

@end
