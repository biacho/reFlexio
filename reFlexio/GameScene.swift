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
	
	//let ball = SKSpriteNode(imageNamed: "Ball")
	var ball:Ball!
	
	//let tray = SKSpriteNode(imageNamed: "Tray")
	var tray:Tray!
	
	var wall:Walls!
	
	let gameOverLabel = SKLabelNode(fontNamed:"Chalkduster")
	
	var moveBallToDirection = SKAction()
	var startBallPosition = CGPoint() // Pocztkowa pozycja piłeczki
	var startTrayPosition = CGPoint() // Początkowa pozycja tacki
	var movementDirection = CGPoint() // Kierynek w którym porusza się piłeczka
	var reflectionAngle = 1
	var move: Bool = true
	var gameIsOver: Bool = false
	var ballIsInMiddleOfMoving: Bool = false
	
	//var obstacle: Bool = false
	
	var x = CGFloat() // do wyznaczania celu poruszania się
	var y = CGFloat() // do wyznaczania celu poruszania się

	
	
	
	var obstaclesType = Obstacles.nothing
	
	// Collision in SpriteKit
	func didBeginContact(contact: SKPhysicsContact) {

		print("Contact!")

		// this gets calld automaticly when two object begin contact with each other
		
		var firstBody: SKPhysicsBody
		var secondBody: SKPhysicsBody
		
		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
		{
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		}
		else
		{
			firstBody = contact.bodyB
			secondBody = contact.bodyA
		}

		if ((firstBody.categoryBitMask & Obstacles.ball.rawValue != 0) &&
			(secondBody.categoryBitMask & Obstacles.tray.rawValue != 0))
		{
			hitInTray()
		}
		else if ((firstBody.categoryBitMask & Obstacles.ball.rawValue != 0) &&
				(secondBody.categoryBitMask & Obstacles.wallTop.rawValue != 0))
		{
			print("Zief")
			hitInTop()
		}
	}


	func didEndContact(contact: SKPhysicsContact) {
		// this gets calld automaticly when two object end contact with each other
	}
	// ---
	
    override func didMoveToView(view: SKView) {
		
		/* Setup veriables */
		let size: CGSize = CGSizeMake(self.size.width, 1)
		let location: CGPoint = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame))
		
		let passData: [String: String] = [
			"Size" : NSStringFromCGSize(size),
			"Location" : NSStringFromCGPoint(location),
		]
		
		let topWall = Walls(passData: passData)
		addChild(topWall)
		
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
	
	func letBallMove()
	{
		// Wprawić w ruch piłeczkę
		movementDirection = tray.position
		moveBallToDirection = SKAction.moveTo(movementDirection, duration: NSTimeInterval(2.0))
		ball.runAction(moveBallToDirection)

		//ball.runAction(SKAction.repeatActionForever(SKAction.sequence([
			//SKAction.runBlock(moveBall),
			//SKAction.waitForDuration(0.1) // 0.1
			//])))
	}

/*
	func moveBall()
	{
		if (ball.position.y + ball.size.height/2 <= tray.position.y + tray.size.height)
		{
			if (ball.position.x <= tray.position.x + tray.size.width/2 && ball.position.x >= tray.position.x - tray.size.width/2) // Tray
			{
				obstaclesType = Obstacles.tray
			}
			else // Dół
			{
				obstaclesType = Obstacles.wallBottom
			}
		}
		else if (ball.position.y + ball.size.height/2 >= CGRectGetMaxY(self.frame)) // Góra
		{
			obstaclesType = Obstacles.wallTop
		}
		else if (ball.position.x + ball.size.width/2 >= CGRectGetMaxX(self.frame)) // Prawa ściana
		{
			if (ball.position.y > 0 || ball.position.y < CGRectGetMaxY(self.frame))
			{
				obstaclesType = Obstacles.wallRight
			}
		}
		else if (ball.position.x + ball.size.width/2 <= CGRectGetMinX(self.frame)) // Lewa ściana
		{
			if (ball.position.y > 0 || ball.position.y < CGRectGetMaxY(self.frame))
			{
				obstaclesType = Obstacles.wallLeft
			}
		}
		checkObstacles()
	}
*/
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
			print("move: \(move)")
			
		default:
			return
		}
	}
	
	func hitInTray()
	{

			print("hitInTray")
			
			x = movementDirection.x
			y = movementDirection.y
			
			//print("x: \(x), y: \(y)")
			//print("ball: \(ball.position.x), y: \(ball.position.y + ball.size.height/2)")
			
			y = CGRectGetMaxY(frame.self)
			x = frame.size.width/2
			
			movementDirection = CGPoint(x: x, y: y)
			
			moveBallToDirection = SKAction.moveTo(movementDirection, duration: 2.0)
			ball.runAction(moveBallToDirection)

		obstaclesType = Obstacles.nothing
	}
	
	func hitInTop()
	{
		print("move: \(move)")
print("hitInTop")
			
			x = movementDirection.x
			y = movementDirection.y
			
			y = CGRectGetMinY(frame.self)
			x = frame.size.width/2
			
			movementDirection = CGPoint(x: x, y: y)
			
			moveBallToDirection = SKAction.moveTo(movementDirection, duration: 2.0)
			ball.runAction(moveBallToDirection)

		obstaclesType = Obstacles.nothing
	}
	
	func hitInLeftWall()
	{

			print("Lewa ściana")
			
			x = movementDirection.x
			y = movementDirection.y
			movementDirection = CGPoint(x: -x, y: y)
			
			moveBallToDirection = SKAction.moveTo(movementDirection, duration: 2.0)
			ball.runAction(moveBallToDirection)

		obstaclesType = Obstacles.nothing
	}
	
	func hitInRightWall()
	{

			print("Prawa ściana")
			x = movementDirection.x
			y = movementDirection.y
			movementDirection = CGPoint(x: -x, y: y)
			
			moveBallToDirection = SKAction.moveTo(movementDirection, duration: 2.0)
			ball.runAction(moveBallToDirection)


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
				letBallMove()
				ballIsInMiddleOfMoving = true
			}
		}
	}
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
