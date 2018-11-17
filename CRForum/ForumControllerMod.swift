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
        let forumsAvailable = allForums.count
        forumCounterLabel.text = String(forumsAvailable)
        
    }
    var baseReference: DatabaseReference!
    var allForums = [forumPostTitles]()
    var currentAddress = ""
    var forumToSearch = ""
    let forumCost = 50.0
    var totalLocalBalance = 0.0
    var newValue = 0.0
    
    func transferFundsToMod(){
        //if SendingControllerMod().checkIfAmountIsValid(){
            var index = Int()
            var prevhash = String()
            let dateString = GenerationController().getTimeString()
            let hash = BlockChain().createNewBlock(addressTo, currentAddress, forumCost, dateString)
            let completion2 = { (count: Int) in
                index = count
            }
            BlockChain().getIndexx(completion: completion2)
            let completion3 = { (last: String) in
                prevhash = last
            }
            BlockChain().getLastHash(completion: completion3)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                BlockChain().saveBlockDataToDatabase(self.forumCost, addressTo, self.currentAddress, dateString, prevhash, hash, index)
            }
            removePrevValue()
            saveNewValues()
            WalletControllerMod().updateDatabaseValues((Auth.auth().currentUser?.displayName)!, newValue)
            AllUserUpdates().getUsername(forumCost)
       // }else{
        //   print("Error. Please enter valid amount")
            
        //}
    }
    
    func removePrevValue(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                totalLocalBalance = data.value(forKey: "totalbalance") as! Double
                context.delete(data)
            }
        } catch {
            print("Loading data from storage failed")
        }
        do { try context.save()
        } catch {
            print("Error saving to local database")
        }
    }
    
    func saveNewValues(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "UserData", in: context)!
        let user = NSManagedObject(entity: userEntity, insertInto: context)
        let transactionEntity = NSEntityDescription.entity(forEntityName: "TransactionData", in: context)!
        let transaction = NSManagedObject(entity: transactionEntity, insertInto: context)
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        newValue = totalLocalBalance-forumCost
        user.setValue(newValue, forKey: "totalbalance")
        transaction.setValue("Sent Currency", forKey: "transactiondescription")
        transaction.setValue(forumCost, forKey: "amount")
        transaction.setValue(NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval)), forKey: "timestamp")
        do {
            try context.save()
        } catch {
            print("Error saving to local database")
        }
    }
    
    func authenticate(){
        let context:LAContext = LAContext()
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil){
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Please login with your fingerprint to access CRForum", reply: {(wasCorrect, error) in
                if wasCorrect{
                    if self.currentAddress != addressTo{
                        self.transferFundsToMod()
                    }
                    self.performSegue(withIdentifier: "readModSeague", sender: self)
                }
            })
        }

    }
    
    
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
        let completion = { (id: String) in
            self.forumToSearch = id
        }
        ReadPostControllerMod().loadIDOfTitle(postTitle, completion: completion)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let completion2 = { (sentTo: String) in
                addressTo = sentTo
            }
            self.getTransferAddress(completion: completion2)
        
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.authenticate()
        }
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
    
    func getTransferAddress(completion: @escaping (String) -> Void){
        var wallet = ""
        self.baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let directRef = self.baseReference.child("forum").child(forumToSearch)
        directRef.queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
            if let dictionary = snapshot.value as? [String: String]{
                wallet = dictionary["wallet"]!
                completion(wallet)
                
            }
        })

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadProfileImage()
        let completion = { (address: String) in
            self.currentAddress = address
        }
        GenerationControllerMod().getCurrentUserWalletAddress(completion: completion)
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

