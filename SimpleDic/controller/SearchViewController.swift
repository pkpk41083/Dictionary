//
//  ViewController.swift
//  SimpleDic
//
//  Created by Yukai Chang on 2021/6/17.
//

import UIKit

class SearchViewController: UIViewController {
    let searchView = SearchView()
    let dictionary = EnglishDictionary()
    var voc = Vocabulary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor(hex: "F5F4F7")
        self.tapAnywhereToHideKeyboard()
        setSearchView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let n1 = [1]
        let n2 = [2]
        let mid = n1.count / 2
        let half = n1[...mid]
        print(half)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchView.addShadowEffect(searchView.definitionView)
    }
    
    func setSearchView () {
        self.view.addSubview(searchView)
        searchView.translatesAutoresizingMaskIntoConstraints = false
        
        searchView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor).isActive = true
        searchView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor).isActive = true
        searchView.widthAnchor.constraint(equalTo: self.view.layoutMarginsGuide.widthAnchor).isActive = true
        searchView.heightAnchor.constraint(equalTo: self.view.layoutMarginsGuide.heightAnchor).isActive = true
        
        searchView.goBtn.addTarget(self, action: #selector(tappedGoBtn(sender:)), for: .touchUpInside)
        searchView.definitionView.addBtn.addTarget(self, action: #selector(tappedAddBtn(sender:)), for: .touchUpInside)
        searchView.definitionView.soundBtn.addTarget(self, action: #selector(tappedSoundBtn(sender:)), for: .touchUpInside)
        searchView.definitionView.showExampleBtn.addTarget(self, action: #selector(tappedShowExampleBtn(sender:)), for: .touchUpInside)
    }
    
    @objc func tappedGoBtn (sender: UIButton) {
        // end textField editing
        searchView.searchField.endEditing(true)
        // remove space
        searchView.searchField.dropLastSpace()
        // update loadingView size
        searchView.loadingView.updateView(frame: searchView.loadingView.frame)
        // disable sender when dic consulting not completed
        sender.isEnabled = false
        // show & start loadingView
        searchView.loadingView.isHidden = false
        searchView.loadingView.start()

        dictionary.consultDic(searchView.searchField.text ?? "") { code, dicInfo in
            self.searchView.isShowingDef ? self.searchView.updateDefinitionView(info: dicInfo) : self.searchView.setDefinitionView(info: dicInfo)
            // remove audio player then set
            self.dictionary.audioPlayer = nil
            self.dictionary.setAudioPlayer(dicInfo.audios)
            // set showExampleBtn title
            self.searchView.definitionView.showExampleBtn.setTitle("例句", for: .normal)
            // stop loadingView
            self.searchView.loadingView.stop()
            self.searchView.loadingView.isHidden = true
            // enable sender
            sender.isEnabled = true
        }
    }
    
    @objc func tappedAddBtn (sender: UIButton) {
        // loading
        self.searchView.definitionView.startLoading()

        if let vocName = searchView.definitionView.vocLabel.text {
            voc.saveVocs(vocName) {
                self.searchView.definitionView.stopLoading()
            }
        }
    }
    
    @objc func tappedSoundBtn (sender: UIButton) {
        self.dictionary.playAudio()
    }
    
    @objc func tappedShowExampleBtn (sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            self.searchView.definitionView.definitionLabel.alpha = 0
        } completion: { _ in
            self.searchView.definitionView.defScrollView.setContentOffset(CGPoint.zero, animated: false)
            switch sender.title(for: .normal) {
            case "例句":
                sender.setTitle("解釋", for: .normal)
                self.searchView.definitionView.definitionLabel.text = self.searchView.definitionView.definitionLabel.examples
            case "解釋":
                sender.setTitle("例句", for: .normal)
                self.searchView.definitionView.definitionLabel.text = self.searchView.definitionView.definitionLabel.defs
            default:
                sender.setTitle("解釋", for: .normal)
                self.searchView.definitionView.definitionLabel.text = self.searchView.definitionView.definitionLabel.examples
            }
            self.searchView.definitionView.needSetScrollViewContentSize = true
            UIView.animate(withDuration: 0.2) {
                self.searchView.definitionView.definitionLabel.alpha = 1
            }
        }
    }
}
