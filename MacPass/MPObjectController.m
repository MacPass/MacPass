//
//  MPObjectController.m
//  MacPass
//
//  Created by Michael Starke on 18/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "MPObjectController.h"

@implementation MPObjectController

- (void)discardEditing {
  [super discardEditing];
}

- (BOOL)commitEditing {
  return [super commitEditing];
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
  NSLog(@"[%@ setValue:%@ forKeyPath:%@]", NSStringFromClass([self class]), value, keyPath);
  [super setValue:value forKeyPath:keyPath];
}

@end
