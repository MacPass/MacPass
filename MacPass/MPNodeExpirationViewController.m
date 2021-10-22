//
//  MPNodeExpirationViewController.m
//  MacPass
//
//  Created by Michael Starke on 22.10.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//

#import "MPNodeExpirationViewController.h"
#import <KeePassKit/KeePassKit.h>

@interface MPNodeExpirationViewController ()

@property (nonatomic, readonly, strong) KPKTimeInfo *representedTimeInfo;

@end

@implementation MPNodeExpirationViewController

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)setRepresentedObject:(id)representedObject {
  /*if(self.representedTimeInfo) {
    [NSNotificationCenter.defaultCenter removeObserver:self name:KPKWillChangeTimeInfo object:self.representedTimeInfo];
    [NSNotificationCenter.defaultCenter removeObserver:self name:KPKDidChangeTimeInfo object:self.representedTimeInfo];
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
  _isDefaultAttribute = self.representedAttribute.isDefault;
  [self _updateValues];*/
}


- (void)_updateValues {
  
}

- (void)_willChangeTimeInfo:(NSNotification *)notification {
  
}
- (void)_didChangeTimeInfo:(NSNotification *)notification {
  
}

@end
