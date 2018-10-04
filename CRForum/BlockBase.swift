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

var hashBase = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ0123456789"

//data to be used from the blockchainData.xcdatamodeld



class Blocks{
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var hash = String()
    var prevHash = String()
    var index = Int()
    //let data = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
    
    /*func fetchData()-> NSManagedObject {
        let data = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        data.fetchLimit = 1
        let user = try! context.fetch(data)
        return user
     
        
    }*/
    




    func generateNewHash()->String{
        var hash = ""
        for _ in 0..<16{
            let r = Int(arc4random_uniform(UInt32(hashBase.count)))
            hash += String(hashBase[hashBase.index(hashBase.startIndex, offsetBy: r)])
        }
        return hash
    }
    
    

}

class BlockChain{
    
    var blockChain = [Blocks]()
    
    
    func createMerkleRoot(data:String){
        let merkleRoot = Blocks()
        merkleRoot.hash = merkleRoot.generateNewHash()
        
        
        
    }
    
    
    
}
