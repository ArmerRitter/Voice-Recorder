//
//  RecordCell.swift
//  Test2
//
//  Created by Yuriy Balabin on 18.03.2020.
//  Copyright © 2020 None. All rights reserved.
//

import UIKit
import AVFoundation

// state player model
enum PlayerState {
    case Ready
    case Play
    case Pause
}

class RecordCell: UITableViewCell {
    
//MARK: Variables
    var stateOfPlayer: PlayerState = .Ready
    var timer: CADisplayLink!
    var startValueOfTimer: Double!
    var durationOfPlayback: Double = 0
    var startValueOfPlayback: Float = 0
    var timeIncrementCounter: TimeCounter = TimeCounter()
    var timeDecrementCounter: TimeCounter = TimeCounter()
    
    
//MARK: UI Elements
    var backgroundCellView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setGradientBackground(colorOne: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), colorTwo: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), location: [0.0,0.4])
        return view
    }()
    
    var nameRecordLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    var dateRecordLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    var durationRecordLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    var startTimeOfPlaybarLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "00:00"
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    var endTimeOfPlaybarLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    var playButtonImage: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 14, y: 11, width: 28, height: 28))
        view.image = UIImage(named: "play")
        return view
    }()
    
    var pauseButtonImage: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 13, y: 13, width: 24, height: 24))
        view.image = UIImage(named: "pause")
        return view
    }()
    
    var forwardButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "forward"), for: .normal)
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var backwardButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "backward"), for: .normal)
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var playButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 25
        btn.layer.borderWidth = 4
        btn.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var playbarSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.value = 0
        slider.maximumTrackTintColor = #colorLiteral(red: 0.6225369821, green: 0.2933016655, blue: 0.3230106177, alpha: 1)
        slider.minimumTrackTintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        slider.setThumbImage(UIImage(named: "circle-16"), for: .normal)
        slider.isExclusiveTouch = true
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
        }()
    
    
//MARK: Play Button - Action
    @objc func playAudio() {
        
        PlaybackManager.shared.player.delegate = self
        PlaybackManager.shared.delegate = self
        
        durationOfPlayback = PlaybackManager.shared.playbackDuration
        playbarSlider.maximumValue = Float(durationOfPlayback)
        
        print(durationOfPlayback)
        switch stateOfPlayer {
        case .Ready:
            startValueOfTimer = CACurrentMediaTime()
            timer = CADisplayLink(target: self, selector: #selector(updateAnimationOfPlaybar))
            timer.add(to: .main, forMode: .common)
            playbarSlider.value = 0
            
            playButtonImage.isHidden = true
            pauseButtonImage.isHidden = false
            
            PlaybackManager.shared.play()
            stateOfPlayer = .Play
        case .Play:
            print("pause")
            playButtonImage.isHidden = false
            pauseButtonImage.isHidden = true
            
            PlaybackManager.shared.pause()
            timer.isPaused = true
          
            startValueOfPlayback = playbarSlider.value
            stateOfPlayer = .Pause
        case .Pause:
            print("play")
            playButtonImage.isHidden = true
            pauseButtonImage.isHidden = false
                     
            timer.isPaused = false
            PlaybackManager.shared.play()
            startValueOfTimer = CACurrentMediaTime()
            stateOfPlayer = .Play
        }
            
    }
    
//MARK: Playbar Updating - Functions
    
    @objc func makePlaybackForward() {
   
       durationOfPlayback = PlaybackManager.shared.playbackDuration
       playbarSlider.maximumValue = Float(durationOfPlayback)
       
        guard playbarSlider.value < playbarSlider.maximumValue else { return }
           
            if stateOfPlayer == .Play {
                timer.isPaused = true
                PlaybackManager.shared.pause()
            }
                
                playbarSlider.value += 1
                PlaybackManager.shared.player.currentTime += 1
                startValueOfPlayback = playbarSlider.value
            
            if playbarSlider.value == playbarSlider.maximumValue{
                updatePlaybarTimers()
                refreshPlaybar()
                return
            }
            
            if stateOfPlayer == .Play {
                PlaybackManager.shared.play()
                startValueOfTimer = CACurrentMediaTime()
                timer.isPaused = false
            }
        
            updatePlaybarTimers()
        
            
        
        print(playbarSlider.value)
        print(PlaybackManager.shared.player.currentTime)
   
    }
    
    @objc func makePlaybackBackward() {
        
        guard playbarSlider.value > 0 else { return }
        
        if playbarSlider.value == playbarSlider.maximumValue {
            PlaybackManager.shared.player.currentTime = durationOfPlayback
            
            playbarSlider.value -= 10
            PlaybackManager.shared.player.currentTime -= 10
            startValueOfPlayback = playbarSlider.value
           
            updatePlaybarTimers()
            return
        }
        
        if stateOfPlayer == .Play {
            timer.isPaused = true
            PlaybackManager.shared.pause()
        }
        
        playbarSlider.value -= 10
        PlaybackManager.shared.player.currentTime -= 10
        startValueOfPlayback = playbarSlider.value
                
        if stateOfPlayer == .Play {
            PlaybackManager.shared.play()
            startValueOfTimer = CACurrentMediaTime()
            timer.isPaused = false
        }
            
             updatePlaybarTimers()
         
    }
    
    @objc func updatePlaybarWithDrag() {
        print("drag")
        updatePlaybarTimers()
    }
    
    @objc func updatePlaybarWithTouchDown() {
        print("down")
            timer.isPaused = true
            PlaybackManager.shared.pause()
    }
    
    @objc func updatePlaybarWithTouchUp() {
        print("up")
        
        PlaybackManager.shared.player.currentTime = Double(playbarSlider.value)
        startValueOfPlayback = playbarSlider.value
        
               
        updatePlaybarTimers()
        
        if stateOfPlayer == .Play {
            PlaybackManager.shared.play()
            startValueOfTimer = CACurrentMediaTime()
            timer.isPaused = false
        }
    }
    
    @objc func updatePlaybarWithTap(sender: UIGestureRecognizer) {
        print("tap")
        
        let pointTapped: CGPoint = sender.location(in: self.backgroundView)
        
        let positionOfSlider: CGPoint = playbarSlider.frame.origin
        let widthOfSlider: CGFloat = playbarSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(playbarSlider.maximumValue) / widthOfSlider)
        playbarSlider.setValue(Float(newValue), animated: true)
        
        updatePlaybarWithTouchUp()
    }
    
    @objc func updateAnimationOfPlaybar() {
               
        let now = CACurrentMediaTime()
        let endTime = now + durationOfPlayback
        
        if now >= endTime {
            timer.isPaused = true
            timer.invalidate()
        }
        
        let percentage = (now - startValueOfTimer) / durationOfPlayback
        playbarSlider.value = startValueOfPlayback + Float(percentage * durationOfPlayback)
          
        print(playbarSlider.value, "???", PlaybackManager.shared.player.currentTime)
       // print(PlaybackManager.shared.player.currentTime)
        
        updatePlaybarTimers()
        
    }
    
    func updatePlaybarTimers() {
      timeIncrementCounter.deciSeconds = Int(playbarSlider.value) * 10
      startTimeOfPlaybarLabel.text = timeIncrementCounter.descriptionSecond
      
      timeDecrementCounter.deciSeconds = (Int(durationOfPlayback) - Int(playbarSlider.value)) * 10
      endTimeOfPlaybarLabel.text = timeDecrementCounter.descriptionThird
    }
    
    func refreshPlaybar() {
        stateOfPlayer = .Ready
        playButtonImage.isHidden = false
        pauseButtonImage.isHidden = true
        timer.isPaused = true
        timer.invalidate()
        startValueOfPlayback = 0
    }
    
//MARK: Cell Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        addSubview(backgroundCellView)
        addSubview(nameRecordLabel)
        addSubview(dateRecordLabel)
        addSubview(durationRecordLabel)
        addSubview(playButton)
        addSubview(forwardButton)
        addSubview(backwardButton)
        playButton.addSubview(playButtonImage)
        playButton.addSubview(pauseButtonImage)
        addSubview(playbarSlider)
        addSubview(startTimeOfPlaybarLabel)
        addSubview(endTimeOfPlaybarLabel)
        
       
                
        print(durationOfPlayback, "ff")
        pauseButtonImage.isHidden = true
        playButton.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        
        forwardButton.addTarget(self, action: #selector(makePlaybackForward), for: .touchUpInside)
        backwardButton.addTarget(self, action: #selector(makePlaybackBackward), for: .touchUpInside)
        
        
        playbarSlider.addTarget(self, action: #selector(updatePlaybarWithDrag), for: .valueChanged)
        playbarSlider.addTarget(self, action: #selector(updatePlaybarWithTouchUp), for: UIControl.Event(rawValue: UIControl.Event.touchUpOutside.rawValue | UIControl.Event.touchUpInside.rawValue))
        playbarSlider.addTarget(self, action: #selector(updatePlaybarWithTouchDown), for: .touchDown)
   
    playbarSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updatePlaybarWithTap)))
        
        endTimeOfPlaybarLabel.topAnchor.constraint(equalTo: playbarSlider.topAnchor, constant: 20).isActive = true
        endTimeOfPlaybarLabel.rightAnchor.constraint(equalTo: playbarSlider.rightAnchor).isActive = true
        
        startTimeOfPlaybarLabel.topAnchor.constraint(equalTo: playbarSlider.topAnchor, constant: 20).isActive = true
        startTimeOfPlaybarLabel.leftAnchor.constraint(equalTo: playbarSlider.leftAnchor).isActive = true
        
        playbarSlider.topAnchor.constraint(equalTo: self.topAnchor, constant: 85).isActive = true
        playbarSlider.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 30).isActive = true
        playbarSlider.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30).isActive = true
               
        playButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 130).isActive = true
        playButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        forwardButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 132).isActive = true
        forwardButton.leftAnchor.constraint(equalTo: playButton.rightAnchor, constant: 20).isActive = true
        forwardButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        forwardButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        backwardButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 132).isActive = true
        backwardButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -20).isActive = true
        backwardButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        backwardButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameRecordLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        nameRecordLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        
        dateRecordLabel.topAnchor.constraint(equalTo: nameRecordLabel.bottomAnchor, constant: 5).isActive = true
        dateRecordLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        
        durationRecordLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        durationRecordLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
      
        backgroundCellView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        backgroundCellView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        backgroundCellView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundCellView.heightAnchor.constraint(equalToConstant: 120).isActive = true
 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: Delegates
extension RecordCell: AVAudioPlayerDelegate, PlaybackManagerDelegate {
    
    func audioPlayerDidInterrupted() {
        refreshPlaybar()
        playbarSlider.value = 0
        updatePlaybarTimers()
        
    }
    
   func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        refreshPlaybar()
    }
}
