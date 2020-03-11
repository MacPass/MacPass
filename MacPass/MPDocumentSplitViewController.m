//
//  MPDocumentSplitViewController.m
//  MacPass
//
//  Created by Michael Starke on 31.01.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocumentSplitViewController.h"
#import "MPOutlineViewController.h"
#import "MPEntryViewController.h"
#import "MPInspectorViewController.h"
#import "MPSettingsHelper.h"

@interface MPDocumentSplitViewController ()

@property (strong) MPEntryViewController *entryViewController;
@property (strong) MPOutlineViewController *outlineViewController;
@property (strong) MPInspectorViewController *inspectorViewController;

@end

@implementation MPDocumentSplitViewController

- (NSNibName)nibName {
  return @"DocumentSplitView";
  
}

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    _outlineViewController = [[MPOutlineViewController alloc] init];
    _entryViewController = [[MPEntryViewController alloc] init];
    _inspectorViewController = [[MPInspectorViewController alloc] init];
  }
  return self;
}

- (void)viewWillLayout {
  self.splitView.autosaveName = @"SplitView";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.splitView.translatesAutoresizingMaskIntoConstraints = NO;
  
  NSSplitViewItem *outlineItem = [NSSplitViewItem sidebarWithViewController:self.outlineViewController];
  outlineItem.holdingPriority = NSLayoutPriorityDefaultLow + 2;
  outlineItem.canCollapse = NO;
  outlineItem.minimumThickness = 150;
  NSSplitViewItem *entries = [NSSplitViewItem splitViewItemWithViewController:self.entryViewController];
  entries.canCollapse = NO;
  entries.minimumThickness  = 150;
  NSSplitViewItem *inspector = [NSSplitViewItem splitViewItemWithViewController:self.inspectorViewController];
  inspector.canCollapse = YES;
  inspector.minimumThickness = 200;
  inspector.holdingPriority = NSLayoutPriorityDefaultLow + 1;
  
  [self addSplitViewItem:outlineItem];
  [self addSplitViewItem:entries];
  [self addSplitViewItem:inspector];

  BOOL showInspector = [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyShowInspector];
  inspector.collapsed = !showInspector;
}

- (void)registerNotificationsForDocument:(MPDocument *)document {
  
  [self.entryViewController registerNotificationsForDocument:document];
  [self.outlineViewController registerNotificationsForDocument:document];
  [self.inspectorViewController registerNotificationsForDocument:document];
}

- (void)showOutline {
  // FIXME: do not require this to be called directly
  [self.outlineViewController showOutline];
}

- (void)toggleInspector:(id)sender {
  NSSplitViewItem *inspector = [self splitViewItemForViewController:self.inspectorViewController];
  inspector.collapsed  = !inspector.collapsed;
  [NSUserDefaults.standardUserDefaults setBool:!inspector.collapsed forKey:kMPSettingsKeyShowInspector];
}

@end
