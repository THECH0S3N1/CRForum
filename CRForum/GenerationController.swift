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
    
    @IBOutlet weak var generateButton: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext



    @IBAction func generateButton(_ sender: Any) {
        
        generateButton.isHidden = true
        animateProgress()
        
        let userEntity = NSEntityDescription.entity(forEntityName: "UserData", in: self.context)!
        let user = NSManagedObject(entity: userEntity, insertInto: self.context)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        var totalBalanceLocal = 0.0
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                totalBalanceLocal = data.value(forKey: "totalbalance") as! Double
                totalBalanceLocal = totalBalanceLocal + 1
                user.setValue(totalBalanceLocal, forKey: "totalbalance")
            }
        } catch {
            print("Loading data from storage failed")
        }
        
        
        
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
        anime.duration = 10
        anime.fillMode = kCAFillModeForwards
        anime.isRemovedOnCompletion = false
        shapeLayer.add(anime, forKey: "bas")
        CATransaction.commit()
        
    }
    
    
    func progressBar(){
        let center = view.center
        let colorScheme = UIColor(red: 89/255, green: 34/255, blue: 185/255, alpha: 1)
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: (-CGFloat.pi/2), endAngle: (2*CGFloat.pi), clockwise: true)
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.white.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = kCALineCapRound
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = colorScheme.cgColor
        shapeLayer.lineWidth = 10
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

