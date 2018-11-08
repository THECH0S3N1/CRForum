//
//  BlockBase.swift
//  CRForum
//
//  Created by OSXXX on 04/10/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreData

//chars to choose the hash elements
var hashBase = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ0123456789"

//data to be used from the coredata
//segment describing the blocks of the blockchain, including the hash function for next blocks.
//for simplicity, only 16 character hashes will be used.

class Blocks{
    var hash = String()
    var prevHash = String()
    var index = Int()
    
    /*func sha256(data : NSData) -> String {
        let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(data.bytes, CC_LONG(data.length), UnsafeMutablePointer(res!.mutableBytes))
        return "\(res!)".stringByReplacingOccurrencesOfString("", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
        
    }*/
    
    
    
    
}

//blockchain class build-up of the blocks

class BlockChain{
    
    
    var baseReference: DatabaseReference!
    var blockChain = [Blocks]()
    var blockDataFile = ""
    let fileName = "blockDataFile.txt"
    var amount = 0.0
    var from = ""
    var to = ""
    var timestamp = ""
    
    
    //load data from the database and store it in a string to pass to the block data
    
    func fetchData()->String{
        var userData = String()
        do {
            let userBlockData = NSFetchRequest<NSFetchRequestResult>(entityName: "BlockchainData")
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let result = try context.fetch(userBlockData)
            for data in result as! [NSManagedObject] {
                userData.append((data.value(forKey: "amount") as! String))
                amount = (data.value(forKey: "amount") as! Double)
                userData.append((data.value(forKey: "/") as! String))
                userData.append((data.value(forKey: "fromwallet") as! String))
                from = (data.value(forKey: "fromwallet") as! String)
                userData.append((data.value(forKey: "/") as! String))
                userData.append((data.value(forKey: "towallet") as! String))
                to = (data.value(forKey: "towallet") as! String)
                userData.append((data.value(forKey: "/") as! String))
                userData.append((data.value(forKey: "timestamp") as! String))
                timestamp = (data.value(forKey: "timestamp") as! String)

            }
        } catch {}
        return userData
    }
    
    func createNewBlock(){
        let newBlock = Blocks()
        //newBlock.hash = newBlock.sha256(data: fetchData())
        //newBlock.prevHash = getLastHash()
        newBlock.index = blockChain.count
        
        saveBlockDataToDatabase(amount, to, from, timestamp, newBlock.prevHash ,newBlock.hash)
        
    }
    
    //saving currently made block to Firebase's realtime database
    
    func getLastHash(completion: @escaping (String) -> Void){
        var lastHash = ""
        self.baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let directRef = self.baseReference.child("hash")
        directRef.queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
            if let dictionary = snapshot.value as? [String: String]{
                lastHash = dictionary["hlastHash"]!
                completion(lastHash)
            }
        })
    }
    
    func getIndexx(completion: @escaping (Int) -> Void){
        var countt = 0
        self.baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        self.baseReference.child("blockchain").observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
            countt += Int((snapshot.childrenCount))
            completion(countt)
        })
    }

    

    func saveBlockDataToDatabase(_ amount: Double, _ destAddress: String, _ originAddress: String, _ timestamp: String, _ prevhash: String, _ hash: String ){
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let directRef = self.baseReference.child("blockchain").child(hash)
        let data = ["amount": amount, "toWallet": destAddress, "fromWallet": originAddress, "timestamp": timestamp, "prevhash": prevhash] as [String : Any]
        directRef.updateChildValues(data, withCompletionBlock: {(error, reference) in
            if error != nil{
                print(error ?? "")
                return
            }
            print("Saved Blockchain Data")
        })
        
        
        
    }
    
    
    
    
}
