//
//  MPIconHelper.m
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPIconHelper.h"

@implementation MPIconHelper

static NSDictionary *icons;

+ (NSImage *)icon:(MPIconType)type {
  if(!icons) {
    icons =   [MPIconHelper availableIconNames];
  }
  if([[icons allKeys] containsObject:@(type)]) {
    NSString *imageName = icons[@(type)];
    return [[NSBundle mainBundle] imageForResource:imageName];
  }
  return [NSImage imageNamed:NSImageNameActionTemplate];
}

+ (NSArray *)availableIcons {
  NSDictionary *imageNames = [MPIconHelper availableIconNames];
  NSMutableArray *icons = [[NSMutableArray alloc] initWithCapacity:[imageNames count]];
  for(NSNumber *iconNumber in [imageNames allKeys]) {
    MPIconType iconType = (MPIconType)[iconNumber integerValue];
    [icons addObject:[MPIconHelper icon:iconType]];
  }
  return icons;
}

+ (NSDictionary *)availableIconNames {
  NSDictionary *imageNames = @{
                               @(MPIconPassword): @"00_PasswordTemplate",
                               @(MPIconPackageNetwork): @"01_PackageNetworkTemplate",
                               @(MPIconWarning): @"02_MessageBoxWarningTemplate",
                               @(MPIconServer): @"03_ServerTemplate",
                               @(MPIconKlipper): @"04_KlipperTemplate",
                               @(MPIconLanguages): @"05_LanguagesTemplate",
                               
                               @(MPIconNotepad): @"07_NotepadTemplate",
                               @(MPIconSocket): @"08_SocketTemplate",
                               @(MPIconIdentity): @"09_IdentityTemplate",
                               @(MPIconContact): @"10_ContactTemplate",
                               @(MPIconCamera): @"11_CameraTemplate",
                               @(MPIconRemote): @"12_RemoteTemplate",

                               @(MPIconTrash): @"43_TrashTemplate",
                               @(MPIconFolder): @"48_FolderTemplate",
                               @(MPIconInfo): @"99_InfoTemplate",
                               @(MPIconAddFolder): @"99_AddFolderTemplate"
                               };
  return imageNames;
}

+ (NSImage *)randomIcon {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    srandom([[NSDate date] timeIntervalSince1970]);
  });
  
  NSArray *types = [[MPIconHelper availableIconNames] allKeys];
  NSUInteger randomIndex = random() % [types count];
  return [MPIconHelper icon:(MPIconType)randomIndex];
}

@end
