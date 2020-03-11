//
//  MPDocumentSplitViewController.h
//  MacPass
//
//  Created by Michael Starke on 31.01.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class MPEntryViewController;
@class MPInspectorViewController;
@class MPOutlineViewController;
@class MPDocument;

@interface MPDocumentSplitViewController : NSSplitViewController

@property (readonly, strong) MPEntryViewController *entryViewController;
@property (readonly, strong) MPOutlineViewController *outlineViewController;
@property (readonly, strong) MPInspectorViewController *inspectorViewController;

- (void)registerNotificationsForDocument:(MPDocument *)document;
- (IBAction)toggleInspector:(id)sender;
- (void)showOutline;

@end

NS_ASSUME_NONNULL_END
