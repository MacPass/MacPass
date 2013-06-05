//
//  MPTextField.m
//  MacPass
//
//  Created by Michael Starke on 01.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPTextField.h"
#import "HNHRoundedTextFieldCell.h"

@implementation MPTextField

+ (Class)cellClass {
  return [HNHRoundedTextFieldCell class];
}

- (void)awakeFromNib {
  [[self class] setCellClass:[HNHRoundedTextFieldCell class]];
  if([[super class] instanceMethodForSelector:@selector(awakeFromNib)]) {
    [super awakeFromNib];
  }
}

@end
