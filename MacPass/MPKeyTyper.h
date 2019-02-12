//
//  MPKeyboardTyper.h
//  MacPass
//
//  Created by Michael Starke on 30.10.18.
//  Copyright © 2018 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPModifiedKey.h"

NS_ASSUME_NONNULL_BEGIN


@interface MPKeyTyper : NSObject

/**
 *  Sends a KeyPress Event with the supplied modifier flags and Keycode
 *  Any existing modifiers will be disabled for this event. If the user
 *  presses any key, those will be ignored during this event
 *
 *  @param keyCode virtual KeyCode to be sent
 *  @param flags   modifier flags for the key press event
 */
+ (void)sendKey:(MPModifiedKey)key;

+ (void)sendText:(NSString *)text;

/**
 *  Convenience message to be sent for executing a simple paste command
 */
+ (void)sendPaste;

@end

NS_ASSUME_NONNULL_END
