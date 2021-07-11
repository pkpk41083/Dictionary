//
//  VocCell.swift
//  SimpleDic
//
//  Created by Yukai Chang on 2021/6/22.
//

import UIKit

class VocCell: UITableViewCell {
    let vocLabel = UILabel()
    let arrowImageView = UIImageView()
    let definitionLabel = UILabel()
    let dayLabel = UILabel()
    let soundBtn = CustomButton(type: .system)
    let shadowView = UIView()
    // icon image
    let downArrow = UIImage(systemName: "arrowtriangle.down.fill")
    let upArrow = UIImage(systemName: "arrowtriangle.up.fill")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .white
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setView () {
        self.contentView.addSubview(dayLabel)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dayLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 18).isActive = true // (60 - 24) / 2
        dayLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        dayLabel.widthAnchor.constraint(equalTo: dayLabel.heightAnchor, multiplier: 1.5).isActive = true
        dayLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true // 60 * 0.4
        
        dayLabel.layer.borderWidth = 1
        dayLabel.layer.borderColor = UIColor.systemGray.cgColor
        dayLabel.layer.cornerRadius = 3
        dayLabel.clipsToBounds = true
        dayLabel.textColor = .systemGray
        dayLabel.textAlignment = .center
        dayLabel.adjustsFontSizeToFitWidth = true
        dayLabel.baselineAdjustment = .alignCenters
        dayLabel.minimumScaleFactor = 0.1
        dayLabel.isHidden = true
        
        self.contentView.addSubview(arrowImageView)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        arrowImageView.centerYAnchor.constraint(equalTo: dayLabel.centerYAnchor).isActive = true
        arrowImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        arrowImageView.heightAnchor.constraint(equalToConstant: 18).isActive = true // 60 * 0.3
        arrowImageView.widthAnchor.constraint(equalTo: arrowImageView.heightAnchor).isActive = true
        
        arrowImageView.image = downArrow
        arrowImageView.tintColor = UIColor(hex: "0076BA")
        
        self.contentView.addSubview(soundBtn)
        soundBtn.translatesAutoresizingMaskIntoConstraints = false
        
        soundBtn.centerYAnchor.constraint(equalTo: dayLabel.centerYAnchor).isActive = true
        soundBtn.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -15).isActive = true
        soundBtn.heightAnchor.constraint(equalToConstant: 24).isActive = true // 60 * 0.4
        soundBtn.widthAnchor.constraint(equalTo: soundBtn.heightAnchor).isActive = true
        
        soundBtn.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        soundBtn.tintColor = UIColor(hex: "0076BA")
        soundBtn.isHidden = true
        
        self.contentView.addSubview(vocLabel)
        vocLabel.translatesAutoresizingMaskIntoConstraints = false
        
        vocLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        vocLabel.leadingAnchor.constraint(equalTo: dayLabel.trailingAnchor, constant: 10).isActive = true
        vocLabel.trailingAnchor.constraint(equalTo: self.soundBtn.leadingAnchor).isActive = true
        vocLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.contentView.addSubview(definitionLabel)
        definitionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        definitionLabel.topAnchor.constraint(equalTo: vocLabel.bottomAnchor).isActive = true
        definitionLabel.leadingAnchor.constraint(equalTo: vocLabel.leadingAnchor).isActive = true
        definitionLabel.trailingAnchor.constraint(equalTo: arrowImageView.trailingAnchor).isActive = true
        definitionLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        
        definitionLabel.numberOfLines = 0
        
        self.contentView.addSubview(shadowView)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        shadowView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        shadowView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        shadowView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        shadowView.layer.shadowColor = UIColor(hex: "83BAD4").cgColor
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowRadius = 10
        shadowView.layer.masksToBounds = false
        shadowView.layer.cornerRadius = 10
        shadowView.clipsToBounds = true
        shadowView.layer.borderWidth = 1
        shadowView.layer.borderColor = UIColor(hex: "F5F4F7").cgColor
        shadowView.alpha = 0
        
        // bring soundBtn to front
        self.contentView.bringSubviewToFront(soundBtn)
    }
}
