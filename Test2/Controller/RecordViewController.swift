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


enum RecorderEror: Error {
    case invalidPath
}

enum RecorderButtonState {
    case Start
    case Pause
    case Resume
}

class RecordViewController: UIViewController, AVAudioRecorderDelegate {
  
//MARK: Variables
    var recordingSession: AVAudioSession!
    var recorder: AVAudioRecorder!
    var stateOfRecorder: RecorderButtonState = .Start
    var timer: Timer?
    var timeIncrementCounter: TimeCounter = TimeCounter()
    var animatedConstraints: [String : NSLayoutConstraint]!
    var voicePiece = CALayer()
    var replicator = CAReplicatorLayer()
    var counterOfAnimations = 0
    var lastScaleRate: CGFloat = 0.0
    
    let pieceLength: CGFloat = 4.0
    let pieceOffset: CGFloat = 10.0
    let screenSize: CGRect = UIScreen.main.bounds
    
    
 //MARK: UI Elements
    let recordButton: UIButton = {
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
    
    var pauseSymbolRightView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        return view
    }()
    
    var pauseSymbolLeftView: UIView = {
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
            }
        }
        
        setView()
        setConstraints()
        
    }
    

//MARK: Record Button - Action
    @objc func startRecord(sender: UIButton) {
        
        switch stateOfRecorder {
        case .Start:
            recorder.record()
            setAndResetTimer(on: true)
            animateRecordButton(state: stateOfRecorder)
            recordButton.setTitle("", for: .normal)
            navigationItem.leftBarButtonItem?.isEnabled = true
            stateOfRecorder = .Pause
        case .Pause:
            recorder.pause()
            setAndResetTimer(on: false)
            animateRecordButton(state: stateOfRecorder)
            stateOfRecorder = .Resume
        case .Resume:
            recorder.record()
            setAndResetTimer(on: true)
            animateRecordButton(state: stateOfRecorder)
            recordButton.setTitle("", for: .normal)
            stateOfRecorder = .Pause
        }
        
    }
    
    
//MARK: Record Button - Animation
    func animateRecordButton(state: RecorderButtonState) {
       
        switch state {
        case .Start: //Start
            animatedConstraints["leftSymbolRight"]!.isActive = false
            animatedConstraints["rightSymbolRight"]!.isActive = true
            animatedConstraints["rightSymbolLeft"]!.isActive = false
            animatedConstraints["leftSymbolLeft"]!.isActive = true
                
            UIView.animate(withDuration: 0.5) {
               self.view.layoutIfNeeded()
            }
        case .Pause: //Pause
            animatedConstraints["widthRecBtn"]!.isActive = false
            animatedConstraints["widthRecBtnNew"]!.isActive = true
            
            UIView.animate(withDuration: 0.5, animations: {
                let translationRight = CGAffineTransform(translationX: 40, y: 0)
                let translationLeft = CGAffineTransform(translationX: -40, y: 0)
                
                self.pauseSymbolRightView.transform = translationRight
                self.pauseSymbolLeftView.transform = translationLeft

                self.view.layoutIfNeeded()
                
            }) { (finish) in
                self.recordButton.setTitle("RESUME", for: .normal)
            }
        case .Resume: //Resume
            animatedConstraints["widthRecBtnNew"]!.isActive = false
            animatedConstraints["widthRecBtn"]!.isActive = true
            
            UIView.animate(withDuration: 0.5) {
               let scale = CGAffineTransform(scaleX: 1, y: 1)
               self.pauseSymbolRightView.transform = scale
               self.pauseSymbolLeftView.transform = scale
               
               self.view.layoutIfNeeded()
            }
        }
    }
    
    func setAndResetTimer(on: Bool) {
        
        if on {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateAnimationOfRecord), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .common)
        } else {
            timer?.invalidate()
        }
    }
    
    
//MARK: Animation of record
    @objc func updateAnimationOfRecord() {
        timeIncrementCounter.deciSeconds += 1
        counterOfAnimations += 1
        
        recorder.updateMeters()
        
        if counterOfAnimations == 2 {
        
        var scaleRate =  CGFloat(recorder.averagePower(forChannel: 0) + 55) / 3
        
        var k: CGFloat
        let delta = abs(scaleRate - lastScaleRate)
        
            switch delta {
            case 1...2: k = 1
            case 2...3: k = 1.5
            default:
                k = 0.5
            }

        lastScaleRate = scaleRate
        scaleRate *= k
        print(scaleRate)
        let scale = CABasicAnimation(keyPath: "transform.scale.y")
        scale.fromValue = max(1,scaleRate)
        scale.toValue = max(1,scaleRate)
        scale.duration = 0.1
        scale.isRemovedOnCompletion = false
        scale.fillMode = .forwards
        self.voicePiece.add(scale, forKey: nil)
         
        
        counterOfAnimations = 0
        }
        
        timeLabel.text = timeIncrementCounter.description
    }
    
    
//MARK: Setup Recorder
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
    

//MARK: Manage Audio Data
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
    
    
//MARK: Setup UI
    func setView() {
        view.addSubview(recordButton)
        view.addSubview(timeLabel)
        
        recordButton.addSubview(pauseSymbolRightView)
        recordButton.addSubview(pauseSymbolLeftView)
        
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneRecord))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        //setup visualization record
        replicator.frame = view.bounds
        view.layer.addSublayer(replicator)
        
        voicePiece.frame = CGRect(
        x: replicator.frame.size.width - pieceLength,
        y: replicator.position.y,
        width: pieceLength, height: pieceLength)
        
        voicePiece.backgroundColor = UIColor.white.cgColor
        //voicePiece.setUltimateGradientBackground(colorOne: .clear, colorTwo: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), colorThree: .clear, location: [0.0,0.5,1.0])
        voicePiece.cornerRadius = 1
        
        replicator.addSublayer(voicePiece)
        let instanceCount = Int(view.frame.size.width / pieceOffset)
        replicator.instanceCount = instanceCount
        replicator.instanceTransform = CATransform3DMakeTranslation(-pieceOffset, 0.0, 0.0)
        replicator.instanceDelay = 0.2
    }

    
//MARK: Setup Constraints
    func setConstraints() {
       
        recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
           let widthConstraint = recordButton.widthAnchor.constraint(equalToConstant: 80)
           let widthConstraint2 = recordButton.widthAnchor.constraint(equalToConstant: 160)
            widthConstraint.isActive = true
            recordButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
        timeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -screenSize.height / 2 - 100).isActive = true
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            timeLabel.widthAnchor.constraint(equalToConstant: 205).isActive = true
            timeLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            let leftConstraint = pauseSymbolRightView.leftAnchor.constraint(equalTo: recordButton.leftAnchor, constant:  -30)
            leftConstraint.isActive = true
            let rightConstraint = pauseSymbolRightView.rightAnchor.constraint(equalTo: recordButton.rightAnchor, constant:  -25)
            
            pauseSymbolRightView.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
            pauseSymbolRightView.widthAnchor.constraint(equalToConstant: 10).isActive = true
            pauseSymbolRightView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            
            let rightConstraint2 = pauseSymbolLeftView.rightAnchor.constraint(equalTo: recordButton.rightAnchor, constant:  30)
            rightConstraint2.isActive = true
            let leftConstraint2 = pauseSymbolLeftView.leftAnchor.constraint(equalTo: recordButton.leftAnchor, constant:  25)
            
            pauseSymbolLeftView.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
            pauseSymbolLeftView.widthAnchor.constraint(equalToConstant: 10).isActive = true
            pauseSymbolLeftView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            animatedConstraints = ["widthRecBtn" : widthConstraint,                        "widthRecBtnNew" : widthConstraint2,
                           "leftSymbolRight" : leftConstraint,
                           "rightSymbolRight" : rightConstraint,
                           "leftSymbolLeft" : leftConstraint2,
                           "rightSymbolLeft" : rightConstraint2]
            
        }
        

}

