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

class SendingControllerMod: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var baseReference: DatabaseReference!
    var allUsers = [UserWallets]()
    var amountCurrent = 0.0
    var totalLocalBalance = 0.0
    var newValue = 0.0
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var amountToSendField: UITextField!
    @IBOutlet weak var userTable: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var errorField: UILabel!
    @IBAction func sendButton(_ sender: Any) {
        if checkIfEmpty() && checkIfAmountIsValid(){
            var addressFrom = ""
            var index = Int()
            var prevhash = String()
            let dateString = GenerationController().getTimeString()
            let completion = { (wallet: String) in
                addressFrom = wallet
            }
            GenerationControllerMod().getCurrentUserWalletAddress(completion: completion)
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
                BlockChain().saveBlockDataToDatabase(amount, addressTo, addressFrom, dateString, prevhash, hash, index)
            }
            removePrevValue()
            saveNewValues()
            WalletControllerMod().updateDatabaseValues((Auth.auth().currentUser?.displayName)!, newValue)
            AllUserUpdates().getUsername(((self.amountToSendField.text! as NSString).doubleValue))
            performSegue(withIdentifier: "sentSuccessfulMod", sender: self)
        }else{
            errorField.text = "Error. Please enter valid amount"
            
        }
        
    }
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func checkIfEmpty()->Bool{
        if  (amountToSendField.text?.isEmpty ?? true) {
            return false
        }
        return true
    }
    
    func downloadAllUserList(){
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let userRef = self.baseReference.child("users")
        let modRef = self.baseReference.child("moderators")
        userRef.observe(.childAdded, with: {(snapshot: DataSnapshot) in
            print(snapshot)
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let oUser = UserWallets()
                oUser.wallet = dictionary["wallet"] as? String
                self.allUsers.append(oUser)
                print(oUser.wallet!)
            }
        })
        
        modRef.observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let mod = UserWallets()
                mod.wallet = dictionary["wallet"] as? String
                self.allUsers.append(mod)
                
            }
        })
        
        
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print(allUsers.count)
        return allUsers.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "usersCellMod")
        let callOne = allUsers[indexPath.row]
        cell.textLabel?.text = callOne.wallet
        return cell
    }
    
    @IBAction func reload(_ sender: Any) {
        userTable.reloadData()
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let theAddress = allUsers[indexPath.row]
        addressTo = theAddress.wallet!
        
    }

    func removePrevValue(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                totalLocalBalance = data.value(forKey: "totalbalance") as! Double
                context.delete(data)
            }
        } catch {
            print("Loading data from storage failed")
        }
        do { try context.save()
        } catch {
            print("Error saving to local database")
        }
    }
    
    func saveNewValues(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "UserData", in: context)!
        let user = NSManagedObject(entity: userEntity, insertInto: context)
        let transactionEntity = NSEntityDescription.entity(forEntityName: "TransactionData", in: context)!
        let transaction = NSManagedObject(entity: transactionEntity, insertInto: context)
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        newValue = totalLocalBalance-((amountToSendField.text! as NSString).doubleValue)
        user.setValue(newValue, forKey: "totalbalance")
        transaction.setValue("Sent Currency", forKey: "transactiondescription")
        transaction.setValue(((amountToSendField.text! as NSString).doubleValue), forKey: "amount")
        transaction.setValue(NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval)), forKey: "timestamp")
        do {
            try context.save()
        } catch {
            print("Error saving to local database")
        }
    }
    
    func getLastBalance(completion: @escaping (Double) -> Void){
        var availableBalance = 0.0
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let userRef = self.baseReference.child("moderators").child((Auth.auth().currentUser?.displayName)!)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                availableBalance = dictionary["balance"] as! Double
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.balanceLabel.text = String(format:"%.1f", self.amountCurrent)
                }
                completion(availableBalance)
            }
        })
    }
    
    func checkIfAmountIsValid()->Bool{
        if (amountCurrent >= (amountToSendField.text! as NSString).doubleValue){
            return true
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadAllUserList()
        userTable.reloadData()
        userTable.dataSource = self
        userTable.delegate = self
        userTable.register(UITableViewCell.self, forCellReuseIdentifier: "usersCellMod")
        let completion = { (availableBalance: Double) in
            self.amountCurrent = availableBalance
        }
        getLastBalance(completion: completion)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
}
