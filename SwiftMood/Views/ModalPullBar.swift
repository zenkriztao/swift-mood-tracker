//
//  ModalPullBar.swift
//  SwiftMood
//
//  Created by zenkriztao  .
//

import Foundation
import UIKit

class ModalPullBar: UIView {
    
    init() {
        super.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 64, height: 8)))
        self.backgroundColor = UIColor(named: "info")
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
