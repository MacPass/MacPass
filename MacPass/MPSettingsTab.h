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
 the settings windows. Tabs are ordered as the controllers are included.
 */
@protocol MPSettingsTab <NSObject>

@required
@property (readonly, copy) NSString *identifier;

@optional
- (NSString *)label;
- (NSImage *)image;
/* Called when the tab is about to be selected and displayed */
- (void)willShowTab;
/* Called when the tab was selected and is being displayed */
- (void)didShowTab;

@end
