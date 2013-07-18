//
//  MPCustomFieldTableDelegate.m
//  MacPass
//
//  Created by Michael Starke on 17.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPCustomFieldTableViewDelegate.h"
#import "MPInspectorViewController.h"
#import "MPCustomFieldTableCellView.h"

#import "Kdb4Node.h"
#import "StringField+Undo.h"

@implementation MPCustomFieldTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  if(![self.viewController.selectedEntry isKindOfClass:[Kdb4Entry class]]) {
    return nil;
  }
  Kdb4Entry *entry = (Kdb4Entry *)self.viewController.selectedEntry;
  MPCustomFieldTableCellView *view = [tableView makeViewWithIdentifier:@"SelectedCell" owner:tableView];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_customFieldFrameChanged:) name:NSViewFrameDidChangeNotification object:view];
  if([self.viewController.selectedEntry isKindOfClass:[Kdb4Entry class]]) {
    StringField *stringField = entry.stringFields[row];
    [view.labelTextField bind:NSValueBinding toObject:stringField withKeyPath:MPStringFieldKeyUndoableKey options:nil];
    [view.valueTextField bind:NSValueBinding toObject:stringField withKeyPath:MPStringFieldValueUndoableKey options:nil];
    [view.removeButton setTarget:self.viewController];
    [view.removeButton setAction:@selector(removeCustomField:)];
    [view.removeButton setTag:row];
  }
  return view;
}

- (void)_customFieldFrameChanged:(NSNotification *)notification {
  // NSView *sender = [notification object];
  // NSLog(@"didChangeFrameFor: %@ to: %@", sender, NSStringFromRect([sender frame]));
}

@end
