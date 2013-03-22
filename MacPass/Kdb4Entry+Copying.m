//
//  Kdb4Entry+Copying.m
//  MacPass
//
//  Created by Michael Starke on 18.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb4Entry+Copying.h"
#import "KdbEntry+Copying.h"

@implementation Kdb4Entry (Copying)

- (id)copyWithZone:(NSZone *)zone {
  Kdb4Entry *entry = [[Kdb4Entry allocWithZone:zone] init];
  entry.uuid = [[self.uuid copy] autorelease];
  entry.titleStringField = [[self.titleStringField copy] autorelease];
  entry.usernameStringField = [[self.usernameStringField copy] autorelease];
  entry.passwordStringField = [[self.passwordStringField copy] autorelease];
  entry.urlStringField = [[self.urlStringField copy] autorelease];
  entry.notesStringField = [[self.notesStringField copy] autorelease];
  entry.customIconUuid = self.customIconUuid;
  entry.foregroundColor = self.foregroundColor;
  entry.backgroundColor = self.backgroundColor;
  entry.overrideUrl = self.overrideUrl;
  entry.tags = self.tags;
  entry.locationChanged = self.locationChanged;
  //entry.stringFields = self.stringFields;
  //entry.binaries = self.binaries;
  entry.autoType = self.autoType;
  //entry.history = self.history;
  return entry;
}

@end
