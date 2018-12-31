//
//  MPTouchBarButtonCreator.m
//  MacPass
//
//  Created by Veit-Hendrik Schlenker on 25.12.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import "MPTouchBarButtonCreator.h"

@implementation MPTouchBarButtonCreator

+ (NSTouchBarItem *) touchBarButtonWithTitle:(NSString *)title identifier:(NSTouchBarItemIdentifier)identifier target:(id)target selector:(SEL)selector customizationLabel:(NSString *)customizationLabel API_AVAILABLE(macos(10.12.2)){
  NSCustomTouchBarItem *item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
  NSButton *button = [NSButton buttonWithTitle:title target:target action:selector];
  item.view = button;
  item.customizationLabel = customizationLabel;
  return item;
}

+ (NSTouchBarItem *) touchBarButtonWithTitleAndImage:(NSString *)title identifier:(NSTouchBarItemIdentifier)identifier image:(NSImage *)image target:(id)target selector:(SEL)selector customizationLabel:(NSString *)customizationLabel API_AVAILABLE(macos(10.12.2)){
  NSCustomTouchBarItem *item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
  NSButton *button = [NSButton buttonWithTitle:title image:image target:target action:selector];
  item.view = button;
  item.customizationLabel = customizationLabel;
  return item;
}

+ (NSTouchBarItem *) touchBarButtonWithImage:(NSImage *)image identifier:(NSTouchBarItemIdentifier)identifier target:(id)target selector:(SEL)selector customizationLabel:(NSString *)customizationLabel API_AVAILABLE(macos(10.12.2)){
  NSCustomTouchBarItem *item = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
  NSButton *button = [NSButton buttonWithImage:image target:target action:selector];
  item.view = button;
  item.customizationLabel = customizationLabel;
  return item;
}

@end
