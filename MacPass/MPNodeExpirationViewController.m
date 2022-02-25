//
//  MPNodeExpirationViewController.m
//  MacPass
//
//  Created by Michael Starke on 22.10.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//

#import "MPNodeExpirationViewController.h"
#import "MPInspectorViewController.h"
#import "MPValueTransformerHelper.h"
#import <KeePassKit/KeePassKit.h>

@interface MPNodeExpirationViewController ()

@property (nonatomic, readonly, strong) KPKTimeInfo *representedTimeInfo;
@property (strong) IBOutlet NSButton *expiredCheckButton;
@property (strong) IBOutlet NSButton *pickExpireDateButton;

@end

@implementation MPNodeExpirationViewController

@synthesize isEditor = _isEditor;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.pickExpireDateButton.action = @selector(pickExpiryDate:);
  [self _updateValues];
}

- (KPKTimeInfo *)representedTimeInfo {
  if([self.representedObject isKindOfClass:KPKTimeInfo.class]) {
    return self.representedObject;
  }
  return nil;
}

- (void)setRepresentedObject:(id)representedObject {
  if(self.representedTimeInfo) {
    [NSNotificationCenter.defaultCenter removeObserver:self name:KPKWillChangeTimeInfoNotification object:self.representedTimeInfo];
    [NSNotificationCenter.defaultCenter removeObserver:self name:KPKDidChangeTimeInfoNotification object:self.representedTimeInfo];
  }
  super.representedObject = representedObject;
  if(self.representedTimeInfo) {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:(@selector(_willChangeTimeInfo:))
                                               name:KPKWillChangeTimeInfoNotification
                                             object:self.representedTimeInfo];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:(@selector(_didChangeTimeInfo:))
                                               name:KPKDidChangeTimeInfoNotification
                                             object:self.representedTimeInfo];

  }
  [self _updateValues];
}

- (void)setIsEditor:(BOOL)isEditor {
  [self _updateValues];
}

- (void)commitChanges {
  // write back expiration changes
}

- (void)_updateValues {
  self.view.hidden = !self.representedTimeInfo.expires;
  self.expiredCheckButton.state = HNHUIStateForBool(self.representedTimeInfo.expires);
  NSValueTransformer *dateTransformer = [NSValueTransformer valueTransformerForName:MPExpiryDateValueTransformerName];
  self.expiredCheckButton.title = [dateTransformer transformedValue:self.representedTimeInfo.expirationDate];
  
  self.expiredCheckButton.enabled = self.isEditor;
  self.pickExpireDateButton.enabled = self.isEditor;
}

- (void)_willChangeTimeInfo:(NSNotification *)notification {}

- (void)_didChangeTimeInfo:(NSNotification *)notification {
  [self _updateValues];
}

@end
