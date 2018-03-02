//
//  GameViewController.swift
//  AlienEscape
//
//  Created by timofey makhlay on 6/30/17.
//  Copyright © 2017 timofey makhlay. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds
import AdSupport


class GameViewController: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate{
    var adBannerView: GADBannerView!
    var myAd = GADInterstitial()
    let request = GADRequest()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MainMenu") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAndShow), name: NSNotification.Name(rawValue: "loadAndShow"), object: nil)
    }
    @objc func loadAndShow() {
        request.testDevices = [ kGADSimulatorID ];
        myAd.setAdUnitID("ca-app-pub-6454574712655895/1809701850")
        myAd.delegate = self
        myAd.load(request)
        print("request for ad works")
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if (self.myAd.isReady) {
             print("request for ad is ready")
            myAd.present(fromRootViewController: self)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
