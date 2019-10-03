//
//  NSApplication+MPAdditions.h
//  MacPass
//
//  Created by Michael Starke on 10/11/15.
//  Copyright © 2015 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class MPAppDelegate;

@interface NSApplication (MPAdditions)

@property (copy, readonly) NSString *applicationName;
@property (copy, readonly, nullable) NSURL *applicationSupportDirectoryURL;
@property (nullable, readonly, weak) MPAppDelegate *mp_delegate;
@property (readonly, nonatomic) BOOL isRunningTests;

- (NSURL *_Nullable)applicationSupportDirectoryURL:(BOOL)create;
- (void)relaunchAfterDelay:(CGFloat)seconds;
@end

NS_ASSUME_NONNULL_END
