//
//  MPTouchBarButtonCreator.m
//  MacPass
//
//  Created by Veit-Hendrik Schlenker on 25.12.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPTouchBarButtonCreator.h"

NSTouchBarCustomizationIdentifier MPTouchBarCustomizationIdentifierPasswordInput = @"com.hicknhacksoftware.MacPass.TouchBar.passwordInput";
NSTouchBarItemIdentifier MPTouchBarItemIdentifierChooseKeyfile = @"com.hicknhacksoftware.MacPass.TouchBar.passwordInput.chooseKeyfile";
NSTouchBarItemIdentifier MPTouchBarItemIdentifierShowPassword = @"com.hicknhacksoftware.MacPass.TouchBar.passwordInput.showPassword";
NSTouchBarItemIdentifier MPTouchBarItemIdentifierUnlock = @"com.hicknhacksoftware.MacPass.TouchBar.passwordInput.unlock";

NSTouchBarCustomizationIdentifier MPTouchBarCustomizationIdentifierDocument = @"com.hicknhacksoftware.MacPass.TouchBar.documentWindow";
NSTouchBarItemIdentifier MPTouchBarItemIdentifierSearch = @"com.hicknhacksoftware.MacPass.TouchBar.documentWindow.search";
NSTouchBarItemIdentifier MPTouchBarItemIdentifierEditPopover = @"com.hicknhacksoftware.MacPass.TouchBar.documentWindow.editPopover";
NSTouchBarItemIdentifier MPTouchBarItemIdentifierCopyUsername = @"com.hicknhacksoftware.MacPass.TouchBar.documentWindow.copyUsername";
NSTouchBarItemIdentifier MPTouchBarItemIdentifierCopyPassword = @"com.hicknhacksoftware.MacPass.TouchBar.documentWindow.copyPassword";
NSTouchBarItemIdentifier MPTouchBarItemIdentifierPerformAutotype = @"com.hicknhacksoftware.MacPass.TouchBar.documentWindow.performAutotype";
NSTouchBarItemIdentifier MPTouchBarItemIdentifierLock = @"com.hicknhacksoftware.MacPass.TouchBar.documentWindow.lock";

NSTouchBarItemIdentifier MPTouchBarItemIdentifierNewEntry = @"com.hicknhacksoftware.MacPass.TouchBar.documentWindow.newEntry";
NSTouchBarItemIdentifier MPTouchBarItemIdentifierNewGroup = @"com.hicknhacksoftware.MacPass.TouchBar.documentWindow.newGroup";
NSTouchBarItemIdentifier MPTouchBarItemIdentifierDelete = @"com.hicknhacksoftware.MacPass.TouchBar.documentWindow.delete";


@implementation MPTouchBarButtonCreator

+ (NSTouchBarItem *)touchBarButtonWithTitle:(NSString *)title identifier:(NSTouchBarItemIdentifier)identifier target:(id)target selector:(SEL)selector customizationLabel:(NSString *)customizationLabel API_AVAILABLE(macos(10.12.2)){
  NSCustomTouchBarItem *item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
  NSButton *button = [NSButton buttonWithTitle:title target:target action:selector];
  item.view = button;
  item.customizationLabel = customizationLabel;
  return item;
}

+ (NSTouchBarItem *)touchBarButtonWithTitleAndImage:(NSString *)title identifier:(NSTouchBarItemIdentifier)identifier image:(NSImage *)image target:(id)target selector:(SEL)selector customizationLabel:(NSString *)customizationLabel API_AVAILABLE(macos(10.12.2)){
  return [self touchBarButtonWithTitleAndImageAndColor:title identifier:identifier image:image color:nil target:target selector:selector customizationLabel:customizationLabel];
}

+ (NSTouchBarItem *)touchBarButtonWithTitleAndImageAndColor:(NSString *)title identifier:(NSTouchBarItemIdentifier)identifier image:(NSImage *)image color:(NSColor *)color target:(id)target selector:(SEL)selector customizationLabel:(NSString *)customizationLabel API_AVAILABLE(macos(10.12.2)){
  NSCustomTouchBarItem *item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
  NSButton *button = [NSButton buttonWithTitle:title image:image target:target action:selector];
  button.bezelColor = color;
  item.view = button;
  item.customizationLabel = customizationLabel;
  return item;
}

+ (NSTouchBarItem *)touchBarButtonWithImage:(NSImage *)image identifier:(NSTouchBarItemIdentifier)identifier target:(id)target selector:(SEL)selector customizationLabel:(NSString *)customizationLabel API_AVAILABLE(macos(10.12.2)){
  NSCustomTouchBarItem *item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
  NSButton *button = [NSButton buttonWithImage:image target:target action:selector];
  item.view = button;
  item.customizationLabel = customizationLabel;
  return item;
}

+ (NSPopoverTouchBarItem *)popoverTouchBarButton:(NSString *)title identifier:(NSTouchBarItemIdentifier)identifier popoverTouchBar:(NSTouchBar *)popoverTouchBar customizationLabel:(NSString *)customizationLabel API_AVAILABLE(macos(10.12.2)){
  NSPopoverTouchBarItem *item = [[NSPopoverTouchBarItem alloc] initWithIdentifier:identifier];
  item.collapsedRepresentationLabel = title;
  item.popoverTouchBar = popoverTouchBar;
  item.customizationLabel = customizationLabel;
  return item;
}

@end
