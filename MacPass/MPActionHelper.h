//
//  MPActionHelper.h
//  MacPass
//
//  Created by Michael Starke on 09.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  MPActionAddEntry, // Add an new entry
  MPActionAddGroup, // Add a new group
  MPActionEdit, // Edit entry or group
  MPActionDelete, // Delete entry or group
  MPActionCopyUsername, // copy username to pasteboard
  MPActionCopyPassword, // copy password to pasteboard
  MPActionCopyURL, // copy url to pasteboard
  MPActionOpenURL, // open url in default browser
  MPActionToggleInspector,
  MPActionLock, // show the lock screen
}
MPActionType;

@interface MPActionHelper : NSObject

+ (SEL)actionOfType:(MPActionType)type;

@end
