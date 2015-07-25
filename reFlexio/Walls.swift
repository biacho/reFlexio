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
		
		super.init()
		
		/* Wall Top */
		let sizeWallTop: CGSize = CGSizeFromString(passData["Size_WallTop"]!)
		let locationWallTop: CGPoint = CGPointFromString(passData["Location_WallTop"]!)
		let wallTop: SKSpriteNode = SKSpriteNode(color: UIColor(), size: sizeWallTop)
		wallTop.physicsBody?.affectedByGravity = false
		wallTop.physicsBody?.allowsRotation = false
		let positionX = locationWallTop.x
		let positionY = locationWallTop.y
		wallTop.position = CGPointMake(positionX, positionY)
		wallTop.physicsBody = SKPhysicsBody(rectangleOfSize: wallTop.size)
		wallTop.physicsBody!.dynamic = false
		wallTop.physicsBody!.categoryBitMask = Obstacles.wallTop.rawValue
		wallTop.physicsBody!.contactTestBitMask = Obstacles.ball.rawValue
		wallTop.physicsBody!.collisionBitMask = Obstacles.nothing.rawValue
		wallTop.physicsBody!.usesPreciseCollisionDetection = false
		addChild(wallTop)
		
		/* Wall Bottom */
		let sizeWallBottom: CGSize = CGSizeFromString(passData["Size_WallBottom"]!)
		let locationWallBottom: CGPoint = CGPointFromString(passData["Location_WallBottom"]!)
		let wallBottom: SKSpriteNode = SKSpriteNode(color: UIColor(), size: sizeWallBottom)
		wallBottom.physicsBody?.affectedByGravity = false
		wallBottom.physicsBody?.allowsRotation = false
		let positionWallBottomX = locationWallBottom.x
		let positionWallBottomY = locationWallBottom.y
		wallBottom.position = CGPointMake(positionWallBottomX, positionWallBottomY)
		wallBottom.physicsBody = SKPhysicsBody(rectangleOfSize: wallBottom.size)
		wallBottom.physicsBody!.dynamic = false
		wallBottom.physicsBody!.categoryBitMask = Obstacles.wallBottom.rawValue
		wallBottom.physicsBody!.contactTestBitMask = Obstacles.ball.rawValue
		wallBottom.physicsBody!.collisionBitMask = Obstacles.nothing.rawValue
		wallBottom.physicsBody!.usesPreciseCollisionDetection = false
		addChild(wallBottom)
		
		/* Left  */
		let sizeWallLeft: CGSize = CGSizeFromString(passData["Size_WallLeft"]!)
		let locationWallLeft: CGPoint = CGPointFromString(passData["Location_WallLeft"]!)
		let wallLeft: SKSpriteNode = SKSpriteNode(color: UIColor(), size: sizeWallLeft)
		wallLeft.physicsBody?.affectedByGravity = false
		wallLeft.physicsBody?.allowsRotation = false
		let positionWallLeftX = locationWallLeft.x
		let positionWallLeftY = locationWallLeft.y
		wallLeft.position = CGPointMake(positionWallLeftX, positionWallLeftY)
		wallLeft.physicsBody = SKPhysicsBody(rectangleOfSize: wallLeft.size)
		wallLeft.physicsBody!.dynamic = false
		wallLeft.physicsBody!.categoryBitMask = Obstacles.wallLeft.rawValue
		wallLeft.physicsBody!.contactTestBitMask = Obstacles.ball.rawValue
		wallLeft.physicsBody!.collisionBitMask = Obstacles.nothing.rawValue
		wallLeft.physicsBody!.usesPreciseCollisionDetection = false
		addChild(wallLeft)

		/* Right  */
		let sizeWallRight: CGSize = CGSizeFromString(passData["Size_WallRight"]!)
		let locationWallRight: CGPoint = CGPointFromString(passData["Location_WallRight"]!)
		let wallRight: SKSpriteNode = SKSpriteNode(color: UIColor(), size: sizeWallRight)
		wallRight.physicsBody?.affectedByGravity = false
		wallRight.physicsBody?.allowsRotation = false
		let positionWallRightX = locationWallRight.x
		let positionWallRightY = locationWallRight.y
		wallRight.position = CGPointMake(positionWallRightX, positionWallRightY)
		wallRight.physicsBody = SKPhysicsBody(rectangleOfSize: wallRight.size)
		wallRight.physicsBody!.dynamic = false
		wallRight.physicsBody!.categoryBitMask = Obstacles.wallRight.rawValue
		wallRight.physicsBody!.contactTestBitMask = Obstacles.ball.rawValue
		wallRight.physicsBody!.collisionBitMask = Obstacles.nothing.rawValue
		wallRight.physicsBody!.usesPreciseCollisionDetection = false
		addChild(wallRight)

	}
	
	func update() {
		// this instance will update when told to by the GameScene class
	}

}
