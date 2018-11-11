//
//  ForumController.swift
//  CRForum
//
//  Created by OSXXX on 13/07/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import UIKit
import Firebase

class ForumController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var loggedInLabel: UILabel!
    @IBOutlet weak var availableForumCounterLabel: UILabel!
    @IBOutlet weak var forumTableView: UITableView!
    @IBAction func reloadB(_ sender: Any) {
        
        forumTableView.reloadData()
        
    }
    var baseReference: DatabaseReference!
    var allForums = [forumPostTitles]()
    
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return allForums.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = allForums[indexPath.row]
        cell.textLabel?.text = post.title
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = allForums[indexPath.row]
        postTitle = title.title!
        performSegue(withIdentifier: "readSeague", sender: self)
        
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
        loggedInLabel.text = loggedInString
        availableForumCounterLabel.text = String(forumsAvailable)
        downloadPosts()
        forumTableView.reloadData()
        forumTableView.dataSource = self
        forumTableView.delegate = self
        forumTableView.register(UITableViewCell.self, forCellReuseIdentifier: "postCell")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

