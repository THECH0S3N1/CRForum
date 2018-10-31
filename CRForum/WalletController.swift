//
//  WalletController.swift
//  CRForum
//
//  Created by OSXXX on 13/07/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import UIKit
import LocalAuthentication
import CoreData
import Firebase

class WalletController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    var transactionsArray = [String]()
    
    var stringToAdd = ""
    var index = 0
    
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var transactionTable: UITableView!
    @IBOutlet weak var unconfirmedPurchaseslabel: UILabel!
    @IBOutlet weak var updateWalletButton: UIButton!
    @IBOutlet weak var sendCryptoButton: UIButton!
    
    
    @IBAction func updateWalletButton(_ sender: Any) {
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
            }
        } catch {
            print("Loading data from storage failed")
        }
    }
    
    
    
    @IBAction func sendCryptoButton(_ sender: Any) {
        self.performSegue(withIdentifier: "sendCrypto", sender: self)
        
    }
    
    
    @IBAction func logOutButton(_ sender: Any) {
        try! Auth.auth().signOut()
        self.performSegue(withIdentifier: "toScan", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            }
        } catch {
            print("Loading data from storage failed")
        }
    
        
    }
    
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("current row count ",transactionsArray.count)
        return transactionsArray.count
    }
    
  
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "historycell", for: indexPath)
        cell.textLabel?.text = transactionsArray[indexPath.row]
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


extension Date {
    func asString(style: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }
}


