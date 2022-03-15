//
//  MPNodeIconViewController.m
//  MacPass
//
//  Created by Michael Starke on 02.03.22.
//  Copyright © 2022 HicknHack Software GmbH. All rights reserved.
//

#import "MPNodeIconViewController.h"
#import <KeePassKit/KeePassKit.h>
#import "MPEntryInspectorViewController.h"

#import "KPKNode+IconImage.h"

@interface MPNodeIconViewController ()
@property (strong) IBOutlet NSImageView *imageView;
@property (strong) IBOutlet NSTextField *textField;
@property (copy) NSUUID *iconUUID;
@property NSUInteger iconId;
@end

@implementation MPNodeIconViewController

@synthesize isEditor = _isEditor;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.imageView.cell.backgroundStyle = NSBackgroundStyleRaised;
  self.textField.placeholderString = NSLocalizedString(@"NO_TITLE", @"Fallback to items with no title");
}

- (void)setRepresentedObject:(id)representedObject {
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
  [self _updateValueAndEditing];
}

- (KPKNode *)representedNode {
  if([self.representedObject isKindOfClass:KPKNode.class]) {
    return (KPKNode *)self.representedObject;
  }
  return nil;
}

- (void)setIsEditor:(BOOL)isEditor {
  _isEditor = isEditor;
  [self _updateValueAndEditing];
}

- (void)_updateValueAndEditing {
  self.imageView.enabled = self.isEditor;
  self.iconUUID = self.representedNode.iconUUID;
  self.iconId = self.representedNode.iconId;
  self.imageView.image = self.representedNode.iconImage;
  self.textField.stringValue = self.representedNode.title.length > 0 ? self.representedNode.title : @"";
}

- (void)commitChanges {
  self.representedNode.iconUUID = self.iconUUID;
  self.representedNode.iconId = self.iconId;
}

- (void)_willChangeNode:(NSNotification *)notification {
  
}

- (void)_didChangeNode:(NSNotification *)notification {
  [self _updateValueAndEditing];
}

@end
