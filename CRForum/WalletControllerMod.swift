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

class WalletControllerMod: UIViewController {
    
    @IBAction func logOutButton(_ sender: Any) {
        try! Auth.auth().signOut()
        self.performSegue(withIdentifier: "toScan", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}

