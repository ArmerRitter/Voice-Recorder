//
//  PlaybackManager.swift
//  Test2
//
//  Created by Yuriy Balabin on 19.03.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation
import AVFoundation
import RealmSwift

protocol PlaybackManagerDelegate: class {
    func audioPlayerDidInterrupted()
}

class PlaybackManager {
    
    static let shared = PlaybackManager()
    
    var records: Results<Audio> = StorageManager.shared.fetchRecords()
    var player: AVAudioPlayer!
    var playbackSession: AVAudioSession!
    var playbackDuration: Double!
    weak var delegate: PlaybackManagerDelegate?
    
    func prepareToPlayback(numberOfRecord: Int) {
        let record = records[numberOfRecord]
        delegate?.audioPlayerDidInterrupted()
        
         playbackSession = AVAudioSession.sharedInstance()
         
         do {
             try playbackSession.setCategory(.playback)
             try playbackSession.setActive(true)
             player = try AVAudioPlayer(data: record.recordData!)
             player.prepareToPlay()
             player.delegate?.audioPlayerDidFinishPlaying?(player, successfully: true)
             player.volume = 4.0
             } catch {
                 print("Error of playback")
             }
        
        playbackDuration = record.recordDuration / 10
        
    }
    
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.stop()
    }
    
    
}



