//
//  MPTemporaryFileStorage.m
//  MacPass
//
//  Created by Michael Starke on 18/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPTemporaryFileStorage.h"
#import "MPTemporaryFileStorageCenter.h"

#import "KPKBinary.h"

#import "NSError+Messages.h"

@interface MPTemporaryFileStorage ()

@property (strong) KPKBinary *binary;
@property (assign) BOOL loadScheduled;
@property (strong) NSURL *temporaryFileURL;

@end

@implementation MPTemporaryFileStorage

- (instancetype)initWithBinary:(KPKBinary *)binary {
  self = [super init];
  if(self) {
    _binary = binary;
    _loadScheduled = NO;
    [[MPTemporaryFileStorageCenter defaultCenter] registerStorage:self];
  }
  return self;
}

- (void)dealloc {
  [self cleanup];
  [[MPTemporaryFileStorageCenter defaultCenter] unregisterStorage:self];
}

- (void)cleanupNow {
  [self _cleanupBinary:YES];
}

- (void)cleanup {
  [self _cleanupBinary:NO];
}

#pragma mark -
#pragma mark QLPreviewPanelDataSource

- (id<QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index {
  if(!self.temporaryFileURL && !self.loadScheduled) {
    self.loadScheduled = YES;
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
      BOOL success = [self _saveBinary:self.binary];
      if(success){
        dispatch_async(dispatch_get_main_queue(), ^{
          [panel refreshCurrentPreviewItem];
        });
      }
    });
  }
  return self;
}

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {
  return 1;
}

#pragma mark -
#pragma mark QLPreviewItem

- (NSURL *)previewItemURL {
  return self.temporaryFileURL;
}

- (NSString *)previewItemTitle {
  return self.binary.name;
}

#pragma mark -
#pragma mark Private

- (BOOL)_saveBinary:(KPKBinary *)binary {
  if(!binary || !binary.data || !binary.name || [binary.name length] == 0) {
    return NO;
  }
  NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], binary.name];
  self.temporaryFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
  
  BOOL success = [binary.data writeToURL:self.temporaryFileURL options:0 error:0];
  if(!success) {
    self.temporaryFileURL = nil;
    return NO;
  }
  return YES;
}


- (void)_cleanupBinary:(BOOL)blockUntilDone {
  if(!self.temporaryFileURL) {
    return; // No URL to clean up
  }
  NSString *path = [self.temporaryFileURL path];
  if(blockUntilDone) {
    [MPTemporaryFileStorage _runCleanupForPath:path];
  }
  else {
    dispatch_queue_t lowQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(lowQueue, ^{
      [MPTemporaryFileStorage _runCleanupForPath:path];
    });
  }
  self.temporaryFileURL = nil;
}

+ (void)_runCleanupForPath:(NSString *)path {
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath:@"/usr/bin/srm"];
  [task setArguments:@[@"-m", path]];
  [task launch];
  [task waitUntilExit];
}

@end
