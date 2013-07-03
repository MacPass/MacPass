//
//  MPIconSelectViewController.m
//  MacPass
//
//  Created by Michael Starke on 10.03.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPIconSelectViewController.h"
#import "MPIconHelper.h"

@interface MPIconSelectViewController ()

@end

@implementation MPIconSelectViewController


- (id)init {
  return [self initWithNibName:@"IconSelection" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
    }
    return self;
}

- (void)didLoadView {
  [self.iconCollectionView setSelectable:YES];
  [self.iconCollectionView setAllowsMultipleSelection:NO];
  [self.iconCollectionView setContent:[MPIconHelper availableIcons]];
}

- (IBAction)useDefault:(id)sender {
}
@end
