//
//  MPDocumentSaveRecoveryAttempter.h
//  MacPass
//
//  Created by Michael Starke on 31/08/16.
//  Copyright © 2016 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MPDocument;

@interface MPErrorRecoveryAttempter : NSObject

@property (strong, nullable) MPDocument *document;

@end
