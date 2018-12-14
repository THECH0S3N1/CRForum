//
//  BlockView.swift
//  CRForum
//
//  Created by PiotrZ on 10/12/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class  BlockView: UIViewController {
    
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    @IBOutlet weak var Label3: UILabel!
    @IBOutlet weak var Label4: UILabel!
    @IBOutlet weak var Label5: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Label1.text = too
        Label2.text = fromm
        Label3.text = String(amountt)
        Label4.text = prevhashh
        Label5.text = timestampp
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}
