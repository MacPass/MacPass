//
//  MPObjectController.m
//  MacPass
//
//  Created by Michael Starke on 18/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "MPObjectController.h"

@interface MPObjectController ()
@property (strong) NSMutableSet *observedModelKeyPaths;
@end

@implementation MPObjectController

- (void)discardEditing {
  [super discardEditing];
}

- (BOOL)commitEditing {
  return [super commitEditing];
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
  BOOL observerd = NO;
  for(NSString *observedKeyPath in self.observedModelKeyPaths) {
    observerd = ([keyPath hasPrefix:observedKeyPath]);
    if(observerd) {
      break;
    }
  }
  if(observerd) {
    
  }
  [super setValue:value forKeyPath:keyPath];
}

- (void)didChangeModel {

}

- (void)willChangeModel {

}

- (void)beginObservingModelKeyPath:(NSString *)keyPath {
  [self.observedModelKeyPaths addObject:keyPath];
}

- (void)endObservingModelKeyPath:(NSString *)keyPath {
  [self.observedModelKeyPaths removeObject:keyPath];
}

@end
