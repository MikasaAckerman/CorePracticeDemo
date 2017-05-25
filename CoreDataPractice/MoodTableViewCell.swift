//
//  MoodTableViewCell.swift
//  CoreDataPractice
//
//  Created by 王淵博 on 2017/05/22.
//  Copyright © 2017年 王淵博. All rights reserved.
//

import UIKit

class MoodTableViewCell: UITableViewCell {
    @IBOutlet weak var moodView: UIView!
    @IBOutlet weak var label: UILabel!
}


private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.doesRelativeDateFormatting = true
    formatter.formattingContext = .standalone
    return formatter
}()


extension MoodTableViewCell {
    func configure(for mood: Mood) {
        moodView.backgroundColor = mood.colors
        label.text = dateFormatter.string(from: mood.date)
    }
}

