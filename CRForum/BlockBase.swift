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
    var userData = String()
    func generateNewHash()->String{
        var hash = ""
        for _ in 0..<16{
            let r = Int(arc4random_uniform(UInt32(hashBase.count)))
            hash += String(hashBase[hashBase.index(hashBase.startIndex, offsetBy: r)])
        }
        return hash
    }
}

//blockchain class build-up of the blocks

class BlockChain{
    
    var blockChain = [Blocks]()
    var blockDataFile = ""
    let fileName = "blockDataFile.txt"
    
    
    
    //load data from the database and store it in a string to pass to the block data
    
    func fetchData()->String{
        var userData = String()
        do {
            let userBlockData = NSFetchRequest<NSFetchRequestResult>(entityName: "BlockchainData")
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let result = try context.fetch(userBlockData)
            for data in result as! [NSManagedObject] {
                userData.append((data.value(forKey: "amount") as! String))
                userData.append((data.value(forKey: "/") as! String))
                userData.append((data.value(forKey: "fromwallet") as! String))
                userData.append((data.value(forKey: "/") as! String))
                userData.append((data.value(forKey: "towallet") as! String))
                userData.append((data.value(forKey: "/") as! String))
                userData.append((data.value(forKey: "hashh") as! String))
                userData.append((data.value(forKey: "/") as! String))
                userData.append((data.value(forKey: "prevhash") as! String))
                userData.append((data.value(forKey: "/") as! String))
                userData.append((data.value(forKey: "timestamp") as! String))
                userData.append((data.value(forKey: "/") as! String))
            }
        } catch {}
        return userData
    }
    
    
    //this function will only be performed by the first user, the rest will be added after the merkleroot
    func createMerkleRoot(){
        let merkleRoot = Blocks()
        merkleRoot.hash = merkleRoot.generateNewHash()
        merkleRoot.userData = fetchData()
        merkleRoot.prevHash = "nil"
        merkleRoot.index = 0
        blockChain.append(merkleRoot)
    }
    
    func createNewBlock(){
        let newBlock = Blocks()
        newBlock.hash = newBlock.generateNewHash()
        newBlock.userData = fetchData()
        newBlock.prevHash = blockChain[blockChain.count-1].hash
        newBlock.index = blockChain.count
        blockChain.append(newBlock)
    }
    
    //saving currently made block to Firebase's text file blockDataFile
    
    func saveBlockDataToFile(){
        
        
        
        
        
    }
    
    
    
    
}
