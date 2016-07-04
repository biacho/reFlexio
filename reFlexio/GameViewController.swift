//
//  GameViewController.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 11/06/15.
//  Copyright (c) 2015 Biacho. All rights reserved.
//

import UIKit
import AVFoundation
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

class GameViewController: UIViewController, GameSceneDelegate {
	
	@IBOutlet weak var menuInGameView: UIView!
	@IBOutlet weak var playerNameView: UIView!
	//@IBOutlet weak var coverViewToBlur: UIView!
	
	@IBOutlet weak var showInGameMenuButton: UIButton!
	@IBOutlet weak var hideInGameMenuButton: UIButton!
	
	@IBOutlet weak var points: UILabel!
	
	var translation = String()
	var viewTransitionTo = CGFloat()
	
	var scoreOnScreen: Bool = false
	
	var animationMenuInGameView: CALayer {
		return menuInGameView.layer
	}
	
	var animationPlayerNameView: CALayer {
		return playerNameView.layer
	}
	
	@IBAction func showInGameMenu(sender: AnyObject!)
	{
		translation = "showMenu"
		setUpMenuAnimation("showMenu")
	}
	
	@IBAction func hideInGameMenu(sender: AnyObject)
	{
		translation = "hideMenu"
		setUpMenuAnimation("hideMenu")
	}
	
	func gameOver()
	{
		//
		// TODO: Delegacja z GameScene wywoływana po zakończeniu gry (GameOver) 
		// Pomyśleć nad rozwiązaniem z drugą sceną zawierającą textfield i labele...
		// TODO: Dodać chowanie się klawiatury po wpisaniu nazwy gracza.
		// TODO: Dodać zapis nazwy i punktów do plist albo DataModel (tutaj TRZEBA ogarnąc temat...) 
		//
		// Przydatny link:
		// https://b4sht4.wordpress.com/2014/12/02/implementing-a-delegate-pattern-between-spritekit-scenes/
		//
		
		print("Game Over")
		
		//translation = "showPlayerNameView"
		//setUpPlayerNameView("show")
	}
	
	@IBAction func hidePlayerNameView(sender: AnyObject)
	{
		print("playerNameView is disable")
		translation = "hidePlayerNameView"
		//setUpPlayerNameView("hide")
	}
	
	override func animationDidStart(anim: CAAnimation) {
		print("Start Animation")
		
		switch translation {
		case "showMenu":
			showInGameMenuButton.hidden = true
			NSNotificationCenter.defaultCenter().postNotificationName("showMenu", object: nil)

		case "hideMenu":
			showInGameMenuButton.hidden = false
			
		case "showPlayerNameView":
			playerNameView.hidden = false
			
			
		default:
			break
		}
		
	}
	override func animationDidStop(anim: CAAnimation, finished flag: Bool)
	{
		print("Stop Animation")
		
		switch translation {
		case "showMenu":
			showInGameMenuButton.hidden = true
			menuInGameView.frame.origin.x = viewTransitionTo - menuInGameView.frame.size.width/2

		case "hideMenu":
			showInGameMenuButton.hidden = false
			menuInGameView.frame.origin.x = viewTransitionTo - menuInGameView.frame.size.width/2
			NSNotificationCenter.defaultCenter().postNotificationName("hideMenu", object: nil)
			
		case "showPlayerNameView":
			playerNameView.hidden = false
			
			
		case "hidePlayerNameView":
			playerNameView.hidden = true
			NSNotificationCenter.defaultCenter().postNotificationName("hidePlayerNameView", object: nil)
			
		default:
			break
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        //if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
		// Configure the view.
		let scene = GameScene(size: view.bounds.size)
		let skView = self.view as! SKView
		skView.showsFPS = true
		skView.showsNodeCount = true
		
		// GameViewController Delegate
		scene.gameSceneDelegate = self
		
		// Others View's
		//self.view.insertSubview(playerNameView, atIndex: 1)
		playerNameView.hidden = true
		playerNameView.alpha = 1.0
		print("\(playerNameView.debugDescription)")
		
		
		/* Sprite Kit applies additional optimizations to improve rendering performance */
		skView.ignoresSiblingOrder = true
		
		/* Set the scale mode to scale to fit the window */
		scene.scaleMode = .ResizeFill
		
		skView.presentScene(scene)
		
        //}
    }

	func setUpMenuAnimation(transition: String) {
		animationMenuInGameView.borderWidth = 0.5
		
		if transition == "showMenu"
		{
			viewTransitionTo = animationMenuInGameView.position.x + animationMenuInGameView.frame.width
		}
		else if transition == "hideMenu"
		{
			viewTransitionTo = animationMenuInGameView.position.x - animationMenuInGameView.frame.width
		}
		
		let viewAnimation = CABasicAnimation(keyPath: "position.x")
		viewAnimation.fromValue = animationMenuInGameView.position.x
		viewAnimation.toValue = viewTransitionTo
		viewAnimation.duration = 0.3
		viewAnimation.delegate = self
		viewAnimation.removedOnCompletion = false
		viewAnimation.fillMode = kCAFillModeForwards
		animationMenuInGameView.addAnimation(viewAnimation, forKey: "position.x")
	}
	
	func setUpPlayerNameView(transition: String)
	{
		print("playerNameView animation:")
		
		// TODO:	Animacja nie działa, więc trzeba coś poprawić. Wyczytane na stackoverflow, że jedna warstwa (layer) nie obsłuży fadeIn i fadeOut...
		//			http://stackoverflow.com/questions/8707104/coreanimation-opacity-fade-in-and-out-animation-not-working
		//			Może tutaj wystraczy samo UIViewAnimation ?
		/*
		if (transition == "show")
		{
			print("show")
			
			let viewAnimation = CABasicAnimation(keyPath: "opacity")
			viewAnimation.fromValue = NSValue(nonretainedObject: 0.0)
			viewAnimation.toValue = NSValue(nonretainedObject: 1.0)
			playerNameView.hidden = false
			print("\(playerNameView.debugDescription)")
			scoreOnScreen = true
			viewAnimation.duration = 0.5
			viewAnimation.delegate = self
			viewAnimation.removedOnCompletion = false
			viewAnimation.fillMode = kCAFillModeForwards
			//viewAnimation.fillMode = kCAFillModeBoth
			animationPlayerNameView.addAnimation(viewAnimation, forKey: "opacity")

		}
		else if (transition == "hide")
		{
			print("hide")
			
			let viewAnimation = CABasicAnimation(keyPath: "opacity")
			viewAnimation.fromValue = NSValue(nonretainedObject: 1.0)
			viewAnimation.toValue = NSValue(nonretainedObject: 0.0)
			print("\(playerNameView.debugDescription)")
			scoreOnScreen = false
			viewAnimation.duration = 0.5
			viewAnimation.delegate = self
			viewAnimation.removedOnCompletion = false
			viewAnimation.fillMode = kCAFillModeForwards
			//viewAnimation.fillMode = kCAFillModeBoth
			animationPlayerNameView.addAnimation(viewAnimation, forKey: "opacity")
		}
		*/
	}
	
	func isScoreIsOnScreen() -> Bool
	{
		if scoreOnScreen
		{
			return true
		}
		else
		{
			return false
		}
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
