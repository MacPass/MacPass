//
//  MPArrayController.m
//  MacPass
//
//  Created by Michael Starke on 27/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "MPArrayController.h"

@implementation MPArrayController

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
  NSLog(@"%@ setValue:forKeyPath:%@", NSStringFromClass([self class]), keyPath);
  [super setValue:value forKeyPath:keyPath];
}

@end
