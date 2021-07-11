//
//  TableHeaderView.swift
//  SimpleDic
//
//  Created by Yukai Chang on 2021/6/25.
//

import UIKit

class TableHeaderView: UIView {
    let titleLabel = UILabel()
    var blurView: UIVisualEffectView?
    var title: String = ""
    var isBlur = false
    
    init(title: String) {
        self.title = title
        
        super.init(frame: .zero)
        
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setView () {
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.baselineAdjustment = .alignCenters
        titleLabel.minimumScaleFactor = 0.1
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.backgroundColor = UIColor(hex: "F5F4F7")
    }
    
    func setBlurView () {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        // add blur view
        self.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        // set titleLabel attr
        self.bringSubviewToFront(titleLabel)
        titleLabel.text = title
        titleLabel.backgroundColor = .clear
        // assign blurView (removeBlurView will use it)
        self.blurView = blurView
        // animating
        self.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
        // turn on flag (avoid scrollView delegate doing method repeatly)
        isBlur = true
    }
    
    func removeBlurView () {
        // remove blurView
        blurView?.removeFromSuperview()
        // set titleLabel attr
        titleLabel.backgroundColor = UIColor(hex: "F5F4F7")
        titleLabel.text = ""
//        // animating
//        self.alpha = 0
//        UIView.animate(withDuration: 0.5) {
//            self.alpha = 1
//        }
        // turn off flag (avoid scrollView delegate doing method repeatly)
        isBlur = false
    }
}
