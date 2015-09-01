//
//  AboutViewController.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 01/09/15.
//  Copyright © 2015 Biacho. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController
{

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var backLabel: UIButton!
	
	@IBOutlet weak var textView: UITextView!
	
	let defaults = NSUserDefaults.standardUserDefaults()
	
	
	func setUpLanguage(lang: String)
	{
		if let path = NSBundle.mainBundle().pathForResource("Language", ofType: "plist")
		{
			if let dict = NSDictionary(contentsOfFile: path)
			{
				let dic = dict.objectForKey(lang)!
				
				titleLabel.text = dic.objectForKey("credits") as? String
				backLabel.setTitle(dic.objectForKey("back") as? String, forState: UIControlState.Normal)
			}
		}
	}
	
	override func viewDidLoad()
	{
		print("Hello in CreditsViewController :)")
		
		let language = defaults.stringForKey("gameLanguage")!
		setUpLanguage(language)
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true;
	}
}