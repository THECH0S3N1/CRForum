//
//  touchIDLogin.swift
//  CRForum
//
//  Created by OSXXX on 24/07/2018.
//  Copyright © 2018 Z Systems. All rights reserved.
//
import UIKit
import Firebase
import LocalAuthentication

import AVFoundation


class touchIDLogin: UIViewController {
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    var currentUserLabel = ""
    
    @IBOutlet weak var diffUser: UIButton!
    @IBAction func diffUser(_ sender: UIButton) {
        badloginFlag = 1
        performSegue(withIdentifier: "badLogin", sender: self)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Auth.auth().currentUser?.displayName as Any)
        currentUserLabel = "Not "
        currentUserLabel.append((Auth.auth().currentUser?.displayName)!)
        currentUserLabel.append("?")
        diffUser.setTitle(currentUserLabel, for: .normal)
        let videoPath = Bundle.main.url(forResource: "saver", withExtension: "mov")
        avPlayer = AVPlayer(url: videoPath!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = .clear
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero, completionHandler: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.play()
        paused = false
        
    }
    
    @IBAction func touchID_login_button(_ sender: Any) {
        let context:LAContext = LAContext()        
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil){
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Please login with your fingerprint to access CRForum", reply: {(wasCorrect, error) in
                if wasCorrect && Auth.auth().currentUser != nil {
                    if modflag == 1{
                        self.performSegue(withIdentifier: "loginModerator", sender: self)
                    }else{
                        self.performSegue(withIdentifier: "loginUser", sender: self)
                    }
                }
            })
        }
    }
    
    
}
