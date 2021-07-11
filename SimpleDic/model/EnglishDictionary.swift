//
//  EnglishDictionary.swift
//  SimpleDic
//
//  Created by Yukai Chang on 2021/6/17.
//

import Foundation
import Alamofire
import Kanna
import AVFoundation

class EnglishDictionary {
    struct DicInfo {
        var definitions: [String]
        var examples: [String]
        var audios: [String]
        
        init() {
            self.definitions = [String]()
            self.examples = [String]()
            self.audios = [String]()
        }
        
        init(definitions: [String], examples: [String], audios: [String]) {
            self.definitions = definitions
            self.examples = examples
            self.audios = audios
        }
    }
    var audioPlayer: AVAudioPlayer?
    
    func consultDic (_ v: String, handler: @escaping (Int, DicInfo) -> Void) {
        if let encodeVoc = v.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
           let url = URL(string: "https://tw.dictionary.search.yahoo.com/search;_ylt=AwrtXG67xcpglAUADS57rolQ;_ylc=X1MDMTM1MTIwMDM3OQRfcgMyBGZyAwRncHJpZANKWHJxMmQ1LlNMLnZXYmZvb0lCenBBBG5fcnNsdAMwBG5fc3VnZwMxMARvcmlnaW4DdHcuZGljdGlvbmFyeS5zZWFyY2gueWFob28uY29tBHBvcwMwBHBxc3RyAwRwcXN0cmwDMARxc3RybAM1BHF1ZXJ5A2FwcGxlBHRfc3RtcAMxNjIzOTAxNjQy?p=\(encodeVoc)&fr=sfp&iscqry=") {
            AF.request(url, method: .get, encoding: JSONEncoding.default, headers: nil).responseString { response in
                guard let httpCode = response.response?.statusCode else {
                    handler(404, DicInfo())
                    return
                }
                guard httpCode < 300 && httpCode >= 200 else {
                    handler(httpCode, DicInfo())
                    return
                }
                if let data = response.data,
                   let html = String(data: data, encoding: .utf8),
                   let doc = try? HTML(html: html, encoding: .utf8) {
                    let definition = "lh-22 mh-22 mt-12 mb-12 mr-25"
                    let example = " d-b fz-14 fc-2nd lh-20 "
                    var definitions = [String]()
                    var examples = [String]()
                    var audios = [String]()
                    
                    for link in doc.xpath("//script") {
                        if let content = link.text {
                            audios = self.findAudioURLString(voc: v, content: content)
                        }
                        
                    }
                    for link in doc.xpath("//li") {
                        if let className = link.className {
                            if className.contains(definition) {
                                definitions.append(link.text ?? "")
                            }
                        }
                    }
                    for link in doc.xpath("//span") {
                        if let className = link.className {
                            if className.contains(example) {
                                examples.append(link.text ?? "")
                            }
                        }
                    }
                    handler(httpCode, DicInfo(definitions: definitions, examples: examples, audios: audios))
                }
            }
        } else {
            print("url error")
        }
    }
    
    func findAudioURLString (voc: String, content: String) -> [String] {
        struct URLIndex {
            var start: Int
            var end: Int
            
            init() {
                self.start = 0
                self.end = 0
            }
        }
        
        if content.contains("\(voc.lowercased()).mp3") {
            let indices1 = content.indicesOf(string: "\(voc.lowercased()).mp3", bound: .upper)
            let indices2 = content.indicesOf(string: "https", bound: .lower)
            var urlIndexes = [URLIndex]()
            
            for index1 in 0...indices1.count - 1 {
                var dif: Int?
                var urlIndex = URLIndex()
                
                for index2 in 0...indices2.count - 1 {
                    let i1 = indices1[index1]
                    let i2 = indices2[index2]
                    var skipIndexes = [Int]()
                    
                    if i1 < i2 || skipIndexes.contains(index2) {
                        continue
                    }
                    let newDif = i1 - i2
                    
                    if dif == nil {
                        dif = newDif
                        urlIndex.start = i2
                        urlIndex.end = i1
                        if skipIndexes.count - 1 < index1 {
                            skipIndexes.append(index2)
                        } else {
                            skipIndexes[index1] = index2
                        }
                        if urlIndexes.count - 1 < index1 {
                            urlIndexes.append(urlIndex)
                        } else {
                            urlIndexes[index1] = urlIndex
                        }
                    } else if dif! > newDif {
                        dif = newDif
                        urlIndex.start = i2
                        urlIndex.end = i1
                        if skipIndexes.count - 1 < index1 {
                            skipIndexes.append(index2)
                        } else {
                            skipIndexes[index1] = index2
                        }
                        if urlIndexes.count - 1 < index1 {
                            urlIndexes.append(urlIndex)
                        } else {
                            urlIndexes[index1] = urlIndex
                        }
                    }
                }
                
            }
            var urlStrings = [String]()
            for urlIndex in urlIndexes {
                let startIndex = content.index(content.startIndex, offsetBy: urlIndex.start)
                let endIndex = content.index(content.startIndex, offsetBy: urlIndex.end)
                let range = startIndex...endIndex
                var urlString = ""
                
                for char in Array(String(content[range])) {
                    if char == "\\" || char == "\"" {
                        continue
                    }
                    urlString += String(char)
                }
                urlStrings.append(urlString)
            }
            
            return urlStrings
        }
        return [String]()
    }
    
    func setAudioPlayer (_ urlStrings: [String]) {
        guard urlStrings.count > 0 else {
            self.audioPlayer = nil
            return
        }
        guard let url = URL(string: urlStrings[0]) else {
            self.audioPlayer = nil
            return
        }
        AF.download(url, method: .get).response { res in
            guard let fileURL = res.fileURL else { return }
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                self.audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            } catch {
                self.audioPlayer = nil
                print(error.localizedDescription)
            }
        }
    }
    
    func playAudio () {
        guard let audioPlayer = audioPlayer else {
            return
        }
        audioPlayer.play()
    }
}
