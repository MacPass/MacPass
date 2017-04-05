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

- (void)objectDidBeginEditing:(id)editor {
  [self.window.windowController.document objectDidBeginEditing:editor];
}

- (void)objectDidEndEditing:(id)editor {
  [self.window.windowController.document objectDidEndEditing:editor];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
  super.backgroundStyle = NSBackgroundStyleLight;
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
  if([keyPath hasPrefix:@"objectValue."]) {
    [self.observer willChangeModelProperty];
    [super setValue:value forKeyPath:keyPath];
    [self.observer didChangeModelProperty];
  }
  else {
    [super setValue:value forKeyPath:keyPath];
  }
}
@end
