//
//  NotificationDataManager.swift
//  MOA
//
//  Created by 오원석 on 3/8/25.
//

import Foundation
import CoreData

class NotificationDataManager {
    static let shared = NotificationDataManager()
    private init() {}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NotificationModel")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error {
                fatalError()
            }
        })
        
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func insertNotification(_ notification: NotificationModel) -> Bool{
        MOALogger.logd("\(notification)")
        if let entity = NSEntityDescription.entity(forEntityName: "NotificationInfo", in: context) {
            let info = NSManagedObject(entity: entity, insertInto: context)
            info.setValue(notification.count, forKey: "count")
            info.setValue(notification.date, forKey: "date")
            info.setValue(notification.message, forKey: "message")
            
            do {
                try context.save()
                return true
            } catch {
                MOALogger.loge(error.localizedDescription)
                return false
            }
        }
        return false
    }
    
    func fetchNotification() -> [NotificationInfo] {
        MOALogger.logd()
        do {
            if let notifications = try context.fetch(NotificationInfo.fetchRequest()) as? [NotificationInfo] {
                return notifications
            }
            return []
        } catch {
            return []
        }
    }
    
    func deleteNotification(_ notification: NotificationInfo) -> Bool {
        MOALogger.logd()
        context.delete(notification)
        do {
            try context.save()
            return true
        } catch {
            MOALogger.loge(error.localizedDescription)
            return false
        }
    }
    
    func deleteAll() -> Bool {
        MOALogger.logd()
        let delete = NSBatchDeleteRequest(fetchRequest: NotificationInfo.fetchRequest())
        do {
            try context.execute(delete)
            return true
        } catch {
            MOALogger.loge(error.localizedDescription)
            return false
        }
    }
}
