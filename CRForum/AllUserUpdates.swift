//
//  AllUserUpdates.swift
//  CRForum
//
//  Created by PiotrZ on 11/11/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase


class AllUserUpdates{
    var type = 0
    var baseReference: DatabaseReference!
    func getUIDUser(completion: @escaping (String) -> Void){
        var uid = ""
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/").child("users")
        baseReference.queryOrdered(byChild: "wallet").queryEqual(toValue: addressTo).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            uid = snapshot.key
            completion(uid)
        })
    }
    
    func getUIDModerator(completion: @escaping (String) -> Void){
        var uid = ""
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/").child("moderators")
        baseReference.queryOrdered(byChild: "wallet").queryEqual(toValue: addressTo).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            uid = snapshot.key
            completion(uid)
        })
    }
    
    
    func getUserBalanceToUpdate(_ id: String, completion: @escaping (Double)->Void){
        var availableBalancee = 0.0
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let userRef = self.baseReference.child("users").child(id)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                availableBalancee = dictionary["balance"] as! Double
                completion(availableBalancee)
            }
        })
    }
    
    func getModeratorBalanceToUpdate(_ id: String, completion: @escaping (Double)->Void){
        var availableBalancee = 0.0
        baseReference = Database.database().reference(fromURL: "https://crforum-f63c5.firebaseio.com/")
        let userRef = self.baseReference.child("moderators").child(id)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                availableBalancee = dictionary["balance"] as! Double
                completion(availableBalancee)
            }
        })
    }
    
    
    
    
    func getUsername(_ val: Double){
        let completion5 = { (uid: String) in
            sentToUsername = uid
        }
        self.getUIDModerator(completion: completion5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if sentToUsername == ""{
                self.type = 0
                let completion5 = { (uid: String)in
                    sentToUsername = uid
                }
                self.getUIDUser(completion: completion5)
            }else{
                self.type = 1
                let completion5 = { (uid: String)in
                    sentToUsername = uid
                }
                self.getUIDModerator(completion: completion5)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.type == 0{
                let completion4 = { (newOtherVal: Double) in
                    sentToValue = newOtherVal
                }
                self.getUserBalanceToUpdate(sentToUsername, completion: completion4)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    WalletController().updateDatabaseValues(sentToUsername, (sentToValue + val))
                }
            }else if self.type == 1{
                let completion4 = { (newOtherVal: Double) in
                    sentToValue = newOtherVal
                }
                self.getModeratorBalanceToUpdate(sentToUsername, completion: completion4)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    WalletControllerMod().updateDatabaseValues(sentToUsername, (sentToValue + val))
                }
            }
        }
    }
}
