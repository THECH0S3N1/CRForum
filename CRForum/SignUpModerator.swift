//
//  SignUpModerator.swift
//  CRForum
//
//  Created by OSXXX on 19/07/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//


import UIKit
import CoreData
import Firebase
import FirebaseDatabase
import LocalAuthentication

struct Moderator{
    let email: String
    let name: String
    let password: String
    let username: String
    let phone: String
    let profileImage: UIImage?
    let moderatorID: String
    var totalBalance: Double
    
    init(email: String, name: String, password: String, username: String, phone: String, profileImage: UIImage?, moderatorID: String, totalBalance: Double){
        self.email = email
        self.name = name
        self.password = password
        self.username = username
        self.phone = phone
        self.profileImage = profileImage
        self.moderatorID = moderatorID
        self.totalBalance = totalBalance
    }
}
var hashBase = "0123456789abcdefghijklmnopqrstuvwqyzABCDEFGHIJKLMNOPQRTSUVWXYZ"
var moderatorContacts: [Moderator] = []
var modflag = 0
class SignUpModerator: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var emailEntry: UITextField!
    @IBOutlet weak var nameEntry: UITextField!
    @IBOutlet weak var usernameEntry: UITextField!
    @IBOutlet weak var passwordEntry: UITextField!
    @IBOutlet weak var phonenumberEntry: UITextField!
    @IBOutlet weak var moderatorID: UITextField!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var errorText: UILabel!
    var baseReference: DatabaseReference!
    
    var moderatorIDString = ""
    var dataFile = ""
    let fileName = "dataFile2.txt"
    let modlistFile = "modList.txt"
    let docURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let welcomeCredit = 100
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func checkIfEmpty() -> Bool{
        if  (emailEntry.text?.isEmpty ?? true) || (nameEntry.text?.isEmpty ?? true) || (usernameEntry.text?.isEmpty ?? true) || (passwordEntry.text?.isEmpty ?? true) ||
            (phonenumberEntry.text?.isEmpty ?? true) || (moderatorID.text?.isEmpty ?? true){
            return false
        }
        return true
    }
    
    func saveModDataToFile(){
        dataFile.append(emailEntry.text! + " ")
        dataFile.append(nameEntry.text! + " ")
        dataFile.append(usernameEntry.text! + " ")
        dataFile.append(passwordEntry.text! + " ")
        dataFile.append(phonenumberEntry.text! + " ")
        dataFile.append(moderatorID.text!)
        let fileURL = docURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        do {
            try dataFile.write(to: fileURL, atomically: false, encoding: .utf8)
        }catch let error as NSError{
            self.errorText.text = ("error creating user: \(error.localizedDescription)")
            print (self.errorText.text!)
        }
        
    }
    
    func loadModList(){
        let fileURL = docURL.appendingPathComponent(modlistFile)
        
        modListRef.getData(maxSize: 1000000){ data, error in
            if let error = error {
                self.errorText.text = ("error creating user: \(error.localizedDescription)")
                print (self.errorText.text!)
            } else {
                try? data?.write(to: fileURL)
                print("success")
            }
        }
        do {
            moderatorIDString = try String(contentsOfFile: fileURL.path)
            print("true")
        } catch {
            self.errorText.text = ("error creating user: \(error.localizedDescription)")
            print (self.errorText.text!)
        }
    }
    
    func uploadDataFile(_ fileName:String, completion: @escaping ((_ url:URL?)->())){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let localFile = docURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        dataRef(uid: uid).putFile(from: localFile, metadata: nil) { metadata, error in}
    }
    
    func checkIfModIDcorrect () ->Bool{
        if (moderatorIDString.range(of: moderatorID.text!) != nil){
            return true
        }
        return false
    }
    
    @IBAction func Submit (_sender: AnyObject){
        guard let usrnm = usernameEntry.text else {return}
        guard let profile = profileView.image else {return}
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        if let email = emailEntry.text, let pass = passwordEntry.text {
            Auth.auth().createUser(withEmail: email, password: pass) { (user, error) in
                if error == nil && user != nil && self.checkIfEmpty() {
                    print("User created successfully")
                    let address = self.getWalletAddress()
                    let directRef = self.baseReference.child("moderators").child(usrnm)
                    let data = ["name": self.nameEntry.text!, "email": self.emailEntry.text!, "username": self.usernameEntry.text!, "phone": self.phonenumberEntry.text!, "balance": self.welcomeCredit, "wallet": address] as [String : Any]
                    let userEntity = NSEntityDescription.entity(forEntityName: "UserData", in: self.context)!
                    let user = NSManagedObject(entity: userEntity, insertInto: self.context)
                    let transactionEntity = NSEntityDescription.entity(forEntityName: "TransactionData", in: self.context)!
                    let transaction = NSManagedObject(entity: transactionEntity, insertInto: self.context)
                    let timestamp = NSDate().timeIntervalSince1970
                    let myTimeInterval = TimeInterval(timestamp)
                    modflag = 1
                    directRef.updateChildValues(data, withCompletionBlock: {(error, reference) in
                        if error != nil{
                            print(error ?? "")
                            return
                        }
                        print("saved")
                    })
                    
                    // core data block saving
                    
                    user.setValue(self.emailEntry.text, forKey: "email")
                    user.setValue(self.passwordEntry.text, forKey: "password")
                    user.setValue(self.welcomeCredit, forKey: "totalbalance")
                    user.setValue(self.usernameEntry.text, forKey: "username")
                    user.setValue(self.phonenumberEntry.text, forKey: "phonenumber")
                    user.setValue(self.nameEntry.text, forKey: "name")
                    user.setValue(address, forKey: "walletaddress")
                    transaction.setValue("Welcome Credit", forKey: "transactiondescription")
                    transaction.setValue(self.welcomeCredit, forKey: "amount")
                    transaction.setValue(NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval)), forKey: "timestamp")
                    
                    
                    do { try self.context.save()
                    } catch {
                        self.errorText.text = ("Error saving to local database")
                    }
                    
                    //struct block
                    
                    totalBalance = totalBalance + 100
                    userContacts.append(User(email: self.emailEntry.text!, name: self.nameEntry.text!, password: self.passwordEntry.text!, username: self.usernameEntry.text!, phone: self.phonenumberEntry.text!, profileImage: self.profileView.image!, totalBalance : Double(totalBalance)))
                    
                    
                   
                    self.uploadImage(profile){ url in }
                    let changeReq = Auth.auth().currentUser?.createProfileChangeRequest()
                    Auth.auth().currentUser?.sendEmailVerification { (error) in}
                    changeReq?.displayName = usrnm
                    changeReq?.commitChanges { error in }
                    self.performSegue(withIdentifier: "backToStartMod", sender: self)
                } else if error != nil{
                    self.errorText.text = ("error creating user: \(error!.localizedDescription)")
                    print (self.errorText.text!)
                }
            }
        }
    }
    
    
    func getWalletAddress()->String{
        var address = ""
        for _ in 0..<34{
            let r = Int(arc4random_uniform(UInt32(hashBase.count)))
            address += String(hashBase[hashBase.index(hashBase.startIndex, offsetBy: r)])
        }
        return address
    }
    
    
    @IBAction func loadImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Profile photo", style: .default, handler: {(action:UIAlertAction) in imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func uploadImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let imageData = UIImageJPEGRepresentation(profileView.image!, 0.75) else {return}
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        imgRef(uid: uid).putData(imageData, metadata: metaData) {metaData, error in
            if error == nil, metaData != nil {
                self.imgRef(uid: uid).downloadURL { (url, error) in
                    guard url != nil  else {return}
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let profileImg = info[UIImagePickerControllerOriginalImage] as! UIImage
        profileView.image = profileImg
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imgRef(uid: String) -> StorageReference{
        return Storage.storage().reference().child("moderators").child("profile_img/\(uid)")
    }
    
    func dataRef(uid: String) -> StorageReference{
        return Storage.storage().reference().child("moderators").child("profile_data/\(uid)")
    }
    
    var modListRef: StorageReference{
        return Storage.storage().reference().child("modsList.txt")
        
    }
    
    @objc func keyboardWillChange(notification: Notification){
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        if notification.name == Notification.Name.UIKeyboardWillShow || notification.name == Notification.Name.UIKeyboardWillChangeFrame{
            view.frame.origin.y = -keyboardRect.height
        }else{
            view.frame.origin.y = 0
        }
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loadModList()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}


