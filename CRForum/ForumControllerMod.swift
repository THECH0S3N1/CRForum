//
//  ForumControllerMod.swift
//  CRForum
//
//  Created by OSXXX on 11/09/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import UIKit
import LocalAuthentication
import CoreData
import Firebase

var postText = ""
var postTitle = ""

class ForumControllerMod: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var loggedInAsLabel: UILabel!
    @IBOutlet weak var forumCounterLabel: UILabel!
    @IBOutlet weak var forumTable: UITableView!
    @IBAction func reloadB(_ sender: Any) {
        
        forumTable.reloadData()
        
    }
    var baseReference: DatabaseReference!
    var allForums = [forumPostTitles]()
    
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return allForums.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "forumCell", for: indexPath)
        let post = allForums[indexPath.row]
        cell.textLabel?.text = post.title
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = allForums[indexPath.row]
        postTitle = title.title!
        performSegue(withIdentifier: "readModSeague", sender: self)
     
    }
    
    func imgRef(uid: String) -> StorageReference{
        return Storage.storage().reference().child("moderators").child("profile_img/\(uid)")
    }
    
    func downloadProfileImage(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        imgRef(uid: uid).getData(maxSize: 1024*1024*12){(data, error) in
            if let data = data{
                let image = UIImage(data: data)
                self.profileImage.image = image
            }
            print(error ?? "No ERROR")
            
        }
    }
    
    
    func downloadPosts(){
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let userRef = self.baseReference.child("forum")
        userRef.observe(.childAdded, with: {(snapshot: DataSnapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let post = forumPostTitles()
                post.title = dictionary["title"] as? String
                self.allForums.append(post)
            }
        })
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadProfileImage()
        let loggedInString = "Logged in as: " + (Auth.auth().currentUser?.displayName)!
        let forumsAvailable = allForums.count
        loggedInAsLabel.text = loggedInString
        forumCounterLabel.text = String(forumsAvailable)
        downloadPosts()
        forumTable.reloadData()
        forumTable.dataSource = self
        forumTable.delegate = self
        forumTable.register(UITableViewCell.self, forCellReuseIdentifier: "forumCell")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}

