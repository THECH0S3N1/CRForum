//
//  ForumController.swift
//  CRForum
//
//  Created by OSXXX on 13/07/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import UIKit
import Firebase

class ForumController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var loggedInLabel: UILabel!
    @IBOutlet weak var forumCounterLabel: UILabel!
    @IBOutlet weak var availableForumCounterLabel: UILabel!
    @IBOutlet weak var forumTableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loggedInString = "Logged in as: " + (Auth.auth().currentUser?.displayName)!
        loggedInLabel.text = loggedInString
        downloadProfileImage()
        
        
    }
    
    func imgRef(uid: String) -> StorageReference{
        return Storage.storage().reference().child("users").child("profile_img/\(uid)")
    }
    
    func downloadProfileImage(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        imgRef(uid: uid).getData(maxSize: 1024*1024*12){(data, error) in
            if let data = data{
                let image = UIImage(data: data)
                self.profileImageView.image = image
            }
            print(error ?? "No ERROR")
            
        }
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    
}

