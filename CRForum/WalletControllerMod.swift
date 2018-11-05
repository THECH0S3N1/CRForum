//
//  WalletControllerMod.swift
//  CRForum
//
//  Created by OSXXX on 13/07/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import UIKit
import LocalAuthentication
import Firebase
import CoreData


class WalletControllerMod: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var transactionsArray = [String]()
    var baseReference: DatabaseReference!
    var stringToAdd = ""
    var index = 0
    
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var transactionTable: UITableView!
    @IBOutlet weak var unconfirmedPurchaseslabel: UILabel!
    @IBOutlet weak var updateWalletButton: UIButton!
    @IBOutlet weak var sendCryptoButton: UIButton!
    
    
    @IBAction func updateWalletButton(_ sender: Any) {
        transactionsArray.removeAll()
        self.viewDidLoad()
        self.viewWillAppear(true)
       
    }
    
    
    
    @IBAction func sendCryptoButton(_ sender: Any) {
        self.performSegue(withIdentifier: "sendCrypto", sender: self)
        
    }
    
    
    @IBAction func logOutButton(_ sender: Any) {
        try! Auth.auth().signOut()
        self.performSegue(withIdentifier: "toScan", sender: self)
        
    }
    
    func updateDatabaseValues(_ address: String,_ balance: Double){
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let directRef = baseReference.child("moderators").child(address)
        directRef.updateChildValues(["balance": balance], withCompletionBlock: {(error, reference) in
            if error != nil{
                print(error ?? "")
                return
            }
            print("saved")
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        activity.isHidden = true
        readItems()
        transactionTable.reloadData()
        transactionTable.dataSource = self
        transactionTable.delegate = self
        transactionTable.register(UITableViewCell.self, forCellReuseIdentifier: "historycell")
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "totalbalance") as! Double)
                currentBalanceLabel.text = String(data.value(forKey: "totalbalance") as! Double)
                updateDatabaseValues((Auth.auth().currentUser?.displayName)!, (data.value(forKey: "totalbalance") as! Double))
            }
        } catch {
            print("Loading data from storage failed")
        }
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(true)
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("current row count ",transactionsArray.count)
        return transactionsArray.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "historycell", for: indexPath)
        cell.textLabel?.text = transactionsArray[indexPath.row]
        transactionTable.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.scrollToBottom()
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func readItems(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TransactionData")
        do{
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let date = data.value(forKey: "timestamp") as! Date
                let stringDate = date.asString(style: .short)
                stringToAdd.append(String(data.value(forKey: "amount") as! Double) + "   ")
                stringToAdd.append(String(data.value(forKey: "transactiondescription") as! String) + "   ")
                stringToAdd.append(stringDate)
                transactionsArray.append(stringToAdd)
                stringToAdd = ""
                
            }
        }
        catch{
            print("Error")
        }
        
    }
    
    
    
}





