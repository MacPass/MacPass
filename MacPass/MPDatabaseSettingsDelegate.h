//
//  MPDatabaseSettingsDelegate.h
//  MacPass
//
//  Created by Michael Starke on 21.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MPDatabaseSettingsDelegate <NSObject>

@optional
- (void)didCancelDatabaseSettings;
- (void)didSaveDatabaseSettings;

@end
