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

+ (instancetype)environmentWithTargetApplication:(NSRunningApplication *)targetApplication entry:(KPKEntry *)entry overrideSequence:(NSString *)overrideSequence {
  return [[MPAutotypeEnvironment alloc] initWithTargetApplication:targetApplication entry:entry overrideSequence:overrideSequence];
}

- (instancetype)initWithTargetApplication:(NSRunningApplication *)targetApplication entry:(KPKEntry *)entry overrideSequence:(NSString *)overrdieSequence {
  self = [super init];
  if(self) {
    _preferredEntry = entry;
    _hidden = NSRunningApplication.currentApplication.isHidden;
    _overrideSequence = [overrdieSequence copy];
    if(!targetApplication) {
      _pid = -1;
      _windowTitle = @"";
      _windowId = -1;
    }
    else {
      NSDictionary *frontApplicationInfoDict = targetApplication.mp_infoDictionary;
      
      _pid = [frontApplicationInfoDict[MPProcessIdentifierKey] intValue];
      _windowTitle = frontApplicationInfoDict[MPWindowTitleKey];
      _windowId = (CGWindowID)[frontApplicationInfoDict[MPWindowIDKey] integerValue];
      
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
