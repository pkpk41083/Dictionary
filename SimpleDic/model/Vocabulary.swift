//
//  Vocabulary.swift
//  SimpleDic
//
//  Created by Yukai Chang on 2021/6/22.
//

import UIKit

struct VocInfo {
    var name: String
    var showDef: Bool
    var def: String
    var example: String
    var day: String
    var color: UIColor
    var soundURLs: [String]
    
    init(_ name: String) {
        self.name = name
        self.showDef = false
        self.def = ""
        self.example = ""
        self.day = ""
        self.color = .gray
        self.soundURLs = [String]()
    }
}

struct Vocabulary {
    var allVocs: [String: [String]]
    var longTermVocs: [String]
    var todayVocs: [Int: [String]]
    let dictionary = EnglishDictionary()
    
    init() {
        self.allVocs = [String: [String]]()
        self.longTermVocs = [String]()
        self.todayVocs = [Int: [String]]()
    }
    
    private func getUserDefaultsKey (_ key: UserDefaultsKey) -> String {
        return key.rawValue
    }
    
    mutating func saveVocs (_ voc: String, handler: @escaping () -> Void) {
        self.getVocs()
        if var vocs = allVocs[Date().getString()] {
            // avoid repeatation
            if !vocs.contains(voc) {
                vocs.append(voc)
                allVocs[Date().getString()] = vocs
            }
        } else {
            allVocs[Date().getString()] = [voc]
        }
        UserDefaults.standard.setValue(allVocs, forKey: getUserDefaultsKey(.allVocs))
        // callback
        handler()
    }
    
    mutating func getVocs () {
        if let allVocs = UserDefaults.standard.value(forKey: getUserDefaultsKey(.allVocs)) as? [String: [String]] {
            self.allVocs = allVocs
        }
    }
    
    mutating func setTodayVoc (handler: @escaping (Bool, [VocInfo]) -> Void) {
        self.getVocs()
        // set Fibonacci to 21
        let fibonaccis = [1, 2, 3, 5, 8, 13, 21]
        // find vocs with fibonaccis
        let timestamp = Int(Date().timeIntervalSince1970)
        for fibonacci in fibonaccis {
            let newTimestamp = TimeInterval(timestamp - ((fibonacci - 1) * 86400))
            let newDate = Date(timeIntervalSince1970: newTimestamp)
            
            if let vocs = allVocs[newDate.getString()] {
                self.todayVocs[fibonacci] = vocs
            }
        }
        // arrange data
        var vocInfos = [VocInfo]()
        var count = 0 // callback when it finish consulting
        let fullCount = todayVocs.getNumberOfValues()
        let colorDic = ["1": UIColor(hex: "AE452A"), "2": UIColor(hex: "AE7330"), "3": UIColor(hex: "AE973A"), "5": UIColor(hex: "A5AE3E"), "8": UIColor(hex: "7FAE3C"), "13": UIColor(hex: "1DB100"), "21": UIColor(hex: "2EAE81")]
        
        for (day, vocs) in todayVocs {
            for voc in vocs {
                var vocInfo = VocInfo(voc)
                dictionary.consultDic(voc) { code, dicInfo in
                    for def in dicInfo.definitions {
                        vocInfo.def += "\(def)\n"
                    }
                    for example in dicInfo.examples {
                        vocInfo.example += "\(example)\n"
                    }
                    vocInfo.day = "\(day)"
                    vocInfo.color = colorDic[vocInfo.day] ?? UIColor.systemGray
                    vocInfo.soundURLs = dicInfo.audios
                    vocInfos.append(vocInfo)
                    // add 1 count
                    count += 1
                    if count == fullCount {
                        // sort
                        vocInfos.sort { voc1, voc2 in
                            let day1 = Int(voc1.day) ?? 0
                            let day2 = Int(voc2.day) ?? 0
                            let name1 = voc1.name
                            let name2 = voc2.name
                            
                            if day1 < day2 {
                                return true
                            } else if day1 == day2 {
                                return name1 < name2
                            } else {
                                return false
                            }
                        }
                        // call completion handler
                        handler(true, vocInfos)
                    }
                }
            }
        }
        if fullCount == 0 {
            handler(false, [VocInfo]())
        }
    }
    
    mutating func getLongTermVocs () {
        if let longTermVocs = UserDefaults.standard.value(forKey: getUserDefaultsKey(.longTermVocs)) as? [String] {
            self.longTermVocs = longTermVocs
        }
    }
    
    mutating func setLongTermVoc (handler: @escaping (Bool, [VocInfo]) -> Void) {
        var newAllVocs = [String: [String]]()
        var longTermVocs = [String]()
        var longTermVocInfos = [VocInfo]()
        
        self.getVocs()
        self.getLongTermVocs()
        for (date, vocs) in allVocs {
            if date.estimateDays() > 21 {
                longTermVocs += vocs
            } else {
                newAllVocs[date] = vocs
            }
        }
        // add previous long-term vocs
        longTermVocs += self.longTermVocs
        // separate long-term voc and all voc
        UserDefaults.standard.setValue(newAllVocs, forKey: getUserDefaultsKey(.allVocs))
        UserDefaults.standard.setValue(longTermVocs, forKey: getUserDefaultsKey(.longTermVocs))
        // arrange data
        var count = 0
        let fullCount = longTermVocs.count
        
        for voc in longTermVocs {
            var vocInfo = VocInfo(voc)
            dictionary.consultDic(voc) { httpCode, dicInfo in
                for def in dicInfo.definitions {
                    vocInfo.def += "\(def)\n"
                }
                for example in dicInfo.examples {
                    vocInfo.example += "\(example)\n"
                }
                vocInfo.soundURLs = dicInfo.audios
                longTermVocInfos.append(vocInfo)
                // wait for last voc finishes consulting
                count += 1
                if count == fullCount {
                    longTermVocInfos.sort(by: {$0.name < $1.name})
                    handler(true, longTermVocInfos)
                }
            }
        }
        if fullCount == 0 {
            handler(false, [VocInfo]())
        }
    }
}
