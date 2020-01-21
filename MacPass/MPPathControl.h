//
//  MPPathControl.h
//  MacPass
//
//  Created by Michael Starke on 28.11.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

APPKIT_EXTERN NSString *const MPPathControlDidSetURLNotification;

@interface MPPathControl : NSPathControl <NSPathControlDelegate>

- (IBAction)showOpenPanel:(id _Nullable)sender;

@end

NS_ASSUME_NONNULL_END
