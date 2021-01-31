//
//  KPKBinary+MacPassAddtions.m
//  MacPass
//
//  Created by Michael Starke on 09.11.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "KPKBinary+MacPassAddtions.h"

@implementation KPKBinary (MacPassAddtions)

- (NSString *)filePromiseProvider:(NSFilePromiseProvider *)filePromiseProvider fileNameForType:(NSString *)fileType {
  return self.name;
}

- (void)filePromiseProvider:(NSFilePromiseProvider *)filePromiseProvider writePromiseToURL:(NSURL *)url completionHandler:(void (^)(NSError * _Nullable))completionHandler {
  NSError *error;
  [self saveToLocation:url error:&error];
  completionHandler(error);
}

@end
