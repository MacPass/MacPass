//
//  MPTreeDelegate.m
//  MacPass
//
//  Created by Michael Starke on 01/09/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPTreeDelegate.h"

#import "MPDocument.h"
#import "MPSettingsHelper.h"

@interface MPTreeDelegate ();

@property (weak) MPDocument *document;

@end


@implementation MPTreeDelegate

- (instancetype)initWithDocument:(MPDocument *)document {
  self = [super init];
  if(self) {
    self.document = document;
  }
  return self;
}

- (NSString *)defaultAutotypeSequenceForTree:(KPKTree *)tree {
  return [[NSUserDefaults standardUserDefaults] stringForKey:kMPSettingsKeyDefaultGlobalAutotypeSequence];
}

- (BOOL)shouldEditTree:(KPKTree *)tree {
  return !self.document.isReadOnly;
}

- (NSUndoManager *)undoManagerForTree:(KPKTree *)tree {
  return self.document.undoManager;
}

@end
