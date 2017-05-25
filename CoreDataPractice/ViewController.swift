//
//  ViewController.swift
//  CoreDataPractice
//
//  Created by 王淵博 on 2017/05/19.
//  Copyright © 2017年 王淵博. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    /// 上下文
    var managedObjectContext: NSManagedObjectContext! // 用来记录操作的，也就是app与数据库的信使吧
    /// 抓取结果控制器
    var frc: NSFetchedResultsController<Mood>! // 用来协调模型和视图的，与tableView or collectionView应该是好搭档

    /// demo的tableView
    @IBOutlet weak var mainTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 给上下文赋值
        if #available(iOS 10.0, *) {
            createMoodyContainer { (container) in
                self.managedObjectContext = container.viewContext
                self.setupTableView()
            }
        } else {
            // Fallback on earlier versions
            managedObjectContext = createMoodyMainContext()
            self.setupTableView()
        }
    }

    // MARK: - 与抓取控制器相结合配置tableView
    fileprivate func setupTableView() {
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.register(UINib.init(nibName: "MoodTableViewCell", bundle: nil), forCellReuseIdentifier: "MoodCell")
        
        let request = Mood.sortedFetchRequest
        request.fetchBatchSize = 20
        request.returnsObjectsAsFaults = false
        frc = NSFetchedResultsController(fetchRequest: request,
                                         managedObjectContext: managedObjectContext,
                                         sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        mainTableView.reloadData()
    }
    
    // MARK: - 增加数据
    @IBAction func plusData(_ sender: UIButton) {
        
        guard let mood = NSEntityDescription.insertNewObject(forEntityName: "Mood", into: managedObjectContext) as? Mood else {
            fatalError("Wrong object type")
        }
        mood.colors = UIColor.brown
        mood.date = Date.init()
        try! self.managedObjectContext.save()
    }
    
    // MARK: - 删除数据
    @IBAction func minusData(_ sender: UIButton) {
        if (frc.sections?[0].objects?.count)! > 0 {
            guard let mood = frc.sections?[0].objects?[0] as? Mood else {
                fatalError("Delete wrong object type")
            }
            mood.managedObjectContext?.delete(mood)
            try! self.managedObjectContext.save()
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 用来交替改变颜色
        guard let mood = frc.sections?[indexPath.section].objects?[indexPath.row] as? Mood else {
            fatalError("modifyData wrong object type")
        }
        if mood.colors == UIColor.brown {
            mood.colors = UIColor.gray
        } else {
            mood.colors = UIColor.brown
        }
        try! self.managedObjectContext.save()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = frc.sections?[section] else {
            return 0
        }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = frc.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoodCell", for: indexPath) as! MoodTableViewCell
        
        cell.configure(for: object)
        
        return cell
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    // 在这里开始更新tableView
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        mainTableView.beginUpdates()
    }
    
    // 这些是书里封装在一个自定义类里的，用于tableViewController，但是自己学艺不精，最终摘抄出来修改下，放在了ViewController里。
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
            mainTableView.insertRows(at: [indexPath], with: .fade)
        case .update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            let object = frc.object(at: indexPath)
            guard let cell = mainTableView.cellForRow(at: indexPath) as? MoodTableViewCell else { break }
            cell.configure(for: object)
            mainTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            mainTableView.deleteRows(at: [indexPath], with: .fade)
            mainTableView.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            mainTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // 在这里结束更新tableView
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        mainTableView.endUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

