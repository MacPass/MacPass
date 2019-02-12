//
//  MPDocumentSaveRecoveryAttempter.m
//  MacPass
//
//  Created by Michael Starke on 31/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
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

#import "MPErrorRecoveryAttempter.h"
#import "NSError+Messages.h"
#import "MPDocument.h"
#import "MPDocumentWindowController.h"

@implementation MPErrorRecoveryAttempter

/* Given that an error alert has been presented document-modally to the user, and the user has chosen one of the error's recovery options, attempt recovery from the error, and send the selected message to the specified delegate. The option index is an index into the error's array of localized recovery options. The method selected by didRecoverSelector must have the same signature as:
 
 - (void)didPresentErrorWithRecovery:(BOOL)didRecover contextInfo:(void *)contextInfo;
 
 The value passed for didRecover must be YES if error recovery was completely successful, NO otherwise.
 */
- (void)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex delegate:(nullable id)delegate didRecoverSelector:(nullable SEL)didRecoverSelector contextInfo:(nullable void *)contextInfo {
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[delegate methodSignatureForSelector:didRecoverSelector]];
  __block void *contextInfoCopy = contextInfo;
  if(error.code == MPErrorNoPasswordOrKeyFile) {
    if([delegate isKindOfClass:MPDocument.class]) {
      MPDocument *document = delegate;
      BOOL didRecover = NO;
      if(recoveryOptionIndex == 0) {
        [document.windowControllers.firstObject editPasswordWithCompetionHandler:^(NSInteger result) {
          BOOL didRecover = (result == NSModalResponseOK);
          invocation.target = delegate;
          invocation.selector = didRecoverSelector;
          [invocation setArgument:&didRecover atIndex:2];
          [invocation setArgument:&contextInfoCopy atIndex:3];
          [invocation invoke];
        }];
      }
      else {
        invocation.target = delegate;
        invocation.selector = didRecoverSelector;
        [invocation setArgument:&didRecover atIndex:2];
        [invocation setArgument:&contextInfo atIndex:3];
        [invocation invoke];
      }
    }
  }
}

/* Given that an error alert has been presented applicaton-modally to the user, and the user has chosen one of the error's recovery options, attempt recovery from the error, and return YES if error recovery was completely successful, NO otherwise. The recovery option index is an index into the error's array of localized recovery options.
 */
- (BOOL)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex {
  return NO;
}
@end
