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



class MainViewController: UITableViewController {
    
//MARK: Variables
    var records: Results<Audio>!
    var player: AVAudioPlayer!
    var playbackSession: AVAudioSession!
    var selectedCellIndexPath: IndexPath?
    var selectedCellHeight: CGFloat = 200
    var unselectedCellHeight: CGFloat = 75
   
    
    var footerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 2))
        view.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        return view
    }()
    
//MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        
        setView()
    }

//MARK: ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        tableView.reloadData()
    }
    
 
//MARK: Setup View
    func setView() {

        records = StorageManager.shared.fetchRecords()
       
        let newRecordButton: UIBarButtonItem = {
            let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewRecord))
            return button
        }()
        
        navigationItem.rightBarButtonItem = newRecordButton
        
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
                
        self.title = "Record list"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        tableView.register(RecordCell.self, forCellReuseIdentifier: "recordCell")
        tableView.tableFooterView = footerView
        tableView.separatorStyle = .none
    }
    
    //Open record viewcontroller
    @objc func addNewRecord() {
        let vc = RecordViewController()
        show(vc, sender: self)
    }
    
}

//MARK: TableView and DataSource Delegate
extension MainViewController {
    
    //didSelectRow
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedCellIndexPath != nil && selectedCellIndexPath == indexPath {
            selectedCellIndexPath = nil
            PlaybackManager.shared.stop()
            
        } else {
            selectedCellIndexPath = indexPath
            PlaybackManager.shared.prepareToPlayback(numberOfRecord: indexPath.row)
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()

        if selectedCellIndexPath != nil {
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
      
    }
    
    //numberOfRowsInSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    //heightForRow
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedCellIndexPath == indexPath {
            return selectedCellHeight
        }
        return unselectedCellHeight
    }
    
    //cellForRow
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! RecordCell
        cell.selectionStyle = .none
        cell.clipsToBounds = true
        
        
        let record = records[indexPath.row]
        let df = DateFormatter()
        df.dateFormat = "dd/MM/YY"
        var timeOfRecord = TimeCounter()
        timeOfRecord.deciSeconds = Int(record.recordDuration)
        
        
        cell.nameRecordLabel.text = "Record \(indexPath.row + 1)"
        cell.dateRecordLabel.text = "\(df.string(from: record.recordDate!))"
        cell.durationRecordLabel.text = timeOfRecord.descriptionSecond
        cell.endTimeOfPlaybarLabel.text = timeOfRecord.descriptionThird
        
        
        return cell
    }
    
    //canEditRow
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

