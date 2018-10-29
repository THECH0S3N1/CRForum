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

class WalletController: UIViewController {

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var transactionTable: UITableView!
    @IBOutlet weak var unconfirmedPurchaseslabel: UILabel!
    @IBOutlet weak var updateWalletButton: UIButton!
    @IBOutlet weak var sendCryptoButton: UIButton!
    
    
    @IBAction func updateWalletButton(_ sender: Any) {
        
        
        
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                currentBalanceLabel.text = data.value(forKey: "totalbalance") as? String
            }
        } catch {
            print("Loading data from storage failed")
        }
    
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

