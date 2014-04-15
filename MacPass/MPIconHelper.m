//
//  MPIconHelper.m
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPIconHelper.h"

@implementation MPIconHelper

+ (NSImage *)icon:(MPIconType)type {
  static NSDictionary *icons;
  if(!icons) {
    icons = [MPIconHelper availableIconNames];
  }
  if([[icons allKeys] containsObject:@(type)]) {
    NSString *imageName = icons[@(type)];
    NSImage *image = [NSImage imageNamed:imageName];
    return image;
  }
  return [NSImage imageNamed:NSImageNameActionTemplate];
}

+ (NSArray *)databaseIcons {
  static NSArray *icons;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSDictionary *imageNames = [MPIconHelper availableIconNames];
    NSMutableArray *mutableIcons = [[NSMutableArray alloc] initWithCapacity:[imageNames count]];
      
    NSArray *sortedImageNames = [[imageNames allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
          return [[imageNames objectForKey:obj1] compare:[imageNames objectForKey:obj2]];
    }];
      
    for(NSNumber *iconNumber in sortedImageNames) {
      if([iconNumber integerValue] > MPCustomIconTypeBegin) {
        continue; // Skip all non-db Keys
      }
      MPIconType iconType = (MPIconType)[iconNumber integerValue];
      [mutableIcons addObject:[MPIconHelper icon:iconType]];
    }
    icons = mutableIcons;
  });
  return icons;
}


+ (NSArray *)databaseIconTypes {
    static NSArray *iconTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *imageNames = [MPIconHelper availableIconNames];
        NSMutableArray *mutableIcons = [[NSMutableArray alloc] initWithCapacity:[imageNames count]];
        
        NSArray *sortedImageNames = [[imageNames allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[imageNames objectForKey:obj1] compare:[imageNames objectForKey:obj2]];
        }];
        
        for(NSNumber *iconNumber in sortedImageNames) {
            if([iconNumber integerValue] > MPCustomIconTypeBegin) {
                continue; // Skip all non-db Keys
            }
            [mutableIcons addObject:iconNumber];
        }
        iconTypes = mutableIcons;
    });
    return iconTypes;
}


+ (NSDictionary *)availableIconNames {
  static NSDictionary *imageNames;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    imageNames = @{
                   @(MPIconPassword): @"00_PasswordTemplate",
                   @(MPIconPackageNetwork): @"01_PackageNetworkTemplate",
                   @(MPIconWarning): @"02_MessageBoxWarningTemplate",
                   @(MPIconServer): @"03_ServerTemplate",
                   @(MPIconKlipper): @"04_KlipperTemplate",
                   @(MPIconLanguages): @"05_LanguagesTemplate",
                   @(MPIconBlockDevice): @"06_BlockDeviceTemplate",
                   @(MPIconNotepad): @"07_NotepadTemplate",
                   @(MPIconSocket): @"08_SocketTemplate",
                   @(MPIconIdentity): @"09_IdentityTemplate",
                   @(MPIconContact): @"10_ContactTemplate",
                   @(MPIconCamera): @"11_CameraTemplate",
                   @(MPIconRemote): @"12_RemoteTemplate",
                   @(MPIconKeys): @"13_KeysTemplate",
                   @(MPIconBattery): @"14_BatteryTemplate",
                   @(MPIconScanner): @"15_ScannerTemplate",
                   @(MPIconBrowser): @"16_BrowserTemplate",
                   @(MPIconCDRom): @"17_CDRomTemplate",
                   @(MPIconDisplay): @"18_DisplayTemplate",
                   @(MPIconEmail): @"19_EmailTemplate",
                   @(MPIconMisc): @"20_MiscTemplate",
                   
                   @(MPIconFileSave): @"26_FileSaveTemplate",
                   
                   @(MPIconTerminal) : @"30_TerminalTemplate",
                   @(MPIconPrint) : @"31_PrintTemplate",
                   
                   @(MPIconTrash): @"43_TrashTemplate",
                   
                   @(MPIconFolder): @"48_FolderTemplate",
                   
                   @(MPIconPhone): @"68_PhoneTemplate",
                   
                   @(MPIconInfo): @"99_InfoTemplate",
                   @(MPIconAddFolder): @"99_AddFolderTemplate",
                   @(MPIconHardDisk): @"99_HarddiskTemplate",
                   @(MPIconCreated): @"99_CreatedTemplate",
                   @(MPIconAddEntry): @"addEntryTemplate",
                   @(MPIconContextTriangle): @"contextTriangleTemplate",
                   
                   @(MPIconExpiredEntry): NSImageNameCaution,
                   @(MPIconExpiredGroup): NSImageNameCaution
                   };
  });
  return imageNames;
}
@end
