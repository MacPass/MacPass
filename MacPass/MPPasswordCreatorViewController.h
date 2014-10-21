//
//  PasswordCreatorView.h
//  MacPass
//
//  Created by Michael Starke on 31.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPViewController.h"

@interface MPPasswordCreatorViewController : MPViewController <NSTextFieldDelegate>

@property (copy, readonly) NSString *generatedPassword;
@property (weak) id closeTarget;
@property (assign) BOOL allowsEntryDefaults;

/**
 *  Should be called to reset the generator
 *
 *  @param sender sender of the action
 */
- (void)reset;

@end
