//
//  MPDocument+Attachment.h
//  MacPass
//
//  Created by Michael Starke on 25.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"

@interface MPDocument (Attachments)

- (void)addAttachment:(NSURL *)location toEntry:(KPKEntry *)anEntry;

@end