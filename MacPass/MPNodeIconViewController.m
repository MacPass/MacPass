//
//  MPNodeIconViewController.m
//  MacPass
//
//  Created by Michael Starke on 02.03.22.
//  Copyright © 2022 HicknHack Software GmbH. All rights reserved.
//

#import "MPNodeIconViewController.h"
#import <KeePassKit/KeePassKit.h>

#import "KPKNode+IconImage.h"

@interface MPNodeIconViewController ()
@property (strong) IBOutlet NSImageView *imageView;
@property (strong) IBOutlet NSTextField *textField;
@end

@implementation MPNodeIconViewController

@synthesize isEditor = _isEditor;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.imageView.cell.backgroundStyle = NSBackgroundStyleRaised;
  self.textField.placeholderString = NSLocalizedString(@"NO_TITLE", @"Fallback to items with no title");
}

- (void)setRepresentedObject:(id)representedObject {
  // FIXME: register for correct notifications
  if(self.representedNode) {
    KPKNode *node = self.representedNode;
    if(node.asEntry) {
      [NSNotificationCenter.defaultCenter removeObserver:self name:KPKWillChangeEntryNotification object:self.representedObject];
      [NSNotificationCenter.defaultCenter removeObserver:self name:KPKDidChangeEntryNotification object:self.representedObject];
    }
    else if(node.asGroup) {
      [NSNotificationCenter.defaultCenter removeObserver:self name:KPKWillChangeGroupNotification object:self.representedObject];
      [NSNotificationCenter.defaultCenter removeObserver:self name:KPKDidChangeGroupNotification object:self.representedObject];
    }
    else {
      NSLog(@"Inconsitant state for notification handling");
    }
  }
  super.representedObject = representedObject;
  if(self.representedNode) {
    KPKNode *node = self.representedNode;
    if(node.asEntry) {
      [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_willChangeNode:) name:KPKWillChangeEntryNotification object:self.representedObject];
      [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didChangeNode:) name:KPKDidChangeEntryNotification object:self.representedObject];
    }
    else if(node.asGroup) {
      [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_willChangeNode:) name:KPKWillChangeGroupNotification object:self.representedObject];
      [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didChangeNode:) name:KPKDidChangeGroupNotification object:self.representedObject];
    }
    else {
      NSLog(@"Inconsitant state for notification handling");
    }
  }
  [self _updateValues];
}

- (KPKNode *)representedNode {
  if([self.representedObject isKindOfClass:KPKNode.class]) {
    return (KPKNode *)self.representedObject;
  }
  return nil;
}

- (void)_updateValues {
  self.imageView.image = self.representedNode.iconImage;
  self.textField.stringValue = self.representedNode.title.length > 0 ? self.representedNode.title : @"";
}

- (void)commitChanges {
  // fixme
}


- (void)_willChangeNode:(NSNotification *)notification {
  
}

- (void)_didChangeNode:(NSNotification *)notification {
  [self _updateValues];
}
/*
- (BOOL)commitEditingAndReturnError:(NSError *__autoreleasing  _Nullable * _Nullable)error {
  <#code#>
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
  <#code#>
}
*/

@end
