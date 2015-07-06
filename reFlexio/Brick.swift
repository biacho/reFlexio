//
//  Brick.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 03/07/15.
//  Copyright © 2015 Biacho. All rights reserved.
//

import Foundation
import SpriteKit

class Bick: SKNode {
	
	var hasSomePhysics: Bool = false

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	init (theDict: Dictionary<String, String>) {
		
		super.init()
		
		let image = theDict["ImageName"]
		let location: CGPoint = CGPointFromString(theDict["Location"]!)
		self.position = location
		
		if ((theDict["PlaceMultiplesOnX"]) != nil)
		{
			let amount:Int = Int(theDict["PlaceMultiplesOnX"]!)!
			
			if (amount > 1)
			{
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
			else if (amount == 1)
			{
				let objectSprite: SKSpriteNode = SKSpriteNode(imageNamed: image!)
				self.addChild(objectSprite)
				
				hasSomePhysics = true
				
				objectSprite.physicsBody = SKPhysicsBody(rectangleOfSize: objectSprite.size)
				objectSprite.physicsBody?.dynamic = false
				objectSprite.physicsBody!.categoryBitMask = Obstacles.tray.rawValue
			}
		}
		else
		{
			print("Number od Tray is 0")
		}
	}

}