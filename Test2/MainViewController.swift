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
    
    var footerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 150, width: 100, height: 100))
        view.backgroundColor = .yellow
        //view.setGradientBackground(colorOne: .clear, colorTwo: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), location: [0.7,1.0])
        return view
    }()
    
//MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        //view.setGradientBackground(colorOne: .clear, colorTwo: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), location: [0.4, 1.0])
        setView()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func update(n: Int) {
        
        //tableView.reloadData()
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
        
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        
        self.title = "Record list"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //tableView.footerView(forSection: 0)
        tableView.tableFooterView = footerView
        tableView.separatorColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //tableView.separatorStyle = .none
    }

   func getDirectory() -> URL {
       let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      
       return paths[0]
   }

}

//MARK: TableView Delegate and DataSource
extension MainViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
      /*  let record = records[indexPath.row]
        playbackSession = AVAudioSession.sharedInstance()
       
        do {
            try playbackSession.setCategory(.playback)
            try playbackSession.setActive(true)
            player = try AVAudioPlayer(data: record.recordData!)
            player.prepareToPlay()
            player.volume = 5.0
            print("do circle")
            } catch {
                print("Error of playback")
            }
            
        player.play()
       */
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        cell.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
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

