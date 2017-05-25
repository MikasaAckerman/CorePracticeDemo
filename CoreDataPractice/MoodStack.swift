//
//  MoodStack.swift
//  CoreDataPractice
//
//  Created by 王淵博 on 2017/05/19.
//  Copyright © 2017年 王淵博. All rights reserved.
//

import CoreData

// 这个类的作用是定义一些方法，可以在全局使用


// iOS10新方法 NSPersistentContainer
// 首先，我们创建并命名了一个持久化容器 (persistent container)。Core Data 使用这个名字来 查找对应的数据模型，所以它应该和你的 .xcdatamodeld bundle 的文件名一致。接下来，我们调用容器的 loadPersistentStores 方法来尝试打开底层的数据库文件。如果数据库文件还不存在，Core Data 会根据你在数据模型里定义的大纲 (schema) 来生成它。
// 因为持久化存储们 (在我们的例子里，以及大多数真实世界情况下，只会有一个存储) 是异步加载的，一旦一个存储被加载完成，我们的回调就会被执行。如果发生了一个错误，我们现在就直接让程序崩溃掉。在生产环境中，你可能需要采取不同的反应，比如迁移已有的存储到新的版本，或者作为最后的手段，删除并重新创建这个存储。
// 最后，我们调度回主队列，并用这个新的持久化容器作为参数，调用 createMoodyContainer 的完成处理函数。
@available(iOS 10.0, *)
func createMoodyContainer(completion: @escaping (NSPersistentContainer) -> ()) {
    let container = NSPersistentContainer.init(name: "Moody")
    container.loadPersistentStores { (_, error) in
        guard error == nil else {
            fatalError("Failed to load store: \(error)")
        }
        DispatchQueue.main.async {
            completion(container)
        }
    }
}


// 下面是对应iOS10之前的
let documentURL = URL.init(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first!)

private let StoreURL = documentURL.appendingPathComponent("Moody.moody")

public func createMoodyMainContext() -> NSManagedObjectContext {
    
    let bundles = [Bundle(for: Mood.self)]
    guard let model = NSManagedObjectModel.mergedModel(from: bundles) else { fatalError("model not found") }
    let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil,
                                at: StoreURL, options: nil)
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = psc
    return context
}
