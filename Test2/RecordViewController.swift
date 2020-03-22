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
    var stateOfRecorder: RecorderButtonState = .Start
    var timer: Timer?
    var timeIncrementCounter = TimeCounter()
    var constraints: [String : NSLayoutConstraint]!
    var recordPowerViews: [UIView] = []
    let screenSize: CGRect = UIScreen.main.bounds
    
    var counter = 0 {
        didSet {
            let recPower: CGFloat = CGFloat(55 + recorder.averagePower(forChannel: 0))
            
            recordPowerViews[oldValue].frame.size.width = 15
            recordPowerViews[oldValue].frame.size.height = 2 * recPower
            recordPowerViews[oldValue].setGradientBackground(colorOne: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), colorTwo:.clear, location: [0.3, 1.0])
          
            for (i, value) in recordPowerViews.enumerated() {
                value.frame.origin = CGPoint(x: Int(screenSize.width) - 20 * (oldValue - i), y: Int(screenSize.height / 2 - 50))
            view.addSubview(value)
                
            }
        }
    }
    
    weak var delegate: NumberOfRecordDelegate?

    let recordingButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        btn.setTitle("REC", for: .normal)
        btn.layer.cornerRadius = 40
        btn.layer.borderWidth = 5
        btn.layer.borderColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(startRecord), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let timeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = " 00 : 00,0"
        lbl.font = .boldSystemFont(ofSize: 46)
        //lbl.backgroundColor = .purple
        lbl.textColor = .white
        lbl.textAlignment = .left
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    var visualAudioView: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 5
        return view
    }()
    
    var pauseSymbolRight: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        return view
    }()
    
    var pauseSymbolLeft: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        return view
    }()
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        view.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        view.setGradientBackground(colorOne: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), colorTwo: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), location: [0.3, 1.0])
        view.clipsToBounds = true

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
        recorder.isMeteringEnabled = true
    }

    @objc func startRecord(sender: UIButton) {
        
        switch stateOfRecorder {
        case .Start:
            recorder.record()
            setAndResetTimer(on: true)
            animateRecButton(state: stateOfRecorder)
            stateOfRecorder = .Pause
            recordingButton.setTitle("", for: .normal)
            navigationItem.leftBarButtonItem?.isEnabled = true
        case .Pause:
            recorder.pause()
            setAndResetTimer(on: false)
            animateRecButton(state: stateOfRecorder)
            stateOfRecorder = .Resume
        case .Resume:
            recorder.record()
            setAndResetTimer(on: true)
            animateRecButton(state: stateOfRecorder)
            stateOfRecorder = .Pause
            recordingButton.setTitle("", for: .normal)
        }
        
    }
    
    func animateRecButton(state: RecorderButtonState) {
       
        switch state {
        case .Start:
            constraints["leftSymbolRight"]!.isActive = false
            constraints["rightSymbolRight"]!.isActive = true
            constraints["rightSymbolLeft"]!.isActive = false
            constraints["leftSymbolLeft"]!.isActive = true
                
            UIView.animate(withDuration: 0.5) {
               self.view.layoutIfNeeded()
            }
        case .Pause:
            constraints["widthRecBtn"]!.isActive = false
            constraints["widthRecBtnNew"]!.isActive = true
            
            UIView.animate(withDuration: 0.5, animations: {
                let translationRight = CGAffineTransform(translationX: 40, y: 0)
                let translationLeft = CGAffineTransform(translationX: -40, y: 0)
                
                self.pauseSymbolRight.transform = translationRight
                self.pauseSymbolLeft.transform = translationLeft

                self.view.layoutIfNeeded()
                
            }) { (finish) in
                self.recordingButton.setTitle("RESUME", for: .normal)
                
            }
            
        case .Resume:
            constraints["widthRecBtnNew"]!.isActive = false
            constraints["widthRecBtn"]!.isActive = true
            
            UIView.animate(withDuration: 0.5) {
               let scale = CGAffineTransform(scaleX: 1, y: 1)
               self.pauseSymbolRight.transform = scale
               self.pauseSymbolLeft.transform = scale
               
               self.view.layoutIfNeeded()
            }
        }
    }
    
    func setAndResetTimer(on: Bool) {
        
        if on {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .common)
        } else {
            timer?.invalidate()
        }
    }
    
    @objc func onTimer() {
        timeIncrementCounter.deciSeconds += 1
        
            recorder.updateMeters()
           // print(recorder.peakPower(forChannel: 0))
        let viewVisualAudio = visualAudioView.clone()
        recordPowerViews.append(viewVisualAudio)
        counter += 1
        timeLabel.text = timeIncrementCounter.description
    }
    
    @objc func doneRecord() {
        recorder.stop()
        
        do {
            let data =  try fetchAudioData()
            
            
            let timeRecord = Double(timeIncrementCounter.deciSeconds)
            let record = Audio(value: [data, Date(), timeRecord])
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
        view.addSubview(timeLabel)
        
        recordingButton.addSubview(pauseSymbolRight)
        recordingButton.addSubview(pauseSymbolLeft)
        
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneRecord))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    func setConstraints() {
       
        recordingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
            recordingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
           let widthConstraint = recordingButton.widthAnchor.constraint(equalToConstant: 80)
           let widthConstraint2 = recordingButton.widthAnchor.constraint(equalToConstant: 160)
            widthConstraint.isActive = true
            recordingButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
        timeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -screenSize.height / 2 - 100).isActive = true
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            timeLabel.widthAnchor.constraint(equalToConstant: 205).isActive = true
            timeLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            let leftConstraint = pauseSymbolRight.leftAnchor.constraint(equalTo: recordingButton.leftAnchor, constant:  -30)
            leftConstraint.isActive = true
            let rightConstraint = pauseSymbolRight.rightAnchor.constraint(equalTo: recordingButton.rightAnchor, constant:  -25)
            
            pauseSymbolRight.centerYAnchor.constraint(equalTo: recordingButton.centerYAnchor).isActive = true
            pauseSymbolRight.widthAnchor.constraint(equalToConstant: 10).isActive = true
            pauseSymbolRight.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            
            let rightConstraint2 = pauseSymbolLeft.rightAnchor.constraint(equalTo: recordingButton.rightAnchor, constant:  30)
            rightConstraint2.isActive = true
            let leftConstraint2 = pauseSymbolLeft.leftAnchor.constraint(equalTo: recordingButton.leftAnchor, constant:  25)
            
            pauseSymbolLeft.centerYAnchor.constraint(equalTo: recordingButton.centerYAnchor).isActive = true
            pauseSymbolLeft.widthAnchor.constraint(equalToConstant: 10).isActive = true
            pauseSymbolLeft.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            constraints = ["widthRecBtn" : widthConstraint,                        "widthRecBtnNew" : widthConstraint2,
                           "leftSymbolRight" : leftConstraint,
                           "rightSymbolRight" : rightConstraint,
                           "leftSymbolLeft" : leftConstraint2,
                           "rightSymbolLeft" : rightConstraint2]
            
        }
        
        
    
}

