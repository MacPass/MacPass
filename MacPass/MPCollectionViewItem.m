//
//  MPCollectionViewItem.m
//  MacPass
//
//  Created by Michael Starke on 15.09.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPCollectionViewItem.h"
#import "MPIconSelectViewController.h"

@interface MPCollectionViewItem ()
@property (strong) IBOutlet NSButton *deleteImageButton;
@end

@implementation MPCollectionViewItem

@dynamic showDeleteIndicator;

- (void)viewDidLoad {
  self.showDeleteIndicator = NO;
}

- (void)setShowDeleteIndicator:(BOOL)showDeleteIndicator {
  self.deleteImageButton.hidden = !showDeleteIndicator;
}

- (BOOL)showDeleteIndicator {
  return !self.deleteImageButton.hidden;
}

@end
