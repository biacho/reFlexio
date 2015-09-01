//
//  Brick.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 03/07/15.
//  Copyright © 2015 Biacho. All rights reserved.
//

import Foundation
import SpriteKit

class Brick: SKSpriteNode {

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	

	init(imageNamed: String)
	{
		
		let imageTexture = SKTexture(imageNamed: imageNamed)
		var x: CGFloat = 0.0
		var y: CGFloat = 0.0
		
		if (UIDevice.currentDevice().userInterfaceIdiom == .Pad)
		{
			x = 50
			y = 200
		}
		else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone)
		{
			x = 20
			y = 70
		}
		
		let size: CGSize = CGSizeMake(y, x)
		
		//let size: CGSize = CGSizeMake(imageTexture.size().width, imageTexture.size().height)
		
		super.init(texture: imageTexture, color: UIColor(), size: size)
		
		let body: SKPhysicsBody = SKPhysicsBody(rectangleOfSize: self.size)
		body.dynamic = false
		body.categoryBitMask = Obstacles.brick.rawValue
		body.contactTestBitMask = Obstacles.ball.rawValue
		body.collisionBitMask = Obstacles.nothing.rawValue
		body.usesPreciseCollisionDetection = false
		
		self.physicsBody = body
	}
	
	func update() {
		// this instance will update when told to by the GameScene class
	}
}