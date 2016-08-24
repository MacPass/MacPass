//
//  MPNumberFormatter.h
//  MacPass
//
//  Created by Michael Starke on 24/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A variation of NSNumberFormatter, that always supplies a valid value. Ideal for usage in NSPopover
 */
@interface MPNumberFormatter : NSNumberFormatter

@end
