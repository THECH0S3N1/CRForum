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


//some data is to be used from the coredata
//segment describing the blocks of the blockchain, including the hash function for next blocks.

class Blocks{
    var hash = String()
    var prevHash = String()
    var index = Int()
    
    //encryption algorithm SHA256 - encrypting data element to a data hash element
    //the following code snippet eliminates bad characters (special, non-alpha-numeric chars)
    //creating an exactly 64-long chars hash value
    
    func sha256(_ toEncrypt: String) -> String {
        let data = toEncrypt.data(using: String.Encoding.utf8)
        let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(((data! as NSData)).bytes, CC_LONG(data!.count), res?.mutableBytes.assumingMemoryBound(to: UInt8.self))
        let hashedString = "\(res!)".replacingOccurrences(of: "", with: "").replacingOccurrences(of: " ", with: "")
        let badchar: CharacterSet = CharacterSet(charactersIn: "\"<\",\">\"")
        let cleanedstring: String = (hashedString.components(separatedBy: badchar) as NSArray).componentsJoined(by: "")
        return cleanedstring
        
    }
}

//blockchain class build-up of the blocks
//this part does not represent the true blockchain, but rather functions for it be created in the database
//creating a block-based data, hashing the value of the generated transaction, indexing and extracting the previous hash value in the database.

class BlockChain{
    
    
    var baseReference: DatabaseReference!
    var blockChain = [Blocks]()
    //var blockDataFile = ""
    //let fileName = "blockDataFile.txt"
    var timestamp = ""
    
    //one of the most important functions of this class
    //create new block within the blockchain, by retrieving the last hash, index and storing new block on the blockchain
    
    func createNewBlock(_ to: String, _ from: String, _ amount: Double, _ timestamp: String) -> String{
        var userData = String()
        userData.append(to)
        userData.append(from)
        userData.append(String(format:"%.1f", amount))
        userData.append(timestamp)
        let newBlock = Blocks()
        newBlock.hash = newBlock.sha256(userData)
        let completion = { (count: Int) in
            newBlock.index = count
        }
        getIndexx(completion: completion)
        let completion2 = { (last: String) in
            newBlock.prevHash = last
        }
        getLastHash(completion: completion2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.saveNewLastHash(newBlock.hash)}
        return newBlock.hash
        
    }
    
    //update the "last" hash value in the database, for future blocks
    
    func saveNewLastHash(_ hash: String){
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let directRef = self.baseReference.child("hash")
        directRef.updateChildValues(["hlastHash": hash], withCompletionBlock: {(error, reference) in
            if error != nil{
                print(error ?? "")
                return
            }
            print("Saved successfuly to database")
        })
        
    }
    
    //get the last block's hash from the blockchain, using completionHandler
    
    func getLastHash(completion: @escaping (String) -> Void){
        var lastHash = ""
        self.baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let directRef = self.baseReference.child("hash")
        directRef.queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
            if let dictionary = snapshot.value as? [String: String]{
                lastHash = dictionary["hlastHash"]!
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    print(lastHash)
                    completion(lastHash)
                }
            }
        })
    }
    
    //get number of blocks in the blockchain, returning a result on completion, using completionHandler
    
    func getIndexx(completion: @escaping (Int) -> Void){
        var countt = 0
        self.baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        self.baseReference.child("blockchain").observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
            countt += Int((snapshot.childrenCount))
            completion(countt)
            
        })
    }

    //save newblock data to the blockchain

    func saveBlockDataToDatabase(_ amount: Double, _ destAddress: String, _ originAddress: String, _ timestamp: String, _ prevhash: String, _ hash: String, _ indexx: Int ){
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let directRef = self.baseReference.child("blockchain").child(hash)
        let data = ["amount": amount, "toWallet": destAddress, "fromWallet": originAddress, "timestamp": timestamp, "prevhash": prevhash, "index": indexx] as [String : Any]
        directRef.updateChildValues(data, withCompletionBlock: {(error, reference) in
            if error != nil{
                print(error ?? "")
                return
            }
            print("Saved Blockchain Data")
        })
        

    }
    
}



//outdated code element
//load data from the database and store it in a string to pass to the block data
//outdated code element

/*func fetchData()->String{
 var userData = String()
 do {
 let userBlockData = NSFetchRequest<NSFetchRequestResult>(entityName: "BlockchainData")
 let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
 let result = try context.fetch(userBlockData)
 for data in result as! [NSManagedObject] {
 let amountToString = String(format:"%.1f", (data.value(forKey: "amount") as! Double))
 userData.append(amountToString)
 amount = (data.value(forKey: "amount") as! Double)
 print("amount:", amount)
 userData.append((data.value(forKey: "fromwallet") as! String))
 from = (data.value(forKey: "fromwallet") as! String)
 print("from", from)
 userData.append((data.value(forKey: "towallet") as! String))
 to = (data.value(forKey: "towallet") as! String)
 print("to", to)
 //userData.append((data.value(forKey: "timestamp") as! String))
 timestamp = ""
 
 }
 } catch {}
 return userData
 }*/



