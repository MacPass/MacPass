//
//  MPIconSelectViewController.m
//  MacPass
//
//  Created by Michael Starke on 10.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
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

- (void)didLoadView {
  //[[self.imageButton cell] setBackgroundStyle:NSBackgroundStyleLowered];
  self.iconCollectionView.backgroundColors = @[[NSColor clearColor]];
  self.iconCollectionView.selectable = YES;
  self.iconCollectionView.allowsMultipleSelection = NO;
  self.iconCollectionView.content = [MPIconHelper databaseIcons];
}

- (IBAction)useDefault:(id)sender {
  KPKNode *node = self.representedObject;
  [self.document willChangeModelProperty];
  node.iconId = [[node class] defaultIcon];
  [self.document didChangeModelProperty];
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
  [self.document willChangeModelProperty];
  node.iconId = newIconId;
  [self.document didChangeModelProperty];
  [self.view.window performClose:sender];
}


@end
