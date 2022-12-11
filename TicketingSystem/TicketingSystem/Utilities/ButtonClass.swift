//
//  ButtonClass.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 9/2/22.
//

import UIKit

class ButtonClass: UIButton{
    
    private func configureCornerRadius() {
        self.layer.cornerRadius  = 10.0
        self.layer.masksToBounds = true
    }
    private func border(){
        self.backgroundColor = .clear
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureCornerRadius()
        self.border()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureCornerRadius()
        self.border()
    }
    
    override var isHighlighted: Bool {
        willSet(highlighted) {
            
            let scale: CGFloat
            if highlighted { scale = 0.9
            } else { scale = 1.0 }
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                self.layer.transform = CATransform3DMakeScale(scale, scale, scale)
            }, completion: nil)
        }
    }
}
