//
//  GameScene.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 11/06/15.
//  Copyright (c) 2015 Biacho. All rights reserved.
//

import SpriteKit

enum Obstacles: UInt32 {
	case nothing		= 0
	case ball			= 1
	case tray			= 2
	case wallBottom		= 3
	case wallTop		= 4
	case wallLeft		= 5
	case wallRight		= 6
	case brick			= 7
}

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	/* Model's & Node's */
	var ball:Ball!
	var tray:Tray!
	var wall:Walls!
	var obstaclesType = Obstacles.nothing
	let gameOverLabel = SKLabelNode(fontNamed:"Chalkduster")
	
	var moveBallToDirection = SKAction()
	var startBallPosition = CGPoint() // Pocztkowa pozycja piłeczki
	var startTrayPosition = CGPoint() // Początkowa pozycja tacki
	var movementDirection = CGPoint() // Kierynek w którym porusza się piłeczka
	var gameIsOver: Bool = false
	var ballIsInMiddleOfMoving: Bool = false


	/* Set Up Move */
	var ballSpeed: CGFloat = 5.0
	var ballMoveDirection = String()
	
	// Collision in SpriteKit
	func didBeginContact(contact: SKPhysicsContact) {
		
		print("Contact!")
		
		let secondBody: SKPhysicsBody = contact.bodyA
		
		if (secondBody.categoryBitMask == 2)
		{
			hitInTray()
		}
		else if (secondBody.categoryBitMask == 3)
		{
			hitInBottom()
		}
		else if (secondBody.categoryBitMask == 4)
		{
			hitInTop()
		}
		else if (secondBody.categoryBitMask == 5)
		{
			hitInLeftWall()
		}
		else if (secondBody.categoryBitMask == 6)
		{
			hitInRightWall()
		}
	}
	
	override func didMoveToView(view: SKView) {
		
		/* Setup veriables */
		let sizeWallTop: CGSize = CGSizeMake(self.size.width, 1)
		let locationWallTop: CGPoint = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame))
		
		let sizeWallBottom: CGSize = CGSizeMake(self.size.width, 1)
		let locationWallBottom: CGPoint = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame))
		
		let sizeWallLeft: CGSize = CGSizeMake(1, self.size.height)
		let locationWallLeft: CGPoint = CGPointMake(0, CGRectGetMidY(self.frame))
		
		let sizeWallRight: CGSize = CGSizeMake(1, self.size.height)
		let locationWallRight: CGPoint = CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMidY(self.frame))
		
		let passData: [String: String] = [
			"Size_WallTop" : NSStringFromCGSize(sizeWallTop),
			"Location_WallTop" : NSStringFromCGPoint(locationWallTop),
			"Size_WallBottom" : NSStringFromCGSize(sizeWallBottom),
			"Location_WallBottom" : NSStringFromCGPoint(locationWallBottom),
			"Size_WallLeft" : NSStringFromCGSize(sizeWallLeft),
			"Location_WallLeft" : NSStringFromCGPoint(locationWallLeft),
			"Size_WallRight" : NSStringFromCGSize(sizeWallRight),
			"Location_WallRight" : NSStringFromCGPoint(locationWallRight),
		]
		
		let wall = Walls(passData: passData)
		addChild(wall)
		
		/* Setup your scene here */
		view.showsPhysics = true
		view.showsFPS = true
		view.showsNodeCount = true
		
		traySetUp()
		ballSetUp()
		
		physicsWorld.gravity = CGVectorMake(0, 0)
		physicsWorld.contactDelegate = self
		
		let panGesture:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveTray:")
		view.addGestureRecognizer(panGesture)
	}
	
	// BALL
	func ballSetUp() // Ustawienia piłki
	{
		ball = Ball(imageNamed: "Ball")
		ball.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)) // początkowa pozycja piłeczki
		startBallPosition = ball.position
		addChild(ball)
	}
	
	func moveBall(ballSpeed: CGFloat, direction: String)
	{
		if (direction == "Up_Left")
		{
			//print("Up Left")
			moveBallToDirection = SKAction.moveBy(CGVectorMake(-1*ballSpeed, 1*ballSpeed), duration: 0.001)
		}
		else if (direction == "Up_Right")
		{
			//print("Up Right")
			moveBallToDirection = SKAction.moveBy(CGVectorMake(1*ballSpeed, 1*ballSpeed), duration: 0.001)
		}
		else if (direction == "Down_Left")
		{
			//print("Down Left")
			moveBallToDirection = SKAction.moveBy(CGVectorMake(-1*ballSpeed, -1*ballSpeed), duration: 0.001)
		}
		else if (direction == "Down_Right")
		{
			//print("Down Right")
			moveBallToDirection = SKAction.moveBy(CGVectorMake(1*ballSpeed, -1*ballSpeed), duration: 0.001)
		}
		else if (direction == "Down")
		{
			//print("Down")
			moveBallToDirection = SKAction.moveBy(CGVectorMake(0, -1*ballSpeed), duration: 0.001)
		}
		else if (direction == "Up")
		{
			//print("Up")
			moveBallToDirection = SKAction.moveBy(CGVectorMake(0, 1*ballSpeed), duration: 0.001)
		}
		else if (direction == "Stop")
		{
			//print("Stop")
			moveBallToDirection = SKAction.moveBy(CGVectorMake(0, 0), duration: 0.001)
		}
		
		ballMoveDirection = direction
		ball.runAction(moveBallToDirection)
	}
	
	func checkObstacles()
	{
		switch obstaclesType {
		case .wallTop:
			//print("Top")
			hitInTop()
			
		case .wallBottom:
			//print("Bottom")
			hitInBottom()
			
		case .wallLeft:
			//print("Left Wall")
			hitInLeftWall()
			
		case .wallRight:
			//print("Right Wall")
			hitInRightWall()
			
		case .tray:
			print("Tray")
			//hitInTray()
			
		case .brick:
			//print("Brick")
			hitInBrick()
			
		case .nothing:
			return
			
		default:
			return
		}
	}

	func hitInTray()
	{
		print("hitInTray")
		
		if (ballMoveDirection == "Down_Left")
		{
			moveBall(ballSpeed, direction: "Up_Right")
		}
		else if  (ballMoveDirection == "Down_Right")
		{
			moveBall(ballSpeed, direction: "Up_Left")
		}
		else
		{
			var directionsArray = ["Up", "Up_Right", "Up_Left"]
			let i = Int(arc4random_uniform(UInt32(directionsArray.count)))
			let randomDirection = String(directionsArray[i])
			moveBall(ballSpeed, direction: randomDirection)
		}
		
		obstaclesType = Obstacles.nothing
	}
	
	func hitInTop()
	{
		print("hitInTop")
		
		if (ballMoveDirection == "Up_Left")
		{
			moveBall(ballSpeed, direction: "Down_Left")
		}
		else if (ballMoveDirection == "Up_Right")
		{
			moveBall(ballSpeed, direction: "Down_Right")
		}
		else
		{
			moveBall(ballSpeed, direction: "Down")
		}
		
		obstaclesType = Obstacles.nothing
	}
	
	func hitInLeftWall()
	{
		
		print("hitInLeftWall")
		
		if (ballMoveDirection == "Down_Left")
		{
			moveBall(ballSpeed, direction: "Down_Right")
		}
		else
		{
			moveBall(ballSpeed, direction: "Up_Right")
		}
		
		obstaclesType = Obstacles.nothing
	}
	
	func hitInRightWall()
	{
		print("Prawa ściana")

		if (ballMoveDirection == "Down_Right")
		{
			moveBall(ballSpeed, direction: "Down_Left")
		}
		else
		{
			moveBall(ballSpeed, direction: "Up_Left")
		}
		
		obstaclesType = Obstacles.nothing
	}
	func hitInBrick()
	{
		print("Not yet :(")
	}
	
	func hitInBottom()
	{
		print("Game Over")
		gameOverLabel.childNodeWithName("GameOver")
		gameOverLabel.text = "Game Over :(";
		gameOverLabel.fontSize = 48;
		gameOverLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2);
		addChild(gameOverLabel)
		ball.removeAllActions()
		ball.removeFromParent()
		tray.removeAllActions()
		tray.removeFromParent()
		
		gameIsOver = true
		ballIsInMiddleOfMoving = false
		
		obstaclesType = Obstacles.nothing
	}
	
	// ---
	
	
	// TRAY
	func traySetUp()
	{
		startTrayPosition = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame) + 30)
		tray = Tray(imageNamed: "Tray")
		tray.position = startTrayPosition
		addChild(tray)
	}
	
	func moveTray(gesture: UIPanGestureRecognizer)
	{
		if (gesture.locationInView(self.view!).x <= tray.position.x + tray.size.width/2 && // <-- tacką można poruszać tylko jak palec jest nad nią
			gesture.locationInView(self.view!).x >= tray.position.x - tray.size.width/2)
		{
			var translation: CGPoint! = gesture.velocityInView(self.view!)
			//translation.x = (translation.x * 0.055) / 2.8		// Przyspieszenie tacki (iPad Mini 1gen)
			translation.x = (translation.x * 0.113) / 2.8		// Przyspieszenie tacki (iPhone 6 Symulatot)
			
			if (gesture.locationInView(view!).y >= self.frame.size.height - tray.size.height * 2) // <-- Ograniczenie pola poruszania tacką do dołu ekranu
			{
				if (gesture.velocityInView(view!).x > 0)
				{
					tray.position.x += translation.x
				}
				else if (gesture.velocityInView(view!).x < 0)
				{
					tray.position.x += translation.x
				}
				
				if (tray.position.x - tray.size.width/2 <= 0)
				{
					tray.position.x = 0 + tray.size.width/2
				}
				else if (tray.position.x >= self.frame.size.width - tray.size.width/2)
				{
					tray.position.x = self.frame.size.width - tray.size.width/2
				}
			}
			tray.runAction(SKAction.moveTo(tray.position, duration: 0))
		}
	}
	// ---
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		/* Called when a touch begins */
		if (gameIsOver)
		{
			ballSetUp()
			traySetUp()
			gameOverLabel.removeFromParent()
			gameIsOver = false
			ballIsInMiddleOfMoving = false
		}
		else
		{
			if (!ballIsInMiddleOfMoving)
			{
				moveBall(ballSpeed, direction: "Down")
				ballIsInMiddleOfMoving = true
			}
		}
	}
	
	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
		if (!gameIsOver)
		{
			moveBall(ballSpeed,direction: ballMoveDirection)
		}
	}
}
