//
//  Managed.swift
//  CoreDataPractice
//
//  Created by 王淵博 on 2017/05/23.
//  Copyright © 2017年 王淵博. All rights reserved.
//

import CoreData

// 自定义抓取请求协议，包含实体的名字和一个排序
protocol Managed: class, NSFetchRequestResult {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}


extension Managed {
    // 给一个默认排序
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    // 真正的请求
    static var sortedFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
}


// 通过约束为NSManagedObject子类型的协议扩展来给静态的entityName添加一个默认实现
extension Managed where Self: NSManagedObject {
    static var entityName: String {
        if #available(iOS 10.0, *) {
            return entity().name!
        } else {
            // Fallback on earlier versions
            return "Mood" // 这样的话不是iOS10的话感觉不能通用了啊，求大神告知
        }
    }
}
