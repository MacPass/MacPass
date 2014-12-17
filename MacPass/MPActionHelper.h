//
//  MPActionHelper.h
//  MacPass
//
//  Created by Michael Starke on 09.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MPActionType) {
  MPUnkownAction, // Neutral element to be used for returns
  MPActionAddEntry, // Add an new entry
  MPActionAddGroup, // Add a new group
  MPActionDuplicateEntry, // Simply duplicate an entry (inlcuding history)
  MPActionDuplicateEntryWithOptions, // Request user inptu on what to duplicate
  MPActionDelete, // Delete entry or group
  MPActionCopyUsername, // copy username to pasteboard
  MPActionCopyPassword, // copy password to pasteboard
  MPActionCopyURL, // copy url to pasteboard
  MPActionOpenURL, // open url in default browser
  MPActionToggleInspector,
  MPActionLock, // show the lock screen
  MPActionEmptyTrash, // empties the trashcan, if there is one
  MPActionEditPassword, // change the database password
  MPActionDatabaseSettings, // Show the settings for the database
  MPActionEditTemplateGroup, // Edit the Template group
  MPActionExportXML, // Exporte as XML
  MPActionImportXML, // Import form XML
  MPActionToggleQuicklook,
  MPActionShowHistory, // History anzeigen
  MPActionExitHistory, // History ausblenden
  MPActionPerformAutotypeForSelectedEntry // Perform Autotype for selected Entry
};
/**
 *	Helper to retrieve commonly used actions
 */
@interface MPActionHelper : NSObject
/**
 *	Call this to retrieve a selector for a common used action
 *	@param	type	The action type as MPActionType
 *	@return	selector for this action type
 */
+ (SEL)actionOfType:(MPActionType)type;
/**
 *	Helper to retrieve the MPActionType for a given selection
 *	@param	action	Selector to find the type for
 *	@return	MPActionTpype for action, if no match was found MPUnknownAction is returned
 */
+ (MPActionType)typeForAction:(SEL)action;
/**
 *  Returns the key equivalent for the given action type
 *  @param type Action to get the equivalent for
 *  @return NSString containing the key equivalent for this action. If none is present, an empty NString is returned
 */
+ (NSString *)keyEquivalentForAction:(MPActionType)type;

@end
