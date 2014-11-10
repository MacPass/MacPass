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


NSInteger const kMPDefaultIcon = -1;

@interface MPIconSelectViewController ()

@property (nonatomic, assign) NSInteger selectedIcon;
@property (nonatomic, assign) BOOL didCancel;

/* UI properties */
@property (weak) IBOutlet NSCollectionView *iconCollectionView;
@property (weak) IBOutlet NSButton *imageButton;

@end

@implementation MPIconSelectViewController

- (NSString *)nibName {
  return @"IconSelection";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      _didCancel = YES;
      _selectedIcon = kMPDefaultIcon;
    }
    return self;
}

- (void)didLoadView {
  //[[self.imageButton cell] setBackgroundStyle:NSBackgroundStyleLowered];
  [self.iconCollectionView setBackgroundColors:@[[NSColor clearColor]]];
  [self.iconCollectionView setSelectable:YES];
  [self.iconCollectionView setAllowsMultipleSelection:NO];
  [self.iconCollectionView setContent:[MPIconHelper databaseIcons]];
}

- (IBAction)useDefault:(id)sender {
  self.didCancel = NO;
  self.selectedIcon = kMPDefaultIcon;
  [self.popover performClose:self];
}

- (IBAction)cancel:(id)sender {
  self.didCancel = YES;
  [self.popover performClose:self];
}

- (void)reset {
  self.didCancel = YES;
  self.selectedIcon = kMPDefaultIcon;
}

- (IBAction)_selectImage:(id)sender {
  self.didCancel = NO;
  NSButton *button = sender;
  NSImage *image = [button image];
  NSUInteger buttonIndex = [[self.iconCollectionView content] indexOfObject:image];
  self.selectedIcon = [[MPIconHelper databaseIconTypes] [buttonIndex] integerValue];
  [self.popover performClose:self];
}

@end
