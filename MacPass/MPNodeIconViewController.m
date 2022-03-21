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
@property (strong) IBOutlet NSButton *imageButton;
@property (strong) IBOutlet NSTextField *textField;
@property (copy) NSUUID *iconUUID;
@property NSUInteger iconId;
@end

@implementation MPNodeIconViewController

@synthesize isEditor = _isEditor;

- (void)viewDidLoad {
  [super viewDidLoad];
  //self.imageView.cell.backgroundStyle = NSBackgroundStyleRaised;
  [self.imageButton bind:NSImageBinding
              toObject:self
           withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(iconImage))]
                 options:@{NSConditionallySetsEnabledBindingOption: @NO}];
  [self.textField bind:NSValueBinding
              toObject:self
           withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(representedObject)), NSStringFromSelector(@selector(title))]
               options:@{NSNullPlaceholderBindingOption:NSLocalizedString(@"NO_TITLE", @"Fallback to items with no title")}];
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
  self.imageButton.enabled = self.isEditor;
}

@end
