//
//  MPIconHelper.m
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPIconHelper.h"

@implementation MPIconHelper

# pragma mark Icon accessors
+ (NSImage *)icon:(MPIconType)type {
  NSDictionary *icons = [MPIconHelper availableIcons];
  NSString *imageName = icons[@(type)];
  return [[NSBundle mainBundle] imageForResource:imageName];
}

+ (NSDictionary *)availableIcons {
  NSDictionary *imageNames = @{ @(MPIconKlipper): @"04_KlipperTemplate",
                                @(MPIconLanguages): @"05_LanguagesTemplate",
                                @(MPIconPackageNetwork): @"01_PackageNetworkTemplate",
                                @(MPIconPassword): @"00_PasswordTemplate",
                                @(MPIconServer): @"03_ServerTemplate",
                                @(MPIconWarning): @"02_MessageBoxWarningTemplate",
                                @(MPIconCamera): @"11_CameraTemplate",
                                @(MPIconContact): @"10_ContactTemplate",
                                @(MPIconIdentity): @"09_IdentityTemplate",
                                @(MPIconNotepad): @"07_NotepadTemplate",
                                @(MPIconSocket): @"08_SocketTemplate"
                                };
  return imageNames;
}

@end
