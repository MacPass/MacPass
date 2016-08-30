//
//  MPCustomFieldTableCellView.m
//  MacPass
//
//  Created by Michael Starke on 28.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPCustomFieldTableCellView.h"
#import "MPDocument.h"

@implementation MPCustomFieldTableCellView
- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
  super.backgroundStyle = NSBackgroundStyleLight;
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
  if([keyPath hasPrefix:@"objectValue."]) {
    [self.window.windowController.document willChangeModelProperty];
    [super setValue:value forKeyPath:keyPath];
    [self.window.windowController.document didChangeModelProperty];
  }
  [super setValue:value forKeyPath:keyPath];
}
@end
