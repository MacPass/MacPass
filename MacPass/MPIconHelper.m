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
  NSDictionary *icons = [MPIconHelper availableIconNames];
  if(type >= [icons count]) {
    return [NSImage imageNamed:NSImageNameActionTemplate];
  }
  NSString *imageName = icons[@(type)];
  return [[NSBundle mainBundle] imageForResource:imageName];
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
                                @(MPIconSocket): @"08_SocketTemplate",
                                @(MPIconTrash): @"43_TrashTemplate",
                                @(MPIconInfo): @"99_InfoTemplate"
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
