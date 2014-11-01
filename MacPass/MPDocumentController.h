//
//  MPDocumentController.h
//  MacPass
//
//  Created by Michael Starke on 31.10.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPDocumentController : NSDocumentController <NSOpenSavePanelDelegate>

- (IBAction)toggleAllowAllFilesButton:(id)sender;

@end
