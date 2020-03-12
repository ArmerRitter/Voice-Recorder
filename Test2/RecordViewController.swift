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

enum RecorderEror: Error {
    case invalidPath
}

enum RecorderButtonState {
    case Start
    case Pause
    case Resume
}

class RecordViewController: UIViewController, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    var recorder: AVAudioRecorder!
    var recorderButtonState: RecorderButtonState = .Start
    
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
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        view.backgroundColor = .white
        

        recordingSession = AVAudioSession.sharedInstance()
        recordingSession.requestRecordPermission {[unowned self] (granted) in
            if granted {
                print("Allow")
                do {
                    try self.setupRecorder()
                }
                catch {
                    print("Error: recorder is not ready")
                    self.recorder = nil
                }
                //self.setupRecorder()
            }
        }
        
        setView()
        setConstraints()
        
    }
    
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = paths[0].appendingPathComponent("Record.m4a")
        return url
    }
    
    func setupRecorder() throws {
        let filename = getDirectory()
        
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        
        
           try recordingSession.setCategory(.playAndRecord)
           try recordingSession.setActive(true)
           recorder =  try AVAudioRecorder(url: filename, settings: settings)
            recorder.delegate = self
    }

    @objc func startRecord(sender: UIButton) {
        
        switch recorderButtonState {
        case .Start:
            recorder.record()
            recorderButtonState = .Pause
            recordingButton.setTitle("Pause", for: .normal)
        case .Pause:
            recorder.pause()
            recorderButtonState = .Resume
            recordingButton.setTitle("Resume", for: .normal)
        case .Resume:
            recorder.record()
            recorderButtonState = .Pause
            recordingButton.setTitle("Pause", for: .normal)
        }
        
    }
    
    @objc func doneRecord() {
        
        recorder.stop()
        
        do {
            let data =  try fetchAudioData()
            
            let record = Audio(value: [data, Date()])
            StorageManager.shared.addRecord(object: record)
        } catch RecorderEror.invalidPath {
            print("Error: path is not correct to AudioFile")
        } catch {
            print("Error: AudioFile not found")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func fetchAudioData() throws -> Data {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let url = URL(fileURLWithPath: dirPath).appendingPathComponent("Record.m4a")

            let data = try Data(contentsOf: url)
            return data
        }
        throw RecorderEror.invalidPath
    }
    
    
    
    //MARK: Setup UI
    func setView() {
        view.addSubview(recordingButton)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneRecord))
    }
    
    func setConstraints() {
        recordingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        recordingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordingButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        recordingButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
}

