//
//  AnimatedHighlightButton.swift
//  HelloAlarm
//
//  Created by Nikita Somenkov on 19/01/2019.
//  Copyright © 2019 Nikita Somenkov. All rights reserved.
//

import UIKit

class AnimatedHighlightButton: UIButton {
    static var durationOfAnimation = 0.05
    
    override open var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: AnimatedHighlightButton.durationOfAnimation) {
                self.layer.opacity = self.isHighlighted ? 0.5: 1.0
            }
        }
    }
}
