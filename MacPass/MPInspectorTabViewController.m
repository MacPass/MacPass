//
//  MPInspectorTabViewController.m
//  MacPass
//
//  Created by Michael Starke on 05.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPInspectorTabViewController.h"

@interface MPInspectorTabViewController ()

@property (assign) IBOutlet NSImageView *itemImageView;
@property (assign) IBOutlet NSTextField *itemNameTextfield;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSSegmentedControl *tabControl;
@property (assign) NSUInteger selectedIndex;

@end

@implementation MPInspectorTabViewController

- (id)init {
  return [[MPInspectorTabViewController alloc] initWithNibName:@"InspectorTabView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      // init
    }
    return self;
}

- (void)didLoadView {
  //[self.tabView bind:NSSelectedIndexBinding toObject:self.tabControl withKeyPath:@"selectedIndex" options:nil];
  [self.tabControl bind:NSSelectedIndexBinding toObject:self withKeyPath:NSSelectedIndexBinding options:nil];
  [self.tabView bind:NSSelectedIndexBinding toObject:self withKeyPath:NSSelectedIndexBinding options:nil];
}

@end
