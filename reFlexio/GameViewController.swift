//
//  GameViewController.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 11/06/15.
//  Copyright (c) 2015 Biacho. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
			//let sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: NSErrorPointer()) // Swift 1.2
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe) // Swift 2.0
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

	
    override func viewDidLoad() {
        super.viewDidLoad()

        //if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
		let scene = GameScene(size: view.bounds.size)
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true

            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .ResizeFill
            
            skView.presentScene(scene)
        //}
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

	/* Swift 1.2
	override func supportedInterfaceOrientations() -> Int {
		let orientation = Int(UIInterfaceOrientationMask.Portrait.rawValue | UIInterfaceOrientationMask.PortraitUpsideDown.rawValue)
		return Int(UIInterfaceOrientationMask.All.rawValue)
	}
	*/
	
	// Swift 2.0
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.PortraitUpsideDown]
		return orientation
	}
	

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
