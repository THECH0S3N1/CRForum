//
//  GeneratiorController.swift
//  CRForum
//
//  Created by OSXXX on 13/07/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class GenerationController: UIViewController {

    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    var totalLocalBalance = 0.0
    @IBOutlet weak var tabBar: UITabBarItem!
    
    
    @IBOutlet var generateView: UIView!
    
    
    @IBOutlet weak var generateButton: UIButton!
    
    
    
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
    
    
    @IBAction func generateButton(_ sender: Any){
        generateView.isUserInteractionEnabled = false
        generateButton.isHidden = true
        animateProgress()
        removePrevValue()
        saveNewValues()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    func animateProgress(){
        
        progressBar()
        let anime = CABasicAnimation(keyPath: "strokeEnd")
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.shapeLayer.removeFromSuperlayer()
            self.trackLayer.removeFromSuperlayer()
            self.generateButton.isHidden = false
        })
        anime.toValue = 1
        anime.duration = 5
        anime.fillMode = kCAFillModeForwards
        anime.isRemovedOnCompletion = false
        shapeLayer.add(anime, forKey: "bas")
        CATransaction.commit()
        
    }
    
    
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

