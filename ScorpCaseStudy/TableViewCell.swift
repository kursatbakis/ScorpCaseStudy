//
//  TableViewCell.swift
//  ScorpCaseStudy
//
//  Created by Kursat on 6.08.2021.
//

import Foundation
import UIKit

class TableViewCell: UITableViewCell {
    
    let label = UILabel(frame: .zero)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        backgroundColor = .systemYellow
        label.frame = CGRect(x: 10, y: 0, width: contentView.frame.width, height: contentView.frame.height)
    }
    
    func prepare(person: Person) {
        label.text = "\(person.fullName) (\(person.id))"
        label.textColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
