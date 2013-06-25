//
//  MPDocumentSettingsWindowController.m
//  MacPass
//
//  Created by Michael Starke on 26.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocumentSettingsWindowController.h"

@interface MPDocumentSettingsWindowController ()

@end

@implementation MPDocumentSettingsWindowController

- (id)init {
  return [self initWithWindowNibName:@"DocumentSettingsWindow"];
}

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
//      @property(nonatomic, copy) NSString *databaseName;
//      @property(nonatomic, retain) NSDate *databaseNameChanged;
//      @property(nonatomic, copy) NSString *databaseDescription;
//      @property(nonatomic, retain) NSDate *databaseDescriptionChanged;
//      @property(nonatomic, copy) NSString *defaultUserName;
//      @property(nonatomic, retain) NSDate *defaultUserNameChanged;
//
//      @property(nonatomic, assign) NSInteger maintenanceHistoryDays;
//      
//      @property(nonatomic, copy) NSString *color;
//      
//      @property(nonatomic, retain) NSDate *masterKeyChanged;
//      @property(nonatomic, assign) NSInteger masterKeyChangeRec;
//      @property(nonatomic, assign) NSInteger masterKeyChangeForce;
//      
//      @property(nonatomic, assign) BOOL protectTitle;
//      @property(nonatomic, assign) BOOL protectUserName;
//      @property(nonatomic, assign) BOOL protectPassword;
//      @property(nonatomic, assign) BOOL protectUrl;
//      @property(nonatomic, assign) BOOL protectNotes;
//      
//      @property(nonatomic, readonly) NSMutableArray *customIcons;
//      @property(nonatomic, assign) BOOL recycleBinEnabled;
//      @property(nonatomic, retain) UUID *recycleBinUuid;
//      @property(nonatomic, retain) NSDate *recycleBinChanged;
//      @property(nonatomic, retain) UUID *entryTemplatesGroup;
//      @property(nonatomic, retain) NSDate *entryTemplatesGroupChanged;
//      @property(nonatomic, assign) NSInteger historyMaxItems;
//      @property(nonatomic, assign) NSInteger historyMaxSize;
//      @property(nonatomic, retain) UUID *lastSelectedGroup;
//      @property(nonatomic, retain) UUID *lastTopVisibleGroup;
//      @property(nonatomic, readonly) NSMutableArray *binaries;
//      @property(nonatomic, readonly) NSMutableArray *customData;
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

@end
