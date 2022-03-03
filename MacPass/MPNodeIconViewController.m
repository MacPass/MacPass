//
//  MPNodeIconViewController.m
//  MacPass
//
//  Created by Michael Starke on 02.03.22.
//  Copyright © 2022 HicknHack Software GmbH. All rights reserved.
//

#import "MPNodeIconViewController.h"
#import <KeePassKit/KeePassKit.h>

@interface MPNodeIconViewController ()

@end

@implementation MPNodeIconViewController

@synthesize isEditor = _isEditor;

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)setRepresentedObject:(id)representedObject {
  
}

- (KPKNode *)representedNode {
  if([self.representedObject isKindOfClass:KPKNode.class]) {
    return (KPKNode *)self.representedObject;
  }
  return nil;
}

/*
- (void)commitChanges {
  <#code#>
}

- (BOOL)commitEditingAndReturnError:(NSError *__autoreleasing  _Nullable * _Nullable)error {
  <#code#>
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
  <#code#>
}
*/

@end
