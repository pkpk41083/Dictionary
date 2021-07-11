//
//  DailyView.swift
//  SimpleDic
//
//  Created by Yukai Chang on 2021/6/18.
//

import UIKit

class DailyView: UIView {
    let tableView = UITableView()
    var isAdded = false
    
    init() {
        super.init(frame: .zero)
        
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setView () {
        self.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
}
