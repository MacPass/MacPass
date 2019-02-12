//
//  MPIconHelper.m
//  MacPass
//
//  Created by Michael Starke on 17.02.13.
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

#import "MPIconHelper.h"
#import "KeePassKit/KeePassKit.h"

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
    NSMutableArray *mutableIcons = [[NSMutableArray alloc] initWithCapacity:imageNames.count];
    
    NSArray *sortedImageNames = [imageNames.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      return [imageNames[obj1] compare:imageNames[obj2]];
    }];
    
    for(NSNumber *iconNumber in sortedImageNames) {
      if(iconNumber.integerValue > MPCustomIconTypeBegin) {
        continue; // Skip all non-db Keys
      }
      MPIconType iconType = (MPIconType)iconNumber.integerValue;
      KPKIcon *icon = [[KPKIcon alloc] initWithImage:[MPIconHelper icon:iconType]];
      [mutableIcons addObject:icon];
    }
    icons = [mutableIcons copy];
  });
  return icons;
}


+ (NSArray *)databaseIconTypes {
  static NSArray *iconTypes;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSDictionary *imageNames = [MPIconHelper availableIconNames];
    
    NSArray *sortedImageNames = [[imageNames allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      return [[imageNames objectForKey:obj1] compare:[imageNames objectForKey:obj2]];
    }];
    iconTypes = [sortedImageNames filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
      NSNumber *iconNumber = (NSNumber *)evaluatedObject;
      return (iconNumber.integerValue < MPCustomIconTypeBegin);
    }]];
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
                   @(MPIconOrganizer): @"21_OrganizerTemplate",
                   @(MPIconASCII): @"22_ASCIITemplate",
                   @(MPIconIcons): @"23_IconsTemplate",
                   @(MPIconEstablishedConnection): @"24_EstablishedConnectionTemplate",
                   @(MPIconMailFolder): @"25_MailFolderTemplate",
                   @(MPIconFileSave): @"26_FileSaveTemplate",
                   @(MPIconNFSUnmount) :@"27_NFSUnmountTemplate",
                   @(MPIconQuickTime) : @"28_QuickTimeTemplate",
                   @(MPIconSecureTerminal) : @"29_SecureTerminalTemplate",
                   @(MPIconTerminal) : @"30_TerminalTemplate",
                   @(MPIconPrint) : @"31_PrintTemplate",
                   @(MPIconFileSystemView) : @"32_FileSystemViewTemplate",
                   @(MPIconRun) : @"33_RunTemplate",
                   @(MPIconConfigure) : @"34_ConfigureTemplate",
                   @(MPIconBrowserWindow) : @"35_BrowserWindowTemplate",
                   @(MPIconArchive) : @"36_ArchiveTemplate",
                   @(MPIconPercentage) : @"37_PercentageTemplate",
                   @(MPIconSambaUnmount) : @"38_SambaUnmountTemplate",
                   @(MPIconHistory) : @"39_HistoryTemplate",
                   @(MPIconFindMail) : @"40_FindMailTemplate",
                   @(MPIconVector) : @"41_VectorTemplate",
                   @(MPIconMemory) : @"42_MemoryTemplate",
                   @(MPIconTrash): @"43_TrashTemplate",
                   @(MPIconNotes) : @"44_NotesTemplate",
                   @(MPIconCancel) : @"45_CancelTemplate",
                   @(MPIconHelp) : @"46_HelpTemplate",
                   @(MPIconPackage) : @"47_PackageTemplate",
                   @(MPIconFolder): @"48_FolderTemplate",
                   @(MPIconFolderOpen) : @"49_FolderOpenTemplate",
                   @(MPIconFolderTar) : @"50_FolderTarTemplate",
                   @(MPIconDecrypted) : @"51_DecryptedTemplate",
                   @(MPIconEncrypted) : @"52_EncryptedTemplate",
                   @(MPIconApply) : @"53_ApplyTemplate",
                   @(MPIconSignature) : @"54_SignatureTemplate",
                   @(MPIconThumbnail) : @"55_ThumbnailTemplate",
                   @(MPIconAddressBook) : @"56_AddressBookTemplate",
                   @(MPIconTextView) : @"57_TextViewTemplate",
                   @(MPIconSecureAccount) : @"58_SecureAccountTemplate",
                   @(MPIconDevelopment) : @"59_DevelopmentTemplate",
                   @(MPIconHome) : @"60_HomeTemplate",
                   @(MPIconServices) : @"61_ServicesTemplate",
                   @(MPIconTux) : @"62_TuxTemplate",
                   @(MPIconFeather) : @"63_FeatherTemplate",
                   @(MPIconApple) : @"64_AppleTemplate",
                   @(MPIconWiki) : @"65_WikiTemplate",
                   @(MPIconMoney) : @"66_MoneyTemplate",
                   @(MPIconCertificat) : @"67_CertificatTemplate",
                   @(MPIconPhone): @"68_PhoneTemplate",
                   /* Custom */
                   @(MPIconInfo): @"infoTemplate",
                   @(MPIconAddFolder): @"addFolderTemplate",
                   @(MPIconHardDisk): @"harddiskTemplate",
                   @(MPIconCreated): @"createdTemplate",
                   @(MPIconAddEntry): @"addEntryTemplate",
                   @(MPIconContextTriangle): @"contextTriangleTemplate",
                   @(MPIconKeyboard): @"keyboardTemplate",
                   
                   @(MPIconExpiredEntry): NSImageNameCaution,
                   @(MPIconExpiredGroup): NSImageNameCaution
                   };
  });
  return imageNames;
}

+ (void)fetchIconDataForURL:(NSURL *)url completionHandler:(void (^)(NSData *iconData))handler {

  if(!url || !handler) {
    return; // no url, no handler so no need to do anything
  }

  NSString *urlString = [NSString stringWithFormat:@"%@://%@/favicon.ico", url.scheme, url.host ? url.host : @""];
  NSURL *favIconURL = [NSURL URLWithString:urlString];
  if(!favIconURL) {
    /* call the handler with nil data */
    handler(nil);
    return;
  }
  
  NSURLSessionTask *task = [NSURLSession.sharedSession dataTaskWithURL:favIconURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if(error) {
        handler(nil);
    }
    else if([response respondsToSelector:@selector(statusCode)]
            && (200 == [(id)response statusCode])
            && data.length > 0) {
        handler(data);
    }
    else {
        handler(nil);
    }
  }];
  [task resume];
}


@end
