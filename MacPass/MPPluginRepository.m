//
//  MPPluginRepository.m
//  MacPass
//
//  Created by Michael Starke on 04.12.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
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

#import "MPPluginRepository.h"
#import "MPConstants.h"
#import "MPPluginRepositoryItem.h"

const NSTimeInterval MPPluginRepositoryCacheTimeOut = 60*3; // 1 Minute cache time

@interface MPPluginRepository ()

@property NSTimeInterval lastPluginCheckTime;
@property BOOL didLoadData;

@end

@implementation MPPluginRepository

+ (instancetype)defaultRepository {
  static MPPluginRepository *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[MPPluginRepository alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if(self) {
    self.lastPluginCheckTime = NSDate.distantPast.timeIntervalSinceReferenceDate;
  }
  return self;
}

- (void)fetchRepositoryDataCompletionHandler:(void (^)(NSArray<MPPluginRepositoryItem *> * _Nonnull))completionHandler {
  NSString *urlString = NSBundle.mainBundle.infoDictionary[MPBundlePluginRepositoryURLKey];
  if(!urlString) {
    if(completionHandler) {
      completionHandler(@[]);
    }
    return;
  }
  NSURL *jsonURL = [NSURL URLWithString:urlString];
  if(!jsonURL) {
    if(completionHandler) {
      completionHandler(@[]);
    }
    return;
  }
  
  NSURLSessionTask *downloadTask = [NSURLSession.sharedSession dataTaskWithURL:jsonURL completionHandler:^(NSData * _Nullable jsonData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if(![response isKindOfClass:NSHTTPURLResponse.class]) {
      if(completionHandler) {
        completionHandler(@[]);
      }
      return;
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if(httpResponse.statusCode != 200 || jsonData.length == 0) {
      if(completionHandler) {
        completionHandler(@[]);
      }
      return;
    }
    id jsonRoot = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if(!jsonRoot || ![jsonRoot isKindOfClass:NSArray.class]) {
      if(completionHandler) {
        completionHandler(@[]);
      }
      return;
    }
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for(id item in jsonRoot) {
      if(![item isKindOfClass:NSDictionary.class]) {
        continue;
      }
      MPPluginRepositoryItem *pluginItem = [MPPluginRepositoryItem pluginItemFromDictionary:item];
      if(pluginItem.isVaid) {
        [items addObject:pluginItem];
      }
    }
    if(completionHandler) {
      completionHandler([items copy]);
    }
  }];
  
  [downloadTask resume];
}

@end
