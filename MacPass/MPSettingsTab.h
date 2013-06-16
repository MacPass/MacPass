//
//  MPSettingsTabProtocoll.h
//  MacPass
//
//  Created by Michael Starke on 23.07.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Protrocoll to be implemented by ViewControllers that can be added to
 the settings windows. Tabs are orded as the controllers are included.
 */
@protocol MPSettingsTab <NSObject>

@required
- (NSString *)identifier;

@optional
- (NSString *)label;
- (NSImage *)image;

@end
