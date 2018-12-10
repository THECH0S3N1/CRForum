//
//  BlockchainControllerMod.swift
//  CRForum
//
//  Created by OSXXX on 11/09/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import UIKit
import Firebase
import CoreData

var amountt = 0
var fromm = ""
var too = ""
var prevhashh = ""
var timestampp = ""
var hashS = ""

class  BlockchainControllerMod:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var baseReference: DatabaseReference!
    var BlockchainArray = [blockHashes]()

    @IBOutlet weak var blockchainTable: UITableView!
    
    
    @IBAction func updateTable(_ sender: Any) {
        blockchainTable.reloadData()
        
        
    }
    
    
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return BlockchainArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath)
        let post = BlockchainArray[indexPath.row]
        cell.textLabel?.text = post.hashh
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hashh = BlockchainArray[indexPath.row]
        hashS = hashh.hashh!
        downloadBlockData(hashS)
        print(hashS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.performSegue(withIdentifier: "toBlockMod" , sender: self)
        }
        
    }
    
    
    func downloadBlockData(_ hashString: String){
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let userRef = self.baseReference.child("blockchain").child(hashString)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if let dictionary = snapshot.value as? [String: AnyObject]{
                fromm = dictionary["fromWallet"] as! String
                
                too =  dictionary["toWallet"] as! String
                prevhashh = dictionary["prevhash"] as! String
                timestampp = dictionary["timestamp"] as! String
                amountt = dictionary["amount"] as! Int
                
            }
        })
        
    }
    
    func downloadPosts(){
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let userRef = self.baseReference.child("blockchain")
        userRef.observe(.childAdded, with: {(snapshot: DataSnapshot) in
            let entry = blockHashes()
            entry.hashh = snapshot.key
            self.BlockchainArray.append(entry)
            
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadPosts()
        blockchainTable.reloadData()
        blockchainTable.dataSource = self
        blockchainTable.delegate = self
        blockchainTable.register(UITableViewCell.self, forCellReuseIdentifier: "blockCell")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    
    
}

