//
//  ReadPostController.swift
//  CRForum
//
//  Created by PiotrZ on 06/11/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase

class ReadPostController: UIViewController{
    
    @IBOutlet weak var forumTitle: UINavigationItem!
    @IBOutlet weak var textView: UITextView!
    var baseReference: DatabaseReference!
    var forumToSearch = ""
    
    func loadIDOfTitle(_ title: String, completion: @escaping (String) -> Void){
        var uid = ""
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/").child("forum")
        baseReference.queryOrdered(byChild: "title").queryEqual(toValue: postTitle).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            uid = snapshot.key
            completion(uid)
        })
    }
    
    func loadText(){
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/").child("forum").child(forumToSearch)
        baseReference.observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: String]{
                self.textView.text = dictionary["text"]
            }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        forumTitle.title = postTitle
        let completion = { (id: String) in
            self.forumToSearch = id
        }
        
        loadIDOfTitle(postTitle, completion: completion)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.loadText()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
}
