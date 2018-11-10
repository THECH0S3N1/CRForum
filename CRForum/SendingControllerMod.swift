//
//  SendingControllerMod.swift
//  CRForum
//
//  Created by PiotrZ on 06/11/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase


class SendingControllerMod: UIViewController{
    var baseReference: DatabaseReference!
    var allUsers = [UserWallets]()
    var addressTo = ""
    var amount = 0.0
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var amountToSendField: UITextField!
    @IBOutlet weak var userTable: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBAction func sendButton(_ sender: Any) {
        var addressFrom = ""
        var index = Int()
        var prevhash = String()
        let dateString = GenerationController().getTimeString()
        let completion = { (wallet: String) in
            addressFrom = wallet
        }
        GenerationController().getCurrentUserWalletAddress(completion: completion)
        let amount = (amountToSendField.text! as NSString).doubleValue
        let hash = BlockChain().createNewBlock(addressTo, addressFrom, amount, dateString)
        let completion2 = { (count: Int) in
            index = count
        }
        BlockChain().getIndexx(completion: completion2)
        let completion3 = { (last: String) in
            prevhash = last
        }
        BlockChain().getLastHash(completion: completion3)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            BlockChain().saveBlockDataToDatabase(amount, self.addressTo, addressFrom, dateString, prevhash, hash, index)
        }
        
    }
    
    func downloadAllUserList(){
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let userRef = self.baseReference.child("users")
        let modRef = self.baseReference.child("moderators")
        userRef.observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: String]{
                let oUser = UserWallets()
                oUser.setValuesForKeys(dictionary)
                self.allUsers.append(oUser)
                
            }
        })
        
        modRef.observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: String]{
                let mod = UserWallets()
                mod.setValuesForKeys(dictionary)
                self.allUsers.append(mod)
                
            }
        })
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return allUsers.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: NSIndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: .default, reuseIdentifier: "usercell")
        let callOne = allUsers[indexPath.row]
        cell.textLabel?.text = callOne.wallet
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let theAddress = allUsers[indexPath.row]
        addressTo = theAddress.wallet!
        
    }
    
    
    func getLastBalance(completion: @escaping (Double) -> Void){
        var availableBalance = 0.0
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let userRef = self.baseReference.child("moderators").child((Auth.auth().currentUser?.displayName)!)
        userRef.queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
            if let dictionary = snapshot.value as? [String: Double]{
                availableBalance = dictionary["balance"]!
                completion(availableBalance)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadAllUserList()
        userTable.reloadData()
        let completion = { (availableBalance: Double) in
            self.amount = availableBalance
        }
        getLastBalance(completion: completion)
        balanceLabel.text = String(format:"%.1f", amount)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
}
