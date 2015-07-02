//
//  ball.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 02/07/15.
//  Copyright © 2015 Biacho. All rights reserved.
//

import Foundation
import SpriteKit

class Ball: SKSpriteNode {
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	init (imageNamed: String)
	{
		let imageTexture = SKTexture(imageNamed: imageNamed)
		
		var x: CGFloat = 0.0
		var y: CGFloat = 0.0
		
		if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) // iPad Mini bez retiny 7.9"
		{
			x = 0.6
			y = 0.6
		}
		else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) // 0.3 dla iPhone 6 4.7"
		{
			x = 0.4
			y = 0.4
		}
		
		let size: CGSize = CGSizeMake(imageTexture.size().width * x, imageTexture.size().height * y)
		super.init(texture: imageTexture, color: UIColor(), size: size)
		
		let body: SKPhysicsBody = SKPhysicsBody(circleOfRadius: imageTexture.size().width / 4.6)
		//body.dynamic = true
		//body.affectedByGravity = true
		body.allowsRotation = false
		body.categoryBitMask = Obstacles.ball.rawValue
		body.contactTestBitMask = Obstacles.tray.rawValue
		
		self.physicsBody = body
	}
	
	func update() {		
		// this instance will update when told to by the GameScene class
	}
}
