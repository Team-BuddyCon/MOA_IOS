//
//  NotificationDataManager.swift
//  MOA
//
//  Created by 오원석 on 3/8/25.
//

import Foundation
import CoreData

class LocalNotificationDataManager {
    static let shared = LocalNotificationDataManager()
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "NotificationInfo")
        fetchRequest.predicate = NSPredicate(format: "gifticonId = %@ AND date = %@", notification.gifticonId, notification.date)
        
        do {
            if let infos = try context.fetch(fetchRequest) as? [NotificationInfo] {
                if !infos.isEmpty {
                    return false
                }
            }
        } catch {
            MOALogger.loge(error.localizedDescription)
            return false
        }
        
        if let entity = NSEntityDescription.entity(forEntityName: "NotificationInfo", in: context) {
            let info = NSManagedObject(entity: entity, insertInto: context)
            info.setValue(notification.count, forKey: "count")
            info.setValue(notification.date, forKey: "date")
            info.setValue(notification.message, forKey: "message")
            info.setValue(notification.gifticonId, forKey: "gifticonId")
            info.setValue(notification.isRead, forKey: "isRead")
            
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
    
    func updateAllNotification() -> Bool {
        MOALogger.logd()
        do {
            if let infos = try context.fetch(NotificationInfo.fetchRequest()) as? [NotificationInfo] {
                infos.forEach { info in
                    info.setValue(true, forKey: "isRead")
                }
                
                do {
                    try context.save()
                    return true
                } catch {
                    MOALogger.loge(error.localizedDescription)
                    return false
                }
            }
        } catch {
            MOALogger.loge(error.localizedDescription)
        }
        return false
    }
    
    func updateNotification(_ notification: NotificationModel) -> Bool {
        MOALogger.logd("\(notification)")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "NotificationInfo")
        fetchRequest.predicate = NSPredicate(format: "gifticonId = %@ AND date = %@", notification.gifticonId, notification.date)
        do {
            if let infos = try context.fetch(fetchRequest) as? [NotificationInfo] {
                if !infos.isEmpty {
                    let info = infos[0]
                    info.setValue(true, forKey: "isRead")
                    
                    do {
                        try context.save()
                        return true
                    } catch {
                        MOALogger.loge(error.localizedDescription)
                        return false
                    }
                }
            }
        } catch {
            MOALogger.loge(error.localizedDescription)
            return false
        }
        
        return false
    }
    
    func fetchNotification() -> [NotificationModel] {
        MOALogger.logd()
        do {
            if let notifications = try context.fetch(NotificationInfo.fetchRequest()) as? [NotificationInfo] {
                return notifications.sorted(by: { $0.date > $1.date }) .map {
                    NotificationModel(
                        count: Int($0.count),
                        date: $0.date,
                        message: $0.message,
                        gifticonId: $0.gifticonId,
                        isRead: $0.isRead
                    )
                }
            }
            return []
        } catch {
            return []
        }
    }
    
    func deleteNotification(_ notification: NotificationModel) -> Bool {
        MOALogger.logd()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "NotificationInfo")
        fetchRequest.predicate = NSPredicate(format: "gifticonId = %@ AND date = %@", notification.gifticonId, notification.date)
        
        do {
            if let infos = try context.fetch(fetchRequest) as? [NotificationInfo] {
                infos.forEach {
                    context.delete($0)
                }
                
                do {
                    try context.save()
                    return true
                } catch {
                    MOALogger.loge(error.localizedDescription)
                }
            }
        } catch {
            MOALogger.loge(error.localizedDescription)
        }
        
        return false
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
