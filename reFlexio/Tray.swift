//
//  Tray.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 02/07/15.
//  Copyright © 2015 Biacho. All rights reserved.
//

import Foundation
import SpriteKit

class Tray: SKNode {
	
	var hasSomePhysics: Bool = false
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("int(coder:) has not been implemented")
	}
	
	init (theDict: Dictionary<String, String>) {
		super.init()
		
		let image = theDict["ImageName"]
		let location: CGPoint = CGPointFromString(theDict["Location"]!)
		self.position = location
		
		if ((theDict["PlaceMultiplesOnX"]) != nil)
		{
			
			let amount:Int = Int(theDict["PlaceMultiplesOnX"]!)!

			for (var i = 0; i < amount; i++)
			{
				let objectSprite: SKSpriteNode = SKSpriteNode(imageNamed: image!)
				self.addChild(objectSprite)
				
				objectSprite.position = CGPoint(x: objectSprite.size.width * CGFloat(i), y: CGFloat(i) * 6)
				
				objectSprite.physicsBody = SKPhysicsBody(rectangleOfSize: objectSprite.size)
				objectSprite.physicsBody!.dynamic = false
				objectSprite.physicsBody!.categoryBitMask = Obstacles.tray.rawValue
				
			}
		}
		else
		{
			let objectSprite: SKSpriteNode = SKSpriteNode(imageNamed: image!)
			self.addChild(objectSprite)
			
			hasSomePhysics = true
			
			objectSprite.physicsBody = SKPhysicsBody(rectangleOfSize: objectSprite.size)
			objectSprite.physicsBody?.dynamic = false
			objectSprite.physicsBody!.categoryBitMask = Obstacles.tray.rawValue
		}
	}
	
	
	
	
	
	
	/*
	init (imageNamed: String)
	{
		let imageTexture = SKTexture(imageNamed: imageNamed)
		var x: CGFloat = 0.0
		var y: CGFloat = 0.0
		
		if (UIDevice.currentDevice().userInterfaceIdiom == .Pad)
		{
			print("iPad")
			x = 50
			y = 200
		}
		else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone)
		{
			print("iPhone")
			x = 30
			y = 100
		}
		
		let size: CGSize = CGSizeMake(y, x)
		super.init(texture: imageTexture, color: UIColor(), size: size)
		
		let body: SKPhysicsBody = SKPhysicsBody(circleOfRadius: imageTexture.size().width)
		body.dynamic = true
		body.affectedByGravity = true
		body.allowsRotation = false
		
		self.physicsBody = body
	}
	*/
	
	func update() {
		// this instance will update when told to by the GameScene class
	}
}
