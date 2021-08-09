//
//  EmptyTableViewBackground.swift
//  ScorpCaseStudy
//
//  Created by Kursat on 9.08.2021.
//

import Foundation
import UIKit

class EmptyTableViewBackground: UIView {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.frame = CGRect(x: 0, y: frame.height/2 - 35, width: frame.width, height: 70)
        label.attributedText = NSAttributedString(string: "No one here 😜", attributes: [.foregroundColor: UIColor.red, .font: UIFont.init(name: "TrebuchetMS", size: 25)!, .kern: 3.0])
        label.numberOfLines = 0
        label.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
