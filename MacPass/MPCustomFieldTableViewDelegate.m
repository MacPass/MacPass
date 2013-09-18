//
//  MPCustomFieldTableDelegate.m
//  MacPass
//
//  Created by Michael Starke on 17.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPCustomFieldTableViewDelegate.h"
#import "MPDocument.h"
#import "MPCustomFieldTableCellView.h"
#import "MPEntryInspectorViewController.h"

#import "KPKEntry.h"
#import "KPKAttribute.h"

@implementation MPCustomFieldTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  MPDocument *document = [[[tableView window] windowController] document];
  
  KPKEntry *entry = document.selectedEntry;
  MPCustomFieldTableCellView *view = [tableView makeViewWithIdentifier:@"SelectedCell" owner:tableView];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_customFieldFrameChanged:)
                                               name:NSViewFrameDidChangeNotification
                                             object:view];
  
  NSAssert([entry.customAttributes count] > row, @"Count of custom attributes must match row");
  KPKAttribute *attribute = entry.customAttributes[row];
  NSDictionary *validateOptions = @{ NSValidatesImmediatelyBindingOption: @YES };
  [view.labelTextField bind:NSValueBinding toObject:attribute withKeyPath:@"key" options:validateOptions];
  [view.valueTextField bind:NSValueBinding toObject:attribute withKeyPath:@"value" options:nil];
  [view.removeButton setTarget:self.viewController];
  [view.removeButton setAction:@selector(removeCustomField:)];
  [view.removeButton setTag:row];
  
  return view;
}

- (void)_customFieldFrameChanged:(NSNotification *)notification {
  // NSView *sender = [notification object];
  // NSLog(@"didChangeFrameFor: %@ to: %@", sender, NSStringFromRect([sender frame]));
}

@end
