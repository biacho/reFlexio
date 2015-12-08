//
//  MenuViewController.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 28/08/15.
//  Copyright © 2015 Biacho. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UIPopoverPresentationControllerDelegate
{
	
	@IBOutlet weak var playLabel: UIButton!
	@IBOutlet weak var scoresLabel: UIButton!
	@IBOutlet weak var creditsLabel: UIButton!
	@IBOutlet weak var optionsLabel: UIButton!
	
	let defaults = NSUserDefaults.standardUserDefaults()


	@IBAction func unwindToMenu(unwindSegue: UIStoryboardSegue)
	{
		if let _ = unwindSegue.sourceViewController as? OptionViewController
		{
			if let language = defaults.stringForKey("gameLanguage")
			{
				setUpLanguage(language)
			}
			else
			{
				print("Back to Menu.")
			}
		}
		else if let _ = unwindSegue.sourceViewController as? GameViewController
		{
			print("Back from Game")
		}
	}
	
	@IBAction func playButton(sender: UIButton)
	{
		print("Play!")
	}
	
	
	
	func setUpLanguage(lang: String)
	{
		if let path = NSBundle.mainBundle().pathForResource("Language", ofType: "plist")
		{
			if let dict = NSDictionary(contentsOfFile: path)
			{
				let dic = dict.objectForKey(lang)!
				
				playLabel.setTitle(dic.objectForKey("play") as? String, forState: UIControlState.Normal)
				scoresLabel.setTitle(dic.objectForKey("scores") as? String, forState: UIControlState.Normal)
				creditsLabel.setTitle(dic.objectForKey("credits") as? String, forState: UIControlState.Normal)
				optionsLabel.setTitle(dic.objectForKey("options") as? String, forState: UIControlState.Normal)
			}
		}
	}
	
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.None
	}
	
	override func viewDidLoad()
	{
		print("Hello in MenuViewController :)")
		
		if let language = defaults.stringForKey("gameLanguage")
		{
			setUpLanguage(language)
		}
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true;
	}

}