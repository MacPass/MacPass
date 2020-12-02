//
//  MPAutotypeCandidateSelectionViewController.m
//  MacPass
//
//  Created by Michael Starke on 26.10.17.
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
#import "MPAutotypeCandidateSelectionViewController.h"
#import "MPAutotypeContext.h"
#import "MPAutotypeDaemon.h"
#import "MPAutotypeEnvironment.h"
#import "MPExtendedTableCellView.h"

#import "KPKNode+IconImage.h"

#import <KeePassKit/KeePassKit.h>

@interface MPAutotypeCandidateSelectionViewController () <NSTableViewDataSource, NSTableViewDelegate>
@property (strong) IBOutlet NSButton *selectAutotypeContextButton;
@property (strong) IBOutlet NSTableView *contextTableView;
@property (strong) IBOutlet NSTextField *messageTextField;
@property (strong) IBOutlet NSImageView *targetApplicationImageView;
@end

@implementation MPAutotypeCandidateSelectionViewController

- (NSString *)nibName {
  return @"AutotypeCandidateSelectionView";
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.selectAutotypeContextButton.enabled = NO;

  NSRunningApplication *targetApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:self.environment.pid];
  if(nil != targetApplication) {
    self.targetApplicationImageView.image = [self _composeInfoImage];
  }
  
  NSString *template = @"";
  if(self.candidates.count > 1) {
    template = NSLocalizedString(@"AUTOTYPE_CANDIDATE_SELECTION_WINDOW_MESSAGE_%@_%@", "Message text in the autotype selection window. Placeholder is %1 - applicationName, %2 windowTitle");
    self.messageTextField.stringValue = [NSString stringWithFormat:template, targetApplication.localizedName, self.environment.windowTitle];
  }
  else {
    template = NSLocalizedString(@"AUTOTYPE_CANDIDATE_CONFIRMATION_WINDOW_MESSAGE_%@_%@", "Message text in the autotype confirmation window. Placeholder is %1 - applicationName, %2 windowTitle");
    self.messageTextField.stringValue = [NSString stringWithFormat:template, targetApplication.localizedName, self.environment.windowTitle];
  }

  NSNotification *notification = [NSNotification notificationWithName:NSTableViewSelectionDidChangeNotification object:self.contextTableView];
  [self tableViewSelectionDidChange:notification];
}

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return self.candidates.count;
}

#pragma mark NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  MPExtendedTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
  MPAutotypeContext *context = self.candidates[row];
  view.addionalTextField.stringValue = context.maskedEvaluatedCommand;
  view.textField.stringValue = context.entry.title;
  view.imageView.image = context.entry.iconImage;
  return view;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  NSTableView *tableView = notification.object;
  if(tableView != self.contextTableView) {
    return;
  }
  self.selectAutotypeContextButton.enabled = (self.contextTableView.selectedRow != -1);
}

#pragma mark Actions
- (void)selectAutotypeContext:(id)sender {
  NSInteger selectedRow = self.contextTableView.selectedRow;
  if(selectedRow >= 0 && selectedRow < self.candidates.count) {
    [MPAutotypeDaemon.defaultDaemon selectAutotypeContext:self.candidates[selectedRow] forEnvironment:self.environment];
  }
  else {
    [self cancelSelection:sender]; // cancel since the selection was invalid!
  }
}

- (void)cancelSelection:(id)sender {
  [MPAutotypeDaemon.defaultDaemon cancelAutotypeContextSelectionForEnvironment:self.environment];
}

- (NSImage *)_composeInfoImage {
  static const uint32_t iconSize = 64;
  uint32_t imageWidth = 256;
  uint32_t imageHeight = 256;
  
  NSRunningApplication *targetApplication = [NSRunningApplication runningApplicationWithProcessIdentifier:self.environment.pid];
  CGImageRef windowGrab = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, self.environment.windowId, kCGWindowImageDefault | kCGWindowImageBestResolution);
  NSImage *windowImage = [[NSImage alloc] initWithCGImage:windowGrab size:NSZeroSize];
  CFRelease(windowGrab);
  
  if(windowImage.size.width > windowImage.size.height) {
    imageHeight = imageWidth * (windowImage.size.height / windowImage.size.width);
  }
  else {
    imageWidth = imageWidth * (windowImage.size.width / windowImage.size.height);
  }
  
  if(!targetApplication.icon) {
    return windowImage;
  }
  
  NSImage *composite = [[NSImage alloc] initWithSize:NSMakeSize(MAX(imageWidth, iconSize), MAX(imageHeight, iconSize))];
  [composite lockFocus];
  /* draw the image at the top left */
  [windowImage drawInRect:NSMakeRect(composite.size.width - imageWidth, composite.size.height - imageHeight, imageWidth, imageHeight)
                 fromRect:NSZeroRect
                operation:NSCompositingOperationSourceOver
                 fraction:1];
  /* draw the app icon at the bottom left */
  [targetApplication.icon drawInRect:NSMakeRect(0, 0, iconSize, iconSize)
                            fromRect:NSZeroRect
                           operation:NSCompositingOperationSourceOver
                            fraction:1];
  [composite unlockFocus];
  return composite;
}

@end
