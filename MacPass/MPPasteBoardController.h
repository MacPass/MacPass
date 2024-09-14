//
//  MPPastBoardController.h
//  MacPass
//
//  Created by Michael Starke on 02.03.13.
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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MPPasteboardOverlayInfoType) {
  MPPasteboardOverlayInfoPassword,
  MPPasteboardOverlayInfoUsername,
  MPPasteboardOverlayInfoURL,
  MPPasteboardOverlayInfoTOTP,
  MPPasteboardOverlayInfoCustom, // overlay info that a custom field was copied
  MPPasteboardOverlayInfoReference // overlay info that a reference that was copied
};

typedef MPPasteboardOverlayInfoType MPPasteboardContentInfoType;

@interface MPPasteBoardContentInfo : NSObject

@property (readonly, strong) NSImage *image;
@property (readonly, strong) NSString *label;

+ (instancetype)contentInforForCustomField:(NSString *)name;
+ (instancetype)passwordContentInfo; // creates a content info approporate for passwords
+ (instancetype)urlContentInfo; // creates a content info apprpriate for urls

- (instancetype)initWithImage:(NSImage * _Nullable)image label:(NSString * _Nullable)label NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithType:(MPPasteboardContentInfoType)type;

@end

@interface MPPasteBoardController : NSObject

/**
 *  The PasteBoardController did copy new items to the pasteboard
 *  The userInfo dictionary is empty. You can obtain the timeout via the clearTimeout property
 */
FOUNDATION_EXPORT NSString *const MPPasteBoardControllerDidCopyObjects;
/**
 *  The PasteBoardController did clear the clipboard.
 *  The userInfo dictionary is empty
 */
FOUNDATION_EXPORT NSString *const MPPasteBoardControllerDidClearClipboard;

/**
 This time sets the time interval after which a copied entry should be purged from the pasteboard
 */
@property (assign, nonatomic) NSTimeInterval clearTimeout;
/**
 *  If set to YES, MacPass will clear the pastboard when it quits.
 */
@property (assign, nonatomic) BOOL clearPasteboardOnShutdown;
@property (class, strong, readonly) MPPasteBoardController *defaultController;

- (void)stashObjects;
- (void)restoreObjects;
- (void)copyObject:(id<NSPasteboardWriting>)objects;
- (void)copyObjectWithoutTimeout:(id<NSPasteboardWriting>)objects;

/**
 The pastboard controller will copy the object to the clipboard, display an appropriate overlay image
 and text and will set the clear time out if any is set. Additinally it will hide the application if
 the user has set this option. This call should always be used when a user is directly copying anything
 to the clipboard. If the clipboard is used internally (e.g. for autotype) you should call copyObjects:
 or even copyObjectsWithoutTimeout:
 
 @param object object so be copied
 @param overlayInfoType infotype discribing what is copied
 @param name a custom name
 @param view the view that initiated the copy action
 */
- (void)copyObject:(id<NSPasteboardWriting>)object overlayInfo:(MPPasteboardOverlayInfoType)overlayInfoType name:(NSString * _Nullable)name atView:(NSView *)view;
- (void)copyObject:(id<NSPasteboardWriting>)object contentInfo:(MPPasteBoardContentInfo *)info atView:(NSView *)view;

@end

NS_ASSUME_NONNULL_END
