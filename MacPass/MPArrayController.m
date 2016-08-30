//
//  MPArrayController.m
//  MacPass
//
//  Created by Michael Starke on 30/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "MPArrayController.h"
#import "MPDocument.h"

@implementation MPArrayController


- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
  if([keyPath hasPrefix:@"selection."]) {
    [self.document willChangeModelProperty];
    [super setValue:value forKeyPath:keyPath];
    [self.document didChangeModelProperty];
  }
  else {
    [super setValue:value forKeyPath:keyPath];
  }
}

@end
