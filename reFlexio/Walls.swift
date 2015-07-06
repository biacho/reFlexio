//
//  Walls.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 03/07/15.
//  Copyright © 2015 Biacho. All rights reserved.
//

import Foundation
import SpriteKit

class Walls: SKNode { // SKSpriteNode {
	
	var hasSomePhysics: Bool = false
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	init (passData: Dictionary<String, String>)
	{
		
		let size: CGSize = CGSizeFromString(passData["Size"]!)
		let location: CGPoint = CGPointFromString(passData["Location"]!)
		
		
		//let wall: SKSpriteNode = SKSpriteNode(color: UIColor.redColor(), size: size)
		//wall.name = "Top Wall"
		
		//super.init(texture: SKTexture(), color: UIColor.redColor(), size: size)
		super.init()

		let wall: SKSpriteNode = SKSpriteNode(color: UIColor.redColor(), size: size)
		wall.physicsBody?.affectedByGravity = false
		wall.physicsBody?.allowsRotation = false
		

		let positionX = location.x// - wall.size.width/2
		let positionY = location.y// - wall.size.height/2

		wall.position = CGPointMake(positionX, positionY)
		wall.physicsBody = SKPhysicsBody(rectangleOfSize: wall.size)
		
		wall.physicsBody!.dynamic = false
		wall.physicsBody!.categoryBitMask = Obstacles.wallTop.rawValue
		wall.physicsBody!.contactTestBitMask = Obstacles.ball.rawValue
		wall.physicsBody!.collisionBitMask = Obstacles.nothing.rawValue
		wall.physicsBody!.usesPreciseCollisionDetection = false
		
		addChild(wall)
	}
	
	func update() {
		// this instance will update when told to by the GameScene class
	}

}
