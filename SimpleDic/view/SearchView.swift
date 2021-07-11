//
//  SearchView.swift
//  SimpleDic
//
//  Created by Yukai Chang on 2021/6/18.
//

import UIKit

class SearchView: UIView {
    let searchField = UITextField()
    let goBtn = UIButton(type: .system)
    let loadingView = LoadingView()
    let definitionView = DefinitionView()
    // layout
    var searchFieldCenterYConstraint: NSLayoutConstraint?
    var isShowingDef = false
    
    init() {
        super.init(frame: .zero)
        
        setView()
        setLoadingView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setView () {
        self.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        
        searchFieldCenterYConstraint = searchField.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        searchFieldCenterYConstraint?.isActive = true
        searchField.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        searchField.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7).isActive = true
        searchField.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1).isActive = true
        
        searchField.borderStyle = .roundedRect
        searchField.placeholder = "Type something..."
        
        self.addSubview(goBtn)
        goBtn.translatesAutoresizingMaskIntoConstraints = false
        
        goBtn.centerYAnchor.constraint(equalTo: searchField.centerYAnchor).isActive = true
        goBtn.leadingAnchor.constraint(equalTo: searchField.trailingAnchor, constant: 5).isActive = true
        goBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        goBtn.heightAnchor.constraint(equalTo: searchField.heightAnchor).isActive = true
        
        goBtn.setTitle("GO!", for: .normal)
        goBtn.setTitle("", for: .disabled)
        goBtn.setTitleColor(.white, for: .normal)
        goBtn.backgroundColor = UIColor(hex: "83BAD4")
        goBtn.layer.cornerRadius = 10
        goBtn.clipsToBounds = true
    }
    
    func setLoadingView () {
        self.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingView.centerXAnchor.constraint(equalTo: goBtn.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: goBtn.centerYAnchor).isActive = true
        loadingView.heightAnchor.constraint(equalTo: goBtn.heightAnchor, multiplier: 0.3).isActive = true
        loadingView.widthAnchor.constraint(equalTo: loadingView.heightAnchor).isActive = true
        
        loadingView.isHidden = true
        loadingView.color = .white
    }
    
    func setDefinitionView (info: EnglishDictionary.DicInfo) {
        // turn on the flag
        isShowingDef = true
        // set definitions
        var definitions = info.definitions.count > 0 ? "" : "查無解釋"
        var examples = info.examples.count > 0 ? "" : "查無例句"
        
        for def in info.definitions {
            definitions += "\(def)\n\n"
        }
        for example in info.examples {
            examples += "\(example)\n\n"
        }
        // set definitionView
        self.addSubview(definitionView)
        definitionView.translatesAutoresizingMaskIntoConstraints = false
        
        definitionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10).isActive = true
        definitionView.leadingAnchor.constraint(equalTo: searchField.leadingAnchor).isActive = true
        definitionView.trailingAnchor.constraint(equalTo: goBtn.trailingAnchor).isActive = true
        definitionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
        definitionView.vocLabel.text = searchField.text
        definitionView.definitionLabel.text = definitions
        definitionView.definitionLabel.defs = definitions
        definitionView.definitionLabel.examples = examples
        definitionView.layer.cornerRadius = 10
        definitionView.clipsToBounds = true
        definitionView.alpha = 0
        definitionView.backgroundColor = .white
        // move searchField and goBtn to the top
        searchFieldCenterYConstraint?.isActive = false
        searchFieldCenterYConstraint = searchField.centerYAnchor.constraint(equalTo: self.topAnchor, constant: searchField.frame.height / 2)
        searchFieldCenterYConstraint?.isActive = true
        // animate
        UIView.animate(withDuration: 0.2) {
            self.layoutSubviews()
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.definitionView.alpha = 1
            }
        }
    }
    
    func updateDefinitionView (info: EnglishDictionary.DicInfo) {
        // set definitions
        var definitions = info.definitions.count > 0 ? "" : "查無解釋"
        var examples = info.examples.count > 0 ? "" : "查無例句"
        
        for def in info.definitions {
            definitions += "\(def)\n\n"
        }
        for example in info.examples {
            examples += "\(example)\n\n"
        }
        definitionView.vocLabel.text = searchField.text
        definitionView.definitionLabel.text = definitions
        definitionView.definitionLabel.defs = definitions
        definitionView.definitionLabel.examples = examples
        
        definitionView.addBtn.isEnabled = true
        definitionView.addBtn.layer.borderColor = UIColor(hex: "0076BA").cgColor // UIColor.systemBlue.cgColor
    }
    
    func addShadowEffect (_ view: UIView) {
        guard view.frame.height > 0 && view.frame.width > 0 else {
            return
        }
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
        view.layer.masksToBounds = false
        
        let path = CGMutablePath()
        path.addRect(view.bounds)
        view.layer.shadowPath = path
    }
    
}

class DefinitionView: UIView {
    let vocLabel = UILabel()
    let defScrollView = UIScrollView()
    let definitionLabel = DefinitionLabel()
    let addBtn = UIButton(type: .system)
    let soundBtn = UIButton(type: .system)
    let showExampleBtn = UIButton(type: .system)
    let loadingView = LoadingView()
    //
    var needSetScrollViewContentSize = true
    
    init() {
        super.init(frame: .zero)
        
        setView()
        setLoadingView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setView () {
        self.addSubview(vocLabel)
        vocLabel.translatesAutoresizingMaskIntoConstraints = false
        
        vocLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        vocLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        vocLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(20 + 50)).isActive = true
        vocLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.15).isActive = true
        
        vocLabel.adjustsFontSizeToFitWidth = true
        vocLabel.baselineAdjustment = .alignCenters
        vocLabel.minimumScaleFactor = 0.1
        vocLabel.font = UIFont.boldSystemFont(ofSize: 30)
        vocLabel.textColor = UIColor(hex: "0076BA")
        
        self.addSubview(addBtn)
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        
        addBtn.centerYAnchor.constraint(equalTo: vocLabel.centerYAnchor).isActive = true
        addBtn.leadingAnchor.constraint(equalTo: vocLabel.trailingAnchor, constant: 10).isActive = true
        addBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        
        addBtn.sizeToFit()
        addBtn.setTitle("新增", for: .normal)
        addBtn.setTitle("已新增", for: .disabled)
        addBtn.setTitleColor(UIColor(hex: "0076BA"), for: .normal)
        addBtn.setTitleColor(.systemGray, for: .disabled)
        addBtn.layer.borderWidth = 1
        addBtn.layer.borderColor = UIColor(hex: "0076BA").cgColor
        addBtn.layer.cornerRadius = 10
        addBtn.clipsToBounds = true
        
        self.addSubview(soundBtn)
        soundBtn.translatesAutoresizingMaskIntoConstraints = false

        soundBtn.topAnchor.constraint(equalTo: vocLabel.bottomAnchor).isActive = true
        soundBtn.leadingAnchor.constraint(equalTo: vocLabel.leadingAnchor).isActive = true
        soundBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        soundBtn.sizeToFit()
        soundBtn.tintColor = UIColor(hex: "0076BA")
        soundBtn.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        soundBtn.setTitle("發音", for: .normal)
        soundBtn.setTitleColor(UIColor(hex: "0076BA"), for: .normal)
        
        self.addSubview(showExampleBtn)
        showExampleBtn.translatesAutoresizingMaskIntoConstraints = false
        
        showExampleBtn.topAnchor.constraint(equalTo: soundBtn.topAnchor).isActive = true
        showExampleBtn.leadingAnchor.constraint(equalTo: soundBtn.trailingAnchor, constant: 10).isActive = true
        showExampleBtn.widthAnchor.constraint(equalTo: soundBtn.widthAnchor).isActive = true
        showExampleBtn.heightAnchor.constraint(equalTo: soundBtn.heightAnchor).isActive = true
        
        showExampleBtn.tintColor = UIColor(hex: "0076BA")
        showExampleBtn.setImage(UIImage(systemName: "paperclip"), for: .normal)
        showExampleBtn.setTitle("例句", for: .normal)
        showExampleBtn.setTitleColor(UIColor(hex: "0076BA"), for: .normal)
        
        self.addSubview(defScrollView)
        defScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        defScrollView.topAnchor.constraint(equalTo: soundBtn.bottomAnchor, constant: 10).isActive = true
        defScrollView.leadingAnchor.constraint(equalTo: vocLabel.leadingAnchor).isActive = true
        defScrollView.trailingAnchor.constraint(equalTo: addBtn.trailingAnchor).isActive = true
        defScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        defScrollView.alwaysBounceVertical = true
        defScrollView.showsVerticalScrollIndicator = false
        defScrollView.delegate = self
        
        defScrollView.addSubview(definitionLabel)
        definitionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        definitionLabel.topAnchor.constraint(equalTo: defScrollView.topAnchor).isActive = true
        definitionLabel.leadingAnchor.constraint(equalTo: defScrollView.leadingAnchor).isActive = true
        definitionLabel.widthAnchor.constraint(equalTo: defScrollView.widthAnchor).isActive = true
        
        definitionLabel.sizeToFit()
        definitionLabel.adjustsFontSizeToFitWidth = true
        definitionLabel.baselineAdjustment = .alignCenters
        definitionLabel.minimumScaleFactor = 0.1
        definitionLabel.font = UIFont.systemFont(ofSize: 17)
        definitionLabel.textColor = .darkGray
        definitionLabel.numberOfLines = 0
    }
    
    func setLoadingView () {
        self.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingView.centerXAnchor.constraint(equalTo: addBtn.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: addBtn.centerYAnchor).isActive = true
        loadingView.widthAnchor.constraint(equalTo: addBtn.widthAnchor, multiplier: 0.5).isActive = true
        loadingView.heightAnchor.constraint(equalTo: loadingView.widthAnchor).isActive = true
        
        loadingView.alpha = 0
    }
    
    func startLoading () {
        // update loadingView size
        loadingView.updateView(frame: loadingView.frame)
        
        addBtn.alpha = 0
        loadingView.alpha = 1
        loadingView.start()
    }
    
    func stopLoading () {
        addBtn.isEnabled = false
        addBtn.layer.borderColor = UIColor.systemGray.cgColor
        addBtn.alpha = 1
        loadingView.alpha = 0
        loadingView.stop()
    }
}

extension DefinitionView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if needSetScrollViewContentSize {
            needSetScrollViewContentSize = false
            scrollView.contentSize = CGSize(width: definitionLabel.frame.width, height: definitionLabel.frame.height)
        }
    }
}

class DefinitionLabel: UILabel {
    var defs = ""
    var examples = ""
}

class LoadingView: UIView {
    let shapeLayer = CAShapeLayer()
    var arcCenter = CGPoint(x: 15, y: 15)
    var color: UIColor = UIColor(hex: "0076BA") {
        didSet {
            shapeLayer.strokeColor = color.cgColor
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setView () {
        let path = UIBezierPath()
        
        path.addArc(withCenter: arcCenter, radius: 15, startAngle: .pi / 3, endAngle: .pi * 2, clockwise: true)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.lineCap = .round
        shapeLayer.path = path.cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
    func updateView (frame: CGRect) {
        let path = UIBezierPath()
        
        arcCenter = CGPoint(x: frame.width / 2, y: frame.height / 2)
        path.addArc(withCenter: arcCenter, radius: frame.height / 2, startAngle: .pi / 3, endAngle: .pi * 2, clockwise: true)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.lineCap = .round
        shapeLayer.path = path.cgPath
    }
    
    func start () {
        // add rotation animation
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func stop () {
        self.layer.removeAnimation(forKey: "rotationAnimation")
    }
}
