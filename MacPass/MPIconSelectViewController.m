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

@interface MPIconSelectViewController () <NSCollectionViewDelegate>

/* UI properties */
@property (weak) IBOutlet NSCollectionView *iconCollectionView;
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
  //[self.iconCollectionView registerForDraggedTypes:@[(NSString *)kUTTypeURL, (NSString *)kUTTypeFileURL]];
  
  MPDocument *document = [NSDocumentController sharedDocumentController].currentDocument;
  self.iconCollectionView.content = document.tree.metaData.customIcons;
  self.iconCollectionView.content = [[MPIconHelper databaseIcons] arrayByAddingObjectsFromArray:document.tree.metaData.customIcons];
  
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
  [self.observer willChangeModelProperty];
  [self.observer didChangeModelProperty];
  [self.view.window performClose:sender];
}

- (IBAction)cancel:(id)sender {
  [self.view.window performClose:sender];
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
  NSLog(@"Index:%ld", index);
  return YES;
}

@end
