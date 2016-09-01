//
//  MPAutotypeBuilderViewController.m
//  MacPass
//
//  Created by Michael Starke on 01/09/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeBuilderViewController.h"
#import <KeePassKit/KeePassKit.h>

@interface MPAutotypeBuilderViewController ()

@property (weak) IBOutlet NSTokenField *tokenField;
@property (nonatomic, readonly, strong) NSArray<NSString *> *tokens;

@end

@implementation MPAutotypeBuilderViewController

#define _MPToken(short,long) [NSString stringWithFormat:@"%@ %@", short, long]

- (NSArray<NSString *> *)tokens {
  static NSArray *_tokens;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    for(NSString *attribute in [KPKFormat sharedFormat].entryDefaultKeys) {
      [fields addObject:[NSString stringWithFormat:@"{%@}", attribute]];
    }
    
    _tokens = [fields arrayByAddingObjectsFromArray:@[ _MPToken(kKPKAutotypeShortEnter, kKPKAutotypeEnter),
                                                       _MPToken(kKPKAutotypeShortAlt, kKPKAutotypeAlt),
                                                       _MPToken(kKPKAutotypeShortControl, kKPKAutotypeControl),
                                                       ]];
  });
  return _tokens;
}


- (NSString *)nibName {
  return @"AutotypeBuilderView";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tokenField.editable = NO;
  self.tokenField.objectValue = self.tokens;
}

@end
