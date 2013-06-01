//
//  MPTextField.m
//  MacPass
//
//  Created by Michael Starke on 01.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPTextField.h"
#import "MPRoundedTextFieldCell.h"

@implementation MPTextField

+ (Class)cellClass {
  return [MPRoundedTextFieldCell class];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if(self) {
    MPRoundedTextFieldCell *newCell = [[MPRoundedTextFieldCell alloc] init];
    NSTextFieldCell *cell = [self cell];
    [newCell setBackgroundStyle:[cell backgroundStyle]];
    [newCell setBezeled:[cell isBezeled]];
    [newCell setBordered:[cell isBordered]];
    [newCell setBackgroundColor:[cell backgroundColor]];
    [newCell setTextColor:[cell textColor]];
    [newCell setDrawsBackground:[cell drawsBackground]];
    [newCell setAction:[cell action]];
    [newCell setTarget:[cell target]];
    [newCell setEditable:[cell isEditable]];
    [newCell setEnabled:[cell isEnabled]];
    [self setCell:newCell];
    [newCell release];
  }
  return self;
}

@end
