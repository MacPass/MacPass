//
//  MPEntryAttributeViewController.h
//  MacPass
//
//  Created by Michael Starke on 14.10.21.
//  Copyright © 2021 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HNHUi/HNHUi.h>
#import "MPInspectorEditor.h"


NS_ASSUME_NONNULL_BEGIN


/// View controller to show and edit KPKAttributes of KPKEntries.
/// Set the represented object to the KPKAttribute the editor shoudl show/edit
/// The editor can be set to edit or view
@interface MPEntryAttributeViewController : NSViewController <MPAttributeInspectorEditor, HNHUITextFieldDelegate>

@property (strong) IBOutlet NSTextField *keyTextField;
@property (strong) IBOutlet HNHUISecureTextField *valueTextField;
@property (strong) IBOutlet NSButton *toggleProtectedButton;
@property (strong) IBOutlet NSButton *removeButton;
@property (strong) IBOutlet NSButton *actionButton;

- (void)updateValuesAndEditing;
- (void)performCopyForText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
