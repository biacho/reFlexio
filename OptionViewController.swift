//
//  OptionViewController.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 31/08/15.
//  Copyright © 2015 Biacho. All rights reserved.
//

import UIKit

class OptionViewController: UIViewController
{

	let defaults = NSUserDefaults.standardUserDefaults()

	@IBOutlet weak var languageSwitch: UISegmentedControl!
	
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var languageLabel: UILabel!
	@IBOutlet weak var soundLabel: UILabel!
	@IBOutlet weak var musicLabel: UILabel!
	@IBOutlet weak var doneLabel: UIButton!
	
	@IBAction func languageSwitch(sender: AnyObject!)
	{
		let language = (languageSwitch.titleForSegmentAtIndex(languageSwitch.selectedSegmentIndex)!)
		defaults.setObject((languageSwitch.titleForSegmentAtIndex(languageSwitch.selectedSegmentIndex)!), forKey: "gameLanguage")
		defaults.setObject((languageSwitch.selectedSegmentIndex), forKey: "selectSegmentIndex")
		setUpLanguage(language)
	}
	
	
	@IBAction func done(sender: AnyObject)
	{
		print("Done!")
	}
	
	
	func setUpLanguage(lang: String)
	{
		if let path = NSBundle.mainBundle().pathForResource("Language", ofType: "plist")
		{
			if let dict = NSDictionary(contentsOfFile: path)
			{
				let dic = dict.objectForKey(lang)!
				
				titleLabel.text = dic.objectForKey("options") as? String
				languageLabel.text = dic.objectForKey("language") as? String
				soundLabel.text = dic.objectForKey("sound") as? String
				musicLabel.text = dic.objectForKey("music") as? String
				doneLabel.setTitle(dic.objectForKey("done") as? String, forState: UIControlState.Normal)
			}
		}
	}
	
	override func viewDidLoad()
	{
		print("Hello in OptionsViewController :)")
		languageSwitch.selectedSegmentIndex = defaults.integerForKey("selectSegmentIndex")
		setUpLanguage(languageSwitch.titleForSegmentAtIndex(languageSwitch.selectedSegmentIndex)!)
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true;
	}
}