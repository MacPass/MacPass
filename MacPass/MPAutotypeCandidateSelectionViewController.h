//
//  MPAutotypeCandidateSelectionViewController.h
//  MacPass
//
//  Created by Michael Starke on 26.10.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPAutotypeCandidateSelectionViewController : NSViewController

@property (copy) NSArray *candidates;

- (IBAction)selectAutotypeContext:(id)sender;
- (IBAction)cancelSelection:(id)sender;


@end
