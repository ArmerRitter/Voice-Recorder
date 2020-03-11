//
//  MainViewController.swift
//  Test2
//
//  Created by Yuriy Balabin on 10.03.2020.
//  Copyright © 2020 None. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class MainViewController: UITableViewController, NumberOfRecordDelegate {
    

    var number: Int?
    var records: Results<Audio>!
    var player: AVAudioPlayer!
    var playbackSession: AVAudioSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   Realm.Configuration.defaultConfiguration = config
        setView()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func update(n: Int) {
        print(records.count)
    }
    
    @objc func addNewRecord() {
        let vc = RecordViewController()
        //navigationController?.pushViewController(vc, animated: true)
        vc.delegate = self
        show(vc, sender: self)
    }
    
    func setView() {
        
        records = StorageManager.shared.fetchRecords()
        print(records.count )
        let newRecordButton: UIBarButtonItem = {
            let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewRecord))
            return button
        }()
        
        navigationItem.rightBarButtonItem = newRecordButton
        
        navigationController?.navigationBar.backgroundColor = .gray
        
        self.title = "Record list"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //tableView.separatorStyle = .none
    }

   

}

extension MainViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = records[indexPath.row]
        playbackSession = AVAudioSession.sharedInstance()
        
        do {
            try playbackSession.setCategory(.playback)
            try playbackSession.setActive(true)
            player = try AVAudioPlayer(data: record.recordData!)
            player.prepareToPlay()
            player.volume = 1.0
            print("do circle")
            } catch {
                print("Error of playback 1")
            }
            
        player.play()
        print("play")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        
        let record = records[indexPath.row]
        let df = DateFormatter()
        df.dateFormat = "dd.MM.YY - HH.mm.ss"
        
        cell.textLabel?.text = "Record \(df.string(from: record.recordDate!))"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            StorageManager.shared.deleteRecord(object: records[indexPath.row])
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}

