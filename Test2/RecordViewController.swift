//
//  RecordViewController.swift
//  Test2
//
//  Created by Yuriy Balabin on 10.03.2020.
//  Copyright © 2020 None. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

protocol NumberOfRecordDelegate: class {
    func update(n: Int)
}



class RecordViewController: UIViewController, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    var recorder: AVAudioRecorder!
    
    weak var delegate: NumberOfRecordDelegate?

    let recordingButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .red
        btn.setTitle("Start", for: .normal)
        btn.layer.cornerRadius = 50
        btn.layer.borderWidth = 3
        btn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        btn.addTarget(self, action: #selector(startRecord), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var countOfRecords = 0
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        
        
        recordingSession = AVAudioSession.sharedInstance()
        
        if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
            countOfRecords = number
        }
        
        recordingSession.requestRecordPermission { (granted) in
            if granted {
                print("Allow")
            }
        }
        
        setView()
        setConstraints()
    }
    
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
       
        return paths[0]
    }
    
   
    
    @objc func startRecord() {
        
        if recorder == nil {
            countOfRecords += 1
            //ex.ex += 1
            print(countOfRecords)
            let filename = getDirectory().appendingPathComponent("Record \(countOfRecords).m4a")
            
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            do {
               //try recordingSession.setCategory(.playAndRecord)
               recorder =  try AVAudioRecorder(url: filename, settings: settings)
                recorder.delegate = self
                recorder.record()
                
                recordingButton.setTitle("Stop", for: .normal)
            }
            catch {
                print("Error of recording")
            }
        } else {
            recorder.stop()
            recorder = nil
            recordingButton.setTitle("Start", for: .normal)
            
            let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
            let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
            
            if let dirPath = paths.first {
                let url = URL(fileURLWithPath: dirPath).appendingPathComponent("Record \(countOfRecords).m4a")
                
                let data = try! Data(contentsOf: url)
               
                let record = Audio(value: [data, Date()])
                StorageManager.shared.addRecord(object: record)
            }
            
            
        }
    }
    
    func setView() {
        view.addSubview(recordingButton)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(lol))
    }
    
    @objc func lol() {
        print(countOfRecords,"Done")
        delegate?.update(n: countOfRecords)
        navigationController?.popViewController(animated: true)
        
    }
    
    
    
    func setConstraints() {
        recordingButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 500).isActive = true
        recordingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordingButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        recordingButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
}

