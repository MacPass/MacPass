//
//  MPIconSelectViewController.m
//  MacPass
//
//  Created by Michael Starke on 10.03.13.
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

#import "MPIconSelectViewController.h"
#import "MPIconHelper.h"
#import "MPDocument.h"
#import "MPCollectionView.h"
#import "MPCollectionViewItem.h"

typedef NS_ENUM(NSInteger, MPIconDownloadStatus) {
  MPIconDownloadStatusNone,
  MPIconDownloadStatusProgress,
  MPIconDownloadStatusError
};

@interface MPIconSelectViewController () <NSCollectionViewDelegate>

/* UI properties */
@property (weak) IBOutlet NSColorWell *foregroundColorWell;
@property (weak) IBOutlet NSColorWell *backgroundColorWell;
@property (weak) IBOutlet MPCollectionView *iconCollectionView;
@property (weak) IBOutlet NSButton *imageButton;
@property (weak) IBOutlet NSButton *downloadIconButton;
@property (assign) MPIconDownloadStatus downloadStatus;

@end

@implementation MPIconSelectViewController

@dynamic downloadStatus;

- (NSString *)nibName {
  return @"IconSelection";
}

- (void)viewDidLoad {
  KPKNode *node = self.representedObject;
  self.downloadIconButton.enabled = (nil != node.asEntry);
  self.iconCollectionView.backgroundColors = @[NSColor.clearColor];
  self.iconCollectionView.selectable = YES;
  self.iconCollectionView.allowsMultipleSelection = NO;
  self.iconCollectionView.delegate = self;
  [self.iconCollectionView registerForDraggedTypes:@[(NSString *)kUTTypeURL, (NSString *)kUTTypeFileURL]];
  
  NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
  [menu addItem:[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DELETE", @"Menu item to delete the selected custom icon") action:@selector(deleteIcon:) keyEquivalent:@""]];
  self.iconCollectionView.menu = menu;
  
  KPKEntry *entry = [self.representedObject asEntry];
  if(entry) {
    self.foregroundColorWell.enabled = YES;
    self.foregroundColorWell.color = entry.foregroundColor ? entry.foregroundColor : NSColor.clearColor;
    self.backgroundColorWell.enabled = YES;
    self.backgroundColorWell.color = entry.backgroundColor ? entry.backgroundColor : NSColor.clearColor;
  }
  else {
    self.foregroundColorWell.enabled = NO;
    self.backgroundColorWell.enabled = NO;
  }
  
  [self _updateCollectionViewContent];
}

- (IBAction)useDefault:(id)sender {
  KPKNode *node = self.representedObject;
  [self.observer willChangeModelProperty];
  node.iconId = [node.class defaultIcon];
  node.iconUUID = nil;
  [self.observer didChangeModelProperty];
  [self dismissController:sender];
}

- (IBAction)downloadIcon:(id)sender {
  KPKNode *node = self.representedObject;
  if(!node.asEntry) {
    return;
  }
  [self _downloadIconForURL:node.asEntry.url];
}

- (void)setDownloadStatus:(MPIconDownloadStatus)status {
  switch (status) {
    case MPIconDownloadStatusNone:
      self.downloadIconButton.image = nil;
      break;
    case MPIconDownloadStatusError: {
      NSImage *image = [NSImage imageNamed:NSImageNameCaution];
      CGFloat scale = image.size.width / image.size.height;
      image.size = NSMakeSize(16 * scale, 16);
      self.downloadIconButton.image = image;
      break;
    }
    case MPIconDownloadStatusProgress: {
      NSImage *image = [NSImage imageNamed:NSImageNameRefreshTemplate];
      CGFloat scale = image.size.width / image.size.height;
      image.size = NSMakeSize(16 * scale, 16);
      self.downloadIconButton.image = image;
      break;
    }
  }
}

- (void)_downloadIconForURL:(NSString *)URLString {
  if([URLString hasPrefix:@"http://"] || ![URLString hasPrefix:@"https://"]) {
    URLString = [@"https://" stringByAppendingString:URLString];
  }
  
  NSURL *url = [NSURL URLWithString:URLString];
  KPKMetaData *metaData = ((MPDocument *)[NSDocumentController sharedDocumentController].currentDocument).tree.metaData;
  
  [MPIconHelper fetchIconDataForURL:url completionHandler:^(NSData *iconData) {
     if(!iconData || iconData.length == 0) {
      dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadStatus = MPIconDownloadStatusError;
      });
       return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      KPKIcon *newIcon = [[KPKIcon alloc] initWithImageData:iconData];
      if(newIcon && newIcon.image) {
        self.downloadStatus = MPIconDownloadStatusNone;
        [metaData addCustomIcon:newIcon];
        [self _updateCollectionViewContent];
      }
      else {
        self.downloadStatus = MPIconDownloadStatusError;
      }
    });
  }];
}

- (void)deleteIcon:(id)sender {
  NSUInteger index = self.iconCollectionView.contextMenuIndex;
  NSUInteger firstCustomIndex = [MPIconHelper databaseIcons].count;
  if(index < firstCustomIndex) {
    return;
  }
  if(index >= self.iconCollectionView.content.count) {
    return;
  }
  MPDocument *document = [NSDocumentController sharedDocumentController].currentDocument;
  KPKIcon *icon = self.iconCollectionView.content[index];
  [document.tree.metaData removeCustomIcon:icon];
  [self _updateCollectionViewContent];
}


- (void)_deleteIcon:(KPKIcon *)icon {
  NSUInteger iconIndex = [self.iconCollectionView.content indexOfObject:icon];
  
  if(iconIndex < [MPIconHelper databaseIcons].count) {
    return; // defautl icons cannot be delted
  }
  MPDocument *document = [NSDocumentController sharedDocumentController].currentDocument;
  [document.tree.metaData removeCustomIcon:icon];
  [self _updateCollectionViewContent];
}

- (IBAction)cancel:(id)sender {
  [self dismissController:sender];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  if(menuItem.action == @selector(deleteIcon:)) {
    NSUInteger index = self.iconCollectionView.contextMenuIndex;
    NSUInteger firstCustomIndex = [MPIconHelper databaseIcons].count;
    if(index < firstCustomIndex) {
      return NO;
    }
    if(index >= self.iconCollectionView.content.count) {
      return NO;
    }
    return YES;
  }
  return NO;
}

- (void)_selectIcon:(KPKIcon *)icon {
  KPKNode *node = self.representedObject;
  NSUInteger iconIndex = [self.iconCollectionView.content indexOfObject:icon];
  
  [self.observer willChangeModelProperty];
  /* Icon is Custom Icon */
  if(iconIndex >= [MPIconHelper databaseIcons].count) {
    node.iconUUID = icon.uuid;
  }
  else {
    NSInteger newIconId = ((NSNumber *)[MPIconHelper databaseIconTypes][iconIndex]).integerValue;
    node.iconId = newIconId;
    node.iconUUID = nil;
  }
  [self.observer didChangeModelProperty];
  [self dismissController:nil];
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id <NSDraggingInfo>)draggingInfo proposedIndex:(NSInteger *)proposedDropIndex dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation {
  *proposedDropIndex = MAX(0,self.iconCollectionView.content.count - 1);
  return NSDragOperationCopy;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id <NSDraggingInfo>)draggingInfo index:(NSInteger)index dropOperation:(NSCollectionViewDropOperation)dropOperation {
  NSPasteboard *pBoard = [draggingInfo draggingPasteboard];
  NSArray *urls = [pBoard readObjectsForClasses:@[NSURL.class] options:@{ NSPasteboardURLReadingFileURLsOnlyKey : @YES }];
  if(urls.count == 0) {
    return NO;
  }
  BOOL success = NO;
  MPDocument *document = NSDocumentController.sharedDocumentController.currentDocument;
  for(NSURL *url in urls) {
    KPKIcon *icon = [[KPKIcon alloc] initWithImageAtURL:url];
    if(icon.image) {
      [document.tree.metaData addCustomIcon:icon];
      success = YES;
    }
  }
  if(success) {
    [self _updateCollectionViewContent];
  }
  return success;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard {
  NSLog(@"dragStart for indexes:%@", indexes);
  [pasteboard declareTypes:@[(NSString *)kUTTypeText] owner:nil];
  return YES;
}

- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint dragOperation:(NSDragOperation)operation {
  
  if(nil == [self.view hitTest:screenPoint]) {
    NSLog(@"Delete Item!");
  }
  else {
    NSLog(@"Keep Item!");
  }
}

- (void)_updateCollectionViewContent {
  MPDocument *document = [NSDocumentController sharedDocumentController].currentDocument;
  self.iconCollectionView.content = [[MPIconHelper databaseIcons] arrayByAddingObjectsFromArray:document.tree.metaData.customIcons];
}

- (void)flagsChanged:(NSEvent *)theEvent {
  BOOL altDown = (0 != (theEvent.modifierFlags & NSEventModifierFlagOption));
  
  for(NSUInteger index = 0; index < self.iconCollectionView.content.count; index++) {
    MPCollectionViewItem *item = (MPCollectionViewItem *)[self.iconCollectionView itemAtIndex:index];
    item.showDeleteIndicator = altDown;
  }
  
}

@end
