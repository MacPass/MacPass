//
//  MPNotificationsHelper.swift
//  MacPass
//
//  Created by Eric on 9/1/19.
//  Copyright © 2019 HicknHack Software GmbH. All rights reserved.
//

import Foundation
import UserNotifications

class MPNotificationsHelper : NSObject {
  
  func showNotification(title: String, message: String) {
      let notification = NSUserNotification()
      notification.identifier = "macpass-notification"
      notification.title = title
      notification.informativeText = message
      notification.soundName = NSUserNotificationDefaultSoundName
    
      // display the notification
      let center = NSUserNotificationCenter.default
    
      center.deliver(notification)
  }
  
}
