//
//  MPDocumentController.m
//  MacPass
//
//  Created by Michael Starke on 31.10.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocumentController.h"

#import "HNHCommon.h"

@interface MPDocumentController ()

@property (strong) IBOutlet NSView *accessoryView;
@property (weak) NSOpenPanel *openPanel;
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
  //self.openPanel.delegate = self;
  [super beginOpenPanel:openPanel forTypes:inTypes completionHandler:completionHandler];
}

- (IBAction)toggleAllowAllFilesButton:(id)sender {
  NSButton *button = (NSButton *)sender;
  self.openPanel.allowsOtherFileTypes = HNHBoolForState(button.state);
  self.allowAllFiles = HNHBoolForState(button.state);
}

#pragma mark NSOpenSavePanelDelegate
- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
  if(self.allowAllFiles) {
    return YES;
  }
  return NO;
}

@end
