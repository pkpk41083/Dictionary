//
//  DailyViewController.swift
//  SimpleDic
//
//  Created by Yukai Chang on 2021/6/19.
//

import UIKit

class DailyViewController: UIViewController {
    let loadingView = LoadingView()
    let dailyView = DailyView()
    let header = TableHeaderView(title: "今日單字") // for header blur effect
    let noDataLabel = UILabel()
    let dictionary = EnglishDictionary()
    var voc = Vocabulary()
    var vocInfos = [VocInfo("今日單字")]
    // fakeTitleCell
    var fakeTitleCell: FakeTitleCell?
    // round corner cell
    var shouldRoundBotCornerCell: VocCell? {
        didSet {
            if let cell = oldValue {
                shouldRemoveRoundCornerCells.append(cell)
            }
        }
    }
    var shouldRoundTopCornerCell: VocCell? {
        didSet {
            if let cell = oldValue {
                shouldRemoveRoundCornerCells.append(cell)
            }
        }
    }
    var shouldRemoveRoundCornerCells = [VocCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(hex: "F5F4F7")
        setLoadingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show & start loadingView
        self.view.bringSubviewToFront(loadingView)
        loadingView.start()
        
        voc.setTodayVoc { (isSuccessful, vocInfos) in
            if isSuccessful {
                // remove noDataLabel
                self.noDataLabel.removeFromSuperview()
                
                self.vocInfos = vocInfos
                self.vocInfos.insert(VocInfo("今日單字"), at: 0) // add data for fakeTitleCell using
            } else {
                // telling user no data exist
                self.setNoDataLabel()
            }
            // set tableView
            self.dailyView.isAdded ? self.dailyView.tableView.reloadData() : self.setDailyView()
            // ???
            self.view.bringSubviewToFront(self.noDataLabel)
            // hide loadingView
            self.loadingView.stop()
            self.loadingView.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // remove previous round corner cells
        for cell in shouldRemoveRoundCornerCells {
            cell.removeRoundCorner()
            cell.shadowView.removeRoundCorner()
        }
        shouldRemoveRoundCornerCells.removeAll()
        // add round corner
        if shouldRoundBotCornerCell == shouldRoundTopCornerCell {
            shouldRoundBotCornerCell?.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
            shouldRoundBotCornerCell?.shadowView.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        } else {
            shouldRoundBotCornerCell?.roundCorners([.bottomLeft, .bottomRight], radius: 10)
            shouldRoundTopCornerCell?.roundCorners([.topLeft, .topRight], radius: 10)
            shouldRoundBotCornerCell?.shadowView.roundCorners([.bottomLeft, .bottomRight], radius: 10)
            shouldRoundTopCornerCell?.shadowView.roundCorners([.topLeft, .topRight], radius: 10)
        }
    }
    
    func setLoadingView () {
        self.view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        loadingView.heightAnchor.constraint(equalTo: loadingView.widthAnchor).isActive = true
    }
    
    func setNoDataLabel () {
        guard !noDataLabel.isDescendant(of: self.view) else {
            return
        }
        self.view.addSubview(noDataLabel)
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noDataLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        noDataLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        noDataLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        noDataLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        
        noDataLabel.text = "找不到資料"
        noDataLabel.textAlignment = .center
        noDataLabel.textColor = .lightGray
        noDataLabel.adjustsFontSizeToFitWidth = true
        noDataLabel.baselineAdjustment = .alignCenters
        noDataLabel.minimumScaleFactor = 0.1
        noDataLabel.font = UIFont.systemFont(ofSize: 17)
    }
    
    func setDailyView () {
        self.view.addSubview(dailyView)
        dailyView.translatesAutoresizingMaskIntoConstraints = false
        
        dailyView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor).isActive = true
        dailyView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor).isActive = true
        dailyView.widthAnchor.constraint(equalTo: self.view.layoutMarginsGuide.widthAnchor).isActive = true
        dailyView.heightAnchor.constraint(equalTo: self.view.layoutMarginsGuide.heightAnchor).isActive = true
        
        dailyView.tableView.delegate = self
        dailyView.tableView.dataSource = self
        dailyView.tableView.register(VocCell.self, forCellReuseIdentifier: "VocCell")
        dailyView.tableView.register(FakeTitleCell.self, forCellReuseIdentifier: "FakeTitleCell")
        dailyView.tableView.rowHeight = UITableView.automaticDimension
        dailyView.tableView.estimatedRowHeight = 60
        
        // turn on flag
        dailyView.isAdded = true
    }
    
    @objc func playSound (sender: CustomButton) {
        if let indexPath = sender.cellIndexPath {
            dictionary.setAudioPlayer(vocInfos[indexPath.row].soundURLs)
            // ???
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dictionary.playAudio()
            }
        }
    }
}

extension DailyViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vocInfos.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FakeTitleCell", for: indexPath) as? FakeTitleCell {
                cell.titleLabel.text = vocInfos[indexPath.row].name
                fakeTitleCell = cell // for animating
                fakeTitleCell?.title = cell.titleLabel.text ?? "" // for animating
                
                return cell
            }
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: "VocCell", for: indexPath) as? VocCell {
            // remove cell corner
            cell.removeRoundCorner()
            cell.shadowView.removeRoundCorner()
            // show dayLabel
            cell.dayLabel.isHidden = false
            // show soundBtn if definitionView is showed
            cell.soundBtn.isHidden = !vocInfos[indexPath.row].showDef
            // add target
            if !cell.soundBtn.isHidden {
                cell.soundBtn.cellIndexPath = indexPath
                cell.soundBtn.addTarget(self, action: #selector(playSound(sender:)), for: .touchUpInside)
            }
            
            cell.vocLabel.text = vocInfos[indexPath.row].name
            cell.definitionLabel.text = vocInfos[indexPath.row].showDef ? vocInfos[indexPath.row].def : ""
            cell.arrowImageView.image = vocInfos[indexPath.row].showDef ? cell.upArrow : cell.downArrow
            cell.shadowView.alpha = vocInfos[indexPath.row].showDef ? 1 : 0
            cell.dayLabel.text = "D\(vocInfos[indexPath.row].day)"
            cell.dayLabel.textColor = vocInfos[indexPath.row].color
            cell.dayLabel.layer.borderColor = vocInfos[indexPath.row].color.cgColor
            
            if indexPath.row == 1 {
                shouldRoundTopCornerCell = cell
                DispatchQueue.main.async {
                    self.viewDidLayoutSubviews()
                }
            }
            if indexPath.row == vocInfos.count - 1 {
                shouldRoundBotCornerCell = cell
                DispatchQueue.main.async {
                    self.viewDidLayoutSubviews()
                }
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? VocCell {
            vocInfos[indexPath.row].showDef.toggle()
            if vocInfos[indexPath.row].showDef {
                UIView.animate(withDuration: 0.2) {
                    cell.arrowImageView.rotate(angle: 180)
                    cell.shadowView.alpha = 1
                } completion: { _ in
                    cell.arrowImageView.rotate(angle: 180)
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
                // set audio player
                dictionary.audioPlayer = nil
                dictionary.setAudioPlayer(vocInfos[indexPath.row].soundURLs)
            } else {
                UIView.animate(withDuration: 0.2) {
                    cell.arrowImageView.rotate(angle: 180)
                    cell.shadowView.alpha = 0
                } completion: { _ in
                    cell.arrowImageView.rotate(angle: 180)
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
}

extension DailyViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 60, !header.isBlur {
            fakeTitleCell?.titleLabel.text = ""
            header.setBlurView()
        } else if scrollView.contentOffset.y < 60, header.isBlur {
            fakeTitleCell?.titleLabel.text = fakeTitleCell?.title
            header.removeBlurView()
        }
    }
}
