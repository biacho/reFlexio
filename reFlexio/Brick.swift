//
//  Brick.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 03/07/15.
//  Copyright © 2015 Biacho. All rights reserved.
//

import Foundation
import SpriteKit

class Brick: SKNode {
	
	var hasSomePhysics: Bool = false
	//var isExist: Bool = false

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	init (theDict: Dictionary<String, String>) {
		
		super.init()

		//isExist = true
		let image = theDict["ImageName"]!
		//let textureImage: SKTexture = SKTexture(imageNamed: image)
		let location: CGPoint = CGPointFromString(theDict["Location"]!)
		let amount:Int = Int(theDict["PlaceMultiplesOnX"]!)!

		//super.init(texture: textureImage, color: UIColor(), size: textureImage.size())
		self.position = location

		if ((theDict["PlaceMultiplesOnX"]) != nil)
		{
			
			if (amount > 1)
			{
				for (var i = 0; i < amount; i++)
				{
					let objectSprite: SKSpriteNode = SKSpriteNode(imageNamed: image)
					self.addChild(objectSprite)
					
					objectSprite.position = CGPoint(x: objectSprite.size.width * CGFloat(i), y: CGFloat(i)) // * 6)
					
					objectSprite.physicsBody = SKPhysicsBody(rectangleOfSize: objectSprite.size)
					objectSprite.physicsBody!.dynamic = false
					objectSprite.physicsBody!.categoryBitMask = Obstacles.brick.rawValue
					objectSprite.physicsBody!.contactTestBitMask = Obstacles.ball.rawValue
					objectSprite.physicsBody!.collisionBitMask = Obstacles.nothing.rawValue
					objectSprite.physicsBody!.usesPreciseCollisionDetection = false
					
				}
			}
			else if (amount == 1)
			{
				let objectSprite: SKSpriteNode = SKSpriteNode(imageNamed: image)
				self.addChild(objectSprite)
				
				hasSomePhysics = true
				
				objectSprite.physicsBody = SKPhysicsBody(rectangleOfSize: objectSprite.size)
				objectSprite.physicsBody!.dynamic = false
				objectSprite.physicsBody!.categoryBitMask = Obstacles.brick.rawValue
				objectSprite.physicsBody!.contactTestBitMask = Obstacles.ball.rawValue
				objectSprite.physicsBody!.collisionBitMask = Obstacles.nothing.rawValue
				objectSprite.physicsBody!.usesPreciseCollisionDetection = false
			}
		}
		else
		{
			print("Number od Bricks is 0")
		}
	}
}