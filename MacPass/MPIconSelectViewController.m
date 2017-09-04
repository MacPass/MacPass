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

@interface MPIconSelectViewController ()

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
  self.iconCollectionView.content = [MPIconHelper databaseIcons];
}

- (IBAction)useDefault:(id)sender {
  KPKNode *node = self.representedObject;
  [self.observer willChangeModelProperty];
  node.iconId = [node.class defaultIcon];
  [self.observer didChangeModelProperty];
  [self.view.window performClose:sender];
}

- (IBAction)cancel:(id)sender {
  [self.view.window performClose:sender];
}

- (IBAction)_selectImage:(id)sender {
  NSButton *button = sender;
  NSImage *image = button.image;
  NSUInteger buttonIndex = [self.iconCollectionView.content indexOfObject:image];
  NSInteger newIconId = ((NSNumber *)[MPIconHelper databaseIconTypes][buttonIndex]).integerValue;
  KPKNode *node = self.representedObject;
  [self.observer willChangeModelProperty];
  node.iconId = newIconId;
  [self.observer didChangeModelProperty];
  [self.view.window performClose:sender];
}


@end
