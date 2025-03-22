//
//  NotificationInfo+CoreDataClass.swift
//  
//
//  Created by 오원석 on 3/8/25.
//
//

import Foundation
import CoreData

@objc(NotificationInfo)
public class NotificationInfo: NSManagedObject {
    @NSManaged public var count: Int16
    @NSManaged public var date: String
    @NSManaged public var message: String
    @NSManaged public var gifticonId: String
    @NSManaged public var isRead: Bool
}
