//
//  MPTemporaryFileStorage.m
//  MacPass
//
//  Created by Michael Starke on 18/03/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
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

#import "MPTemporaryFileStorage.h"
#import "MPTemporaryFileStorageCenter.h"

#import "KeePassKit/KeePassKit.h"

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
    [MPTemporaryFileStorageCenter.defaultCenter registerStorage:self];
  }
  return self;
}

- (void)dealloc {
  [self cleanup];
  [MPTemporaryFileStorageCenter.defaultCenter unregisterStorage:self];
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
  NSString *fileName = [NSString stringWithFormat:@"%@_%@", NSProcessInfo.processInfo.globallyUniqueString, binary.name];
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
  NSString *path = self.temporaryFileURL.path;
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
  
  NSURL *srmURL = [NSURL fileURLWithPath:@"/usr/bin/srm"];
  NSURL *rmURL = [NSURL fileURLWithPath:@"/bin/rm"];
  
  if([srmURL checkResourceIsReachableAndReturnError:nil]) {
    task.launchPath = srmURL.path;
    task.arguments = @[@"-m", path];
  }
  else if([rmURL checkResourceIsReachableAndReturnError:nil]) {
    task.launchPath = rmURL.path;
    task.arguments= @[@"-P", path];
  }
  else {
    NSLog(@"Unable to retrieve remove command to whipe temporary file storage!");
    return;
  }
  [task launch];
  [task waitUntilExit];
}

@end
