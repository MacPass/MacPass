//
//  MPOutlineViewController.h
//  MacPass
//
//  Created by michael starke on 19.02.13.
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

#import "MPViewController.h"
#import "MPTargetNodeResolving.h"

APPKIT_EXTERN NSString *const MPOutlineViewDidChangeGroupSelection;

@class MPDocument;
@class KPKGroup;

@interface MPOutlineViewController : MPViewController <MPTargetNodeResolving, NSOutlineViewDelegate, NSMenuDelegate>

- (void)clearSelection;
- (void)showOutline;
- (void)registerNotificationsForDocument:(MPDocument *)document;
- (void)selectGroup:(KPKGroup *)group;

/**
 *	Retrieves the current item for the current mouse location
 *	@return	Item under mouse. If the mouse isn't inside the view, nil is returned
 */
- (id)itemUnderMouse;

@end
