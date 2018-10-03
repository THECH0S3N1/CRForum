//
//  WalletController.swift
//  CRForum
//
//  Created by OSXXX on 13/07/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import UIKit
import LocalAuthentication
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
    
    @IBAction func sendCryptoButton(_ sender: Any) {
        self.performSegue(withIdentifier: "sendCrypto", sender: self)
        
    }
    
    
    @IBAction func logOutButton(_ sender: Any) {
        try! Auth.auth().signOut()
        self.performSegue(withIdentifier: "toScan", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate

        //let context = appDelegate.persistentContainer.viewContext
        //let entity = NSEntityDescription.entity(forEntityName: "Users", in: context)
        //let newUser = NSManagedObject(entity: entity!, insertInto: context)
        
        activity.isHidden = true
        //userContacts[1].totalBalance = totalBalance
        //currentBalanceLabel.text = String(format:"%.2f", totalBalance)
        //print(totalBalance)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

