//
//  PostCreationController.swift
//  CRForum
//
//  Created by PiotrZ on 06/11/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase

class PostCreationController: UIViewController{
    
    var baseReference: DatabaseReference!
    var modAddress = ""
    @IBOutlet weak var forumTitleEntry: UITextField!
    @IBOutlet weak var textCreator: UITextView!
    
    func createForumID()->String{
        var forumID = ""
        for _ in 0..<8{
            let r = Int(arc4random_uniform(UInt32(hashBase.count)))
            forumID += String(hashBase[hashBase.index(hashBase.startIndex, offsetBy: r)])
        }
        return forumID
    }
    
    
    @IBAction func createPost(_ sender: Any) {
        uploadForumPost(createForumID())
        performSegue(withIdentifier: "createPost", sender: self)
        
    }
    
    func uploadForumPost(_ forumID: String){
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let data = ["text": textCreator.text, "title": forumTitleEntry.text!, "wallet": modAddress] as [String : Any]
        let forumRef = self.baseReference.child("forum").child(forumID)
        forumRef.updateChildValues(data, withCompletionBlock: {(error, reference) in
            if error != nil{
                print(error ?? "")
                return
            }
            print("saved")
        })
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let completion = { (address: String) in
            self.modAddress = address
        }
        GenerationControllerMod().getCurrentUserWalletAddress(completion: completion)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
}
