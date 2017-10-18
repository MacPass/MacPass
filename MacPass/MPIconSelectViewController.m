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

@interface MPIconSelectViewController () <NSCollectionViewDelegate>

/* UI properties */
@property (weak) IBOutlet MPCollectionView *iconCollectionView;
@property (weak) IBOutlet NSButton *imageButton;

@end

@implementation MPIconSelectViewController

- (NSString *)nibName {
  return @"IconSelection";
}

- (void)viewDidLoad {
  self.iconCollectionView.backgroundColors = @[NSColor.clearColor];
  self.iconCollectionView.selectable = YES;
  self.iconCollectionView.allowsMultipleSelection = NO;
  self.iconCollectionView.delegate = self;
  [self.iconCollectionView registerForDraggedTypes:@[(NSString *)kUTTypeURL, (NSString *)kUTTypeFileURL]];
  
  NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
  [menu addItem:[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DELETE", @"") action:@selector(deleteIcon:) keyEquivalent:@""]];
  self.iconCollectionView.menu = menu;
  
  [self _updateCollectionViewContent];
}

- (IBAction)useDefault:(id)sender {
  KPKNode *node = self.representedObject;
  [self.observer willChangeModelProperty];
  node.iconId = [node.class defaultIcon];
  node.iconUUID = nil;
  [self.observer didChangeModelProperty];
  [self.view.window performClose:sender];
}

- (IBAction)downloadIcon:(id)sender {
  KPKNode *node = self.representedObject;
  if(!node.asEntry) {
    return;
  }
  NSString *rawURL = node.asEntry.url;
  if([rawURL hasPrefix:@"http://"] || ![rawURL hasPrefix:@"https://"]) {
    rawURL = [@"https://" stringByAppendingString:rawURL];
  }
  
  NSURL *url = [NSURL URLWithString:rawURL];
  if(!url) {
    return;
  }
  
  NSString *urlString = [NSString stringWithFormat:@"%@://%@/favicon.ico", url.scheme, url.host ? url.host : @""];
  NSURL *favIconURL = [NSURL URLWithString:urlString];
  if(!favIconURL) {
    return;
  }
  
  KPKMetaData *metaData = ((MPDocument *)[NSDocumentController sharedDocumentController].currentDocument).tree.metaData;
  NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:favIconURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if(data) {
      dispatch_async(dispatch_get_main_queue(), ^{
        KPKIcon *newIcon = [[KPKIcon alloc] initWithImageData:data];
        if(newIcon) {
          [metaData addCustomIcon:newIcon];
          [self _updateCollectionViewContent];
        }
      });
    }
  }];
  [task resume];
}

- (void)deleteIcon:(id)sender {
  NSUInteger index = self.iconCollectionView.contextMenuIndex;
  NSUInteger firstCustomIndex = [MPIconHelper databaseIcons].count;
  if(index < firstCustomIndex) {
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
  [self.view.window performClose:sender];
}

- (void)didSelectCollectionViewItem:(id)sender {
  if(![sender isKindOfClass:[NSCollectionViewItem class]]) {
    return;
  }
  NSCollectionViewItem *item = sender;
  NSLog(@"selected item.frame: %@", NSStringFromRect(item.view.frame));
  //[self _selectIcon:item.representedObject];
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
  [self.view.window performClose:nil];
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
  MPDocument *document = [NSDocumentController sharedDocumentController].currentDocument;
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
