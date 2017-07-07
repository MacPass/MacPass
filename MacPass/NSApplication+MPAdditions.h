//
//  NSApplication+MPAdditions.h
//  MacPass
//
//  Created by Michael Starke on 10/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSApplication (MPAdditions)

@property (copy, readonly) NSString *applicationName;
@property (copy, readonly, nullable) NSURL *applicationSupportDirectoryURL;

- (NSURL  * _Nullable)applicationSupportDirectoryURL:(BOOL)create;

@end

NS_ASSUME_NONNULL_END
