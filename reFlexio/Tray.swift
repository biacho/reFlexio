//
//  Tray.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 02/07/15.
//  Copyright © 2015 Biacho. All rights reserved.
//

import Foundation
import SpriteKit

class Tray: SKSpriteNode {
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("int(coder:) has not been implemented")
	}
	
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
		
		let body: SKPhysicsBody = SKPhysicsBody(rectangleOfSize: self.size)
		body.affectedByGravity = false
		body.allowsRotation = false
		
		//body.dynamic = false
		body.categoryBitMask = Obstacles.tray.rawValue
		body.contactTestBitMask = Obstacles.ball.rawValue
		body.collisionBitMask = Obstacles.nothing.rawValue
		body.usesPreciseCollisionDetection = false
		
		self.physicsBody = body
	}
	
	func update() {
		// this instance will update when told to by the GameScene class
	}
}
