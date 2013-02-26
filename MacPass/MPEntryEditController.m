//
//  MPEntryEditController.m
//  MacPass
//
//  Created by michael starke on 21.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntryEditController.h"
#import "MPMainWindowController.h"

@interface MPEntryEditController ()

@property (assign) IBOutlet NSButton *cancelButton;

@end

@implementation MPEntryEditController

- (id)init {
  return [self initWithNibName:@"EntryEditView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)dealloc {
  self.selectedItem = nil;
  [super dealloc];
}

- (NSResponder *)reconmendedFirstResponder {
  return self.cancelButton;
}

#pragma mark Actions

- (IBAction)save:(id)sender {
  MPMainWindowController *controller = [[self.view window] windowController];
  [controller showEntries];
}

@end
