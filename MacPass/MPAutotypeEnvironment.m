//
//  MPAutotypeEnvironment.m
//  MacPass
//
//  Created by Michael Starke on 15.01.20.
//  Copyright © 2020 HicknHack Software GmbH. All rights reserved.
//

#import "MPAutotypeEnvironment.h"
#import "NSRunningApplication+MPAdditions.h"
#import "MPPluginHost.h"
#import "MPPlugin.h"

@implementation MPAutotypeEnvironment

+ (instancetype)environmentWithTargetApplication:(NSRunningApplication *)targetApplication entry:(KPKEntry *)entry {
  return [[MPAutotypeEnvironment alloc] initWithTargetApplication:targetApplication entry:entry];
}

- (instancetype)initWithTargetApplication:(NSRunningApplication *)targetApplication entry:(KPKEntry *)entry {
  self = [super init];
  if(self) {
    _preferredEntry = entry;
    if(!targetApplication) {
      _pid = -1;
      _windowTitle = @"";
    }
    else {
      NSDictionary *frontApplicationInfoDict = targetApplication.mp_infoDictionary;
      
      _pid = [frontApplicationInfoDict[MPProcessIdentifierKey] intValue];
      _windowTitle = frontApplicationInfoDict[MPWindowTitleKey];
      
      /* if we have any resolvers, let them provide the window title */
      NSArray *resolvers = [MPPluginHost.sharedHost windowTitleResolverForRunningApplication:targetApplication];
      for(MPPlugin<MPAutotypeWindowTitleResolverPlugin> *resolver in resolvers) {
        NSString *windowTitle = [resolver windowTitleForRunningApplication:targetApplication];
        if(windowTitle.length > 0) {
          _windowTitle = windowTitle;
          break;
        }
      }
    }
    _hidden = NSRunningApplication.currentApplication.isHidden;
  }
  return self;
}

- (BOOL)isSelfTargeting {
  return NSRunningApplication.currentApplication.processIdentifier == _pid;
}

- (NSDictionary *)_infoDictionaryForApplication:(NSRunningApplication *)application {
  NSArray *currentWindows = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements, kCGNullWindowID));
  NSArray *windowNumbers = [NSWindow windowNumbersWithOptions:NSWindowNumberListAllApplications];
  NSUInteger minZIndex = NSNotFound;
  NSDictionary *infoDict = nil;
  for(NSDictionary *windowDict in currentWindows) {
    NSString *windowTitle = windowDict[(NSString *)kCGWindowName];
    if(windowTitle.length <= 0) {
      continue;
    }
    NSNumber *processId = windowDict[(NSString *)kCGWindowOwnerPID];
    if(processId && [processId isEqualToNumber:@(application.processIdentifier)]) {
      
      NSNumber *number = (NSNumber *)windowDict[(NSString *)kCGWindowNumber];
      NSUInteger zIndex = [windowNumbers indexOfObject:number];
      if(zIndex < minZIndex) {
        minZIndex = zIndex;
        infoDict = @{
          MPWindowTitleKey: windowTitle,
          MPProcessIdentifierKey : processId
        };
      }
    }
  }
  if(currentWindows.count > 0 && infoDict.count == 0) {
    // show some information about not being able to determine any windows
    NSLog(@"Unable to retrieve any window names. If you encounter this issue you might be running 10.15 and MacPass has no permission for screen recording.");
  }
  return infoDict;
}

@end
