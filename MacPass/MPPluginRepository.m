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
#import "MPSettingsHelper.h"

NSString *const MPPluginRepositoryDidUpdateAvailablePluginsNotification = @"com.hicknhack.macpass.MPPluginRepositoryDidInitializeAvailablePluginsNotification";

@interface MPPluginRepository ()

@property (nonatomic, copy) NSArray<MPPluginRepositoryItem *> *availablePlugins;
@property NSTimeInterval lastDataFetchTime;
@property BOOL isInitialized;

@end

@implementation MPPluginRepository

@synthesize availablePlugins = _availablePlugins;

+ (NSSet<NSString *> *)keyPathsForValuesAffectingUpdatedAt {
  return [NSSet setWithObject:NSStringFromSelector(@selector(lastDataFetchTime))];
}

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
    _isInitialized = NO;
    _lastDataFetchTime = NSDate.distantPast.timeIntervalSinceReferenceDate;
    [self _fetchAppropriateRepositoryDataCompletionHandler:^(NSArray<MPPluginRepositoryItem *> * _Nonnull availablePlugins) {
      self.availablePlugins = availablePlugins;
      self.isInitialized = YES;
    }];
  }
  return self;
}

- (NSArray<MPPluginRepositoryItem *> *)availablePlugins {
  /* FIXME: Invalidate fetch when settings have changed!
   update cache on every read if it's older than 5 minutes
   */
  if((NSDate.timeIntervalSinceReferenceDate - self.lastDataFetchTime) > 60*5 ) {
    NSLog(@"%@: updating available plugins cache.", self.className);
    [self _fetchAppropriateRepositoryDataCompletionHandler:^(NSArray<MPPluginRepositoryItem *> * _Nonnull availablePlugins) {
      self.availablePlugins = availablePlugins;
    }];
  }
  return _availablePlugins;
}

- (NSDate *)updatedAt {
  return [NSDate dateWithTimeIntervalSinceReferenceDate:self.lastDataFetchTime];
}

- (void)setAvailablePlugins:(NSArray<MPPluginRepositoryItem *> *)availablePlugins {
  @synchronized (self) {
    _availablePlugins = [availablePlugins copy];
    self.lastDataFetchTime = NSDate.timeIntervalSinceReferenceDate;
    [NSNotificationCenter.defaultCenter postNotificationName:MPPluginRepositoryDidUpdateAvailablePluginsNotification object:self];
  }
}

- (void)_fetchAppropriateRepositoryDataCompletionHandler:(void (^)(NSArray<MPPluginRepositoryItem *> * _Nonnull))completionHandler {
  /* dispatch the call to allow for direct return and handle result later on */
  dispatch_async(dispatch_get_main_queue(), ^{
    BOOL allowRemoteConnection = [self _askForPluginRepositoryPermission];
    if(!allowRemoteConnection) {
      [self _fetchLocalFallbackRepositoryData:completionHandler];
    }
    else {
      [self _fetchRepositoryDataCompletionHandler:completionHandler];      
    }
  });
}

- (void)_fetchRepositoryDataCompletionHandler:(void (^)(NSArray<MPPluginRepositoryItem *> * _Nonnull))completionHandler {
  NSString *urlString = NSBundle.mainBundle.infoDictionary[MPBundlePluginRepositoryURLKey];
  if(!urlString) {
    [self _fetchLocalFallbackRepositoryData:completionHandler];
    return;
  }
  NSURL *jsonURL = [NSURL URLWithString:urlString];
  if(!jsonURL) {
    [self _fetchLocalFallbackRepositoryData:completionHandler];
    return;
  }
  
  NSURLSessionTask *downloadTask = [NSURLSession.sharedSession dataTaskWithURL:jsonURL completionHandler:^(NSData * _Nullable jsonData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if(![response isKindOfClass:NSHTTPURLResponse.class]) {
      [self _fetchLocalFallbackRepositoryData:completionHandler];
      return;
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if(httpResponse.statusCode != 200 || jsonData.length == 0) {
      [self _fetchLocalFallbackRepositoryData:completionHandler];
      return;
    }
    
    NSArray *items = [self _parseJSONData:jsonData];
    
    if(completionHandler) {
      completionHandler([items copy]);
    }
  }];
  [downloadTask resume];
}

- (void)_fetchLocalFallbackRepositoryData:(void (^)(NSArray<MPPluginRepositoryItem *> * _Nonnull))completionHandler {
  NSURL *jsonURL = [NSBundle.mainBundle URLForResource:@"plugins" withExtension:@"json"];
  NSData *localJsonData = [NSData dataWithContentsOfURL:jsonURL];
  if(!localJsonData) {
    if(completionHandler) {
      completionHandler(@[]);
    }
  }
  NSArray<MPPluginRepositoryItem *> *items = [self _parseJSONData:localJsonData];
  if(completionHandler) {
    completionHandler(items);
  }
}

- (NSArray<MPPluginRepositoryItem *> *)_parseJSONData:(NSData *)jsonData {
  NSError *error;
  id jsonRoot = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
  if(!jsonRoot || ![jsonRoot isKindOfClass:NSArray.class]) {
    return @[];
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
  return [items copy];
}

- (BOOL)_askForPluginRepositoryPermission {
  if(![NSUserDefaults.standardUserDefaults objectForKey:kMPSettingsKeyAllowRemoteFetchOfPluginRepository]) {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleWarning;
    alert.informativeText = NSLocalizedString(@"ALERT_ASK_FOR_PLUGIN_REPOSITORY_CONNECTION_PERMISSION_INFORMATIVE_TEXT", @"Informative text displayed on the alert that shows up when MacPass asks for permssion to download the plugin repository JSON file");
    alert.messageText = NSLocalizedString(@"ALERT_ASK_FOR_PLUGIN_REPOSITORY_CONNECTION_PERMISSION_MESSAGE", @"Message displayed on the alert that asks for permission to download the plugin repository JSON file");
    alert.showsSuppressionButton = YES;
    [alert addButtonWithTitle:NSLocalizedString(@"ALERT_ASK_FOR_PLUGIN_REPOSITORY_ALLOW_DOWNLOAD", @"Allow the download of the plugin repository file")];
    [alert addButtonWithTitle:NSLocalizedString(@"ALERT_ASK_FOR_PLUGIN_REPOSITORY_DISALLOW_DOWNLOAD", @"Disallow the download of the plugin repository file")];
    NSModalResponse repsonse = [alert runModal];
    BOOL allow = (repsonse == NSAlertFirstButtonReturn);
    [NSUserDefaults.standardUserDefaults setBool:allow forKey:kMPSettingsKeyAllowRemoteFetchOfPluginRepository];
    return allow;
  }
  return [NSUserDefaults.standardUserDefaults boolForKey:kMPSettingsKeyAllowRemoteFetchOfPluginRepository];
}

@end
