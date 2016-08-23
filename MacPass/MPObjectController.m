//
//  MPObjectController.m
//  MacPass
//
//  Created by Michael Starke on 18/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import "MPObjectController.h"

@implementation MPObjectController

//- (void)objectDidBeginEditing:(id)editor {
//  NSLog(@"objectDidBeginEditing:%@", editor);
//  [super objectDidBeginEditing:editor];
//}
//- (void)objectDidEndEditing:(id)editor {
//  NSLog(@"objectDidEndEditing:%@", editor);
//  [super objectDidEndEditing:editor];
//}

- (void)discardEditing {
  [super discardEditing];
}

- (BOOL)commitEditing {
  return [super commitEditing];
}


//- (BOOL)commitEditing {
//  return [super commitEditing];
//}
//
//- (BOOL)commitEditingAndReturnError:(NSError * _Nullable __autoreleasing *)error {
//  return [super commitEditingAndReturnError:error];
//}
//
//- (void)commitEditingWithDelegate:(id)delegate didCommitSelector:(SEL)didCommitSelector contextInfo:(void *)contextInfo {
//  [super commitEditingWithDelegate:delegate didCommitSelector:didCommitSelector contextInfo:contextInfo];
//}

@end
