//
//  MPTouchBarButtonCreator.h
//  MacPass
//
//  Created by Veit-Hendrik Schlenker on 25.12.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//
#import "MPPasswordInputController.h"

@interface MPTouchBarButtonCreator: NSObject

APPKIT_EXTERN NSTouchBarCustomizationIdentifier MPTouchBarCustomizationIdentifierPasswordInput;
APPKIT_EXTERN NSTouchBarItemIdentifier MPTouchBarItemIdentifierChooseKeyfile;
APPKIT_EXTERN NSTouchBarItemIdentifier MPTouchBarItemIdentifierShowPassword;
APPKIT_EXTERN NSTouchBarItemIdentifier MPTouchBarItemIdentifierUnlock;

APPKIT_EXTERN NSTouchBarCustomizationIdentifier MPTouchBarCustomizationIdentifierDocument;
APPKIT_EXTERN NSTouchBarItemIdentifier MPTouchBarItemIdentifierSearch;
APPKIT_EXTERN NSTouchBarItemIdentifier MPTouchBarItemIdentifierEditPopover;
APPKIT_EXTERN NSTouchBarItemIdentifier MPTouchBarItemIdentifierCopyUsername;
APPKIT_EXTERN NSTouchBarItemIdentifier MPTouchBarItemIdentifierCopyPassword;
APPKIT_EXTERN NSTouchBarItemIdentifier MPTouchBarItemIdentifierPerformAutotype;
APPKIT_EXTERN NSTouchBarItemIdentifier MPTouchBarItemIdentifierLock;

APPKIT_EXTERN NSTouchBarItemIdentifier MPTouchBarItemIdentifierNewEntry;
APPKIT_EXTERN NSTouchBarItemIdentifier MPTouchBarItemIdentifierNewGroup;
APPKIT_EXTERN NSTouchBarItemIdentifier MPTouchBarItemIdentifierDelete;


+ (NSTouchBarItem *)touchBarButtonWithTitle:(NSString *)title identifier:(NSTouchBarItemIdentifier)identifier target:(id)target selector:(SEL)selector customizationLabel:(NSString *)customizationLabel API_AVAILABLE(macos(10.12.2));

+ (NSTouchBarItem *)touchBarButtonWithTitleAndImage:(NSString *)title identifier:(NSTouchBarItemIdentifier)identifier image:(NSImage *)image target:(id)target selector:(SEL)selector customizationLabel:(NSString *)customizationLabel API_AVAILABLE(macos(10.12.2));

+ (NSTouchBarItem *)touchBarButtonWithTitleAndImageAndColor:(NSString *)title identifier:(NSTouchBarItemIdentifier)identifier image:(NSImage *)image color:(NSColor *)color target:(id)target selector:(SEL)selector customizationLabel:(NSString *)customizationLabel API_AVAILABLE(macos(10.12.2));

+ (NSTouchBarItem *)touchBarButtonWithImage:(NSImage *)image identifier:(NSTouchBarItemIdentifier)identifier target:(id)target selector:(SEL)selector customizationLabel:(NSString *)customizationLabel API_AVAILABLE(macos(10.12.2));

+ (NSPopoverTouchBarItem *)popoverTouchBarButton:(NSString *)title identifier:(NSTouchBarItemIdentifier)identifier popoverTouchBar:(NSTouchBar *)popoverTouchBar customizationLabel:(NSString *)customizationLabel API_AVAILABLE(macos(10.12.2));

@end
