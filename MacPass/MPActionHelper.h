//
//  MPActionHelper.h
//  MacPass
//
//  Created by Michael Starke on 09.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MPActionType) {
  MPUnkownAction, // Neutral element to be used for returns
  MPActionAddEntry, // Add an new entry
  MPActionAddGroup, // Add a new group
  MPActionDuplicateEntry, // Simply duplicate an entry (including history)
  MPActionDuplicateEntryWithOptions, // Request user input on what to duplicate
  MPActionDuplicateGroup, // Duplicate the group and all it's children
  MPActionReverToHistoryEntry, // Restore an entry to an older state in history
  MPActionDelete, // Delete entry or group
  MPActionCopyUsername, // copy username to pasteboard
  MPActionCopyPassword, // copy password to pasteboard
  MPActionCopyCustomAttribute, // copy a custom attribute to the pasteboard
  MPActionCopyAsReference, // copy a reference to the attribute {REF:…} to the pasteboard
  MPActionCopyURL, // copy url to pasteboard
  MPActionOpenURL, // open url in default browser
  MPActionToggleInspector,
  MPActionLock, // show the lock screen
  MPActionEmptyTrash, // empties the trashcan, if there is one
  MPActionEditPassword, // change the database password
  MPActionDatabaseSettings, // Show the settings for the database
  MPActionEditTemplateGroup, // Edit the Template group
  MPActionExportXML, // Export as XML
  MPActionImportXML, // Import form XML
  MPActionToggleQuicklook,
  MPActionShowEntryHistory, // show history
  MPActionHideEntryHistory, // exit history
  MPActionShowGroupInOutline, // show the group (of the entry) in the outline view
  MPActionPerformAutotypeForSelectedEntry, // Perform Autotype for selected Entry
  MPActionRemoveAttachment // Remove an attachment
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
