//
//  GeneratiorControllerMod.swift
//  CRForum
//
//  Created by OSXXX on 13/07/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class GenerationControllerMod: UIViewController {
    var baseReference: DatabaseReference!
    var address = ""
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    var totalLocalBalance = 0.0
    @IBOutlet weak var tabBar: UITabBarItem!
    @IBOutlet var generateView: UIView!
    @IBOutlet weak var generateButton: UIButton!
    
    //because of the coredata strucutre specificity, previous data elements will be removed, before saving the new ones - concerns only the balance values
    
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
    
    //function to save the new values to the core data "TransactionData" and "BlockchainData" storage
    
    func saveNewValues(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "UserData", in: context)!
        let user = NSManagedObject(entity: userEntity, insertInto: context)
        let transactionEntity = NSEntityDescription.entity(forEntityName: "TransactionData", in: context)!
        let transaction = NSManagedObject(entity: transactionEntity, insertInto: context)
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let completion = { (wallet: String) in
            self.address = wallet
        }
        getCurrentUserWalletAddress(completion: completion)
        user.setValue(totalLocalBalance+1, forKey: "totalbalance")
        transaction.setValue("Generated Currency", forKey: "transactiondescription")
        transaction.setValue(1.00, forKey: "amount")
        transaction.setValue(NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval)), forKey: "timestamp")
        do {
            try context.save()
            generateView.isUserInteractionEnabled = true
        } catch {
            print("Error saving to local database")
        }
        
    }
    
    //function to retrieve current user's wallet address from the database
    
    func getCurrentUserWalletAddress(completion: @escaping (String)->Void){
        var wallet = ""
        self.baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let directRef = self.baseReference.child("moderators").child((Auth.auth().currentUser?.displayName)!)
        directRef.queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
            if let dictionary = snapshot.value as? [String: String]{
                wallet = dictionary["wallet"]!
                completion(wallet)
                
            }
        })
        
    }
    
    //generation button will be using several functions, the most important of which, is calling the function to create newBlock to the blockchain, as well as update Coredata storage values
    //creating new block will require some time, for retrieving data from the firebase, whenever the generation button is pressed (due to new transaction)
    
    @IBAction func generateButton(_ sender: Any){
        let time = Date()
        var index = Int()
        var prevhash = String()
        let format = DateFormatter()
        format.timeZone = TimeZone.current
        format.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = format.string(from: time)
        generateView.isUserInteractionEnabled = false
        generateButton.isHidden = true
        animateProgress()
        removePrevValue()
        saveNewValues()
        let hash = BlockChain().createNewBlock(address, address, 1.0, dateString)
        let completion = { (count: Int) in
            index = count
        }
        BlockChain().getIndexx(completion: completion)
        let completion2 = { (last: String) in
            prevhash = last
        }
        BlockChain().getLastHash(completion: completion2)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            BlockChain().saveBlockDataToDatabase(1.0, self.address, self.address, dateString, prevhash, hash, index)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //animation of the "loading" hoop, including basic parameters
    
    func animateProgress(){
        
        progressBar()
        let animate = CABasicAnimation(keyPath: "strokeEnd")
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.shapeLayer.removeFromSuperlayer()
            self.trackLayer.removeFromSuperlayer()
            self.generateButton.isHidden = false
        })
        animate.toValue = 1
        animate.duration = 5
        animate.fillMode = kCAFillModeForwards
        animate.isRemovedOnCompletion = false
        shapeLayer.add(animate, forKey: "bas")
        CATransaction.commit()
        
    }
    
    //description of some of the further "loading" hoop parameters
    
    func progressBar(){
        let center = view.center
        let colorScheme = UIColor(red: 89/255, green: 34/255, blue: 185/255, alpha: 1)
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: (-CGFloat.pi/2), endAngle: (3*CGFloat.pi/2), clockwise: true)
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.white.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = kCALineCapRound
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = colorScheme.cgColor
        shapeLayer.lineWidth = 11
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(trackLayer)
        view.layer.addSublayer(shapeLayer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
}

