//
//  Mood.swift
//  CoreDataPractice
//
//  Created by 王淵博 on 2017/05/19.
//  Copyright © 2017年 王淵博. All rights reserved.
//

import UIKit
import CoreData

final class Mood: NSManagedObject {
    @NSManaged var date: Date
    @NSManaged var colors: UIColor
    
}

// 支持这个自定义的协议，给默认排序赋值
extension Mood: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(date), ascending: false)]
    }
}
