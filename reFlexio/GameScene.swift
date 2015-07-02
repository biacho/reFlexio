//
//  GameScene.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 11/06/15.
//  Copyright (c) 2015 Biacho. All rights reserved.
//

import SpriteKit

enum Obstacles: UInt32 {
	case ball
	case nothing
	
	case wallBottom
	case wallTop
	case wallLeft
	case wallRight
	
	case tray
	
	case brick
}

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	//let ball = SKSpriteNode(imageNamed: "Ball")
	var ball:Ball!
	
	//let tray = SKSpriteNode(imageNamed: "Tray")
	var tray:Tray!
	
	let gameOverLabel = SKLabelNode(fontNamed:"Chalkduster")
	
	var moveBallToDirection = SKAction()
	var startBallPosition = CGPoint() // Pocztkowa pozycja piłeczki
	var startTrayPosition = CGPoint() // Początkowa pozycja tacki
	var movementDirection = CGPoint() // Kierynek w którym porusza się piłeczka
	var reflectionAngle = 1
	var move: Bool = true
	var gameIsOver: Bool = false
	
	//var obstacle: Bool = false
	
	var x = CGFloat() // do wyznaczania celu poruszania się
	var y = CGFloat() // do wyznaczania celu poruszania się

	
	
	
	var obstaclesType = Obstacles.nothing
	
	// Collision in SpriteKit
	func didBeginContact(contact: SKPhysicsContact) {
		// this gets calld automaticly when two object begin contact with each other
		
		let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
		
		switch(contactMask) {
		case Obstacles.ball.rawValue | Obstacles.tray.rawValue:
			hitInTray() // Odbija się :) 
			
		default:
			return
		}

	}
	
	func didEndContact(contact: SKPhysicsContact) {
		// this gets calld automaticly when two object end contact with each other
		if (contact.bodyA.categoryBitMask == Obstacles.ball.rawValue &&
			contact.bodyB.categoryBitMask == Obstacles.tray.rawValue)
		{
			print("bodyA is ball and bodyB was tray")
		}
		
	}
	// ---
	
    override func didMoveToView(view: SKView) {
		
		/* Setup veriables */
		//var x: CGFloat = CGRectGetMaxX(frame.self)
		//var y: CGFloat = CGRectGetMaxY(frame.self)
		
        /* Setup your scene here */
		view.showsPhysics = true
		
        gameOverLabel.text = "Game Over :(";
        gameOverLabel.fontSize = 48;
        gameOverLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2);
		
		traySetUp()
		ballSetUp()
		physicsWorld.contactDelegate = self
		
		let panGesture:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveTray:")
		view.addGestureRecognizer(panGesture)
    }
	
	
	// BALL
	func ballSetUp() // Ustawienia piłki
	{
		ball = Ball(imageNamed: "Ball")
		ball.childNodeWithName("ball")
		ball.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)) // początkowa pozycja piłeczki
		startBallPosition = ball.position
		addChild(ball)
		
		// Log
		print("\(ball.position)")
		// ---
		
		}
	
	func letBallMove()
	{
		//myLabel.removeFromParent()
		
		// Wprawić w ruch piłeczkę
		moveBallToDirection = SKAction.moveTo(movementDirection, duration: 2.0)
		ball.runAction(moveBallToDirection)

		ball.runAction(SKAction.repeatActionForever(SKAction.sequence([
			SKAction.runBlock(moveBall),
			SKAction.waitForDuration(0.1)
			])))
		// ---
	}
	
	func moveBall()
	{
		if (ball.position.y /*+ ball.size.height/2*/ <= tray.position.y /*+ tray.size.height*/) // Tray
		{
			obstaclesType = Obstacles.tray
		}
		else if (ball.position.y - ball.size.height/2 <= CGRectGetMinY(self.frame)) // Dół
		{
			obstaclesType = Obstacles.wallBottom
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
			//print("Tray")
			hitInTray()
		case .brick:
			//print("Brick")
			hitInBrick()
		case .nothing:
			move = true
			//print("move: \(move.boolValue)")
			
		default:
			return
		}
	}
	
	func hitInTray()
	{
		if (move)
		{
			print("Tacka")
			
			x = movementDirection.x
			y = movementDirection.y
			
			print("x: \(x), y: \(y)")
			print("ball: \(ball.position.x), y: \(ball.position.y + ball.size.height/2)")
			
			y = CGRectGetMaxY(frame.self)
			x = frame.size.width/2
			
			movementDirection = CGPoint(x: x, y: y)
			
			moveBallToDirection = SKAction.moveTo(movementDirection, duration: 2.0)
			ball.runAction(moveBallToDirection)
			move = false
		}
		
		obstaclesType = Obstacles.nothing
	}
	
	func hitInTop()
	{
		if (move)
		{
			print("Sufit")
			
			x = movementDirection.x
			y = movementDirection.y
			
			y = CGRectGetMinY(frame.self)
			x = frame.size.width/2
			
			movementDirection = CGPoint(x: x, y: y)
			
			moveBallToDirection = SKAction.moveTo(movementDirection, duration: 2.0)
			ball.runAction(moveBallToDirection)
			move = false
		}
		obstaclesType = Obstacles.nothing
	}
	
	func hitInLeftWall()
	{
		if (move)
		{
			print("Lewa ściana")
			
			x = movementDirection.x
			y = movementDirection.y
			movementDirection = CGPoint(x: -x, y: y)
			
			moveBallToDirection = SKAction.moveTo(movementDirection, duration: 2.0)
			ball.runAction(moveBallToDirection)
			move = false
		}
		obstaclesType = Obstacles.nothing
	}
	
	func hitInRightWall()
	{
		if (move)
		{
			print("Prawa ściana")
			x = movementDirection.x
			y = movementDirection.y
			movementDirection = CGPoint(x: -x, y: y)
			
			moveBallToDirection = SKAction.moveTo(movementDirection, duration: 2.0)
			ball.runAction(moveBallToDirection)

			move = false
		}
		obstaclesType = Obstacles.nothing
	}
	func hitInBrick()
	{
		print("Not yet :(")
	}
	
	func hitInBottom()
	{
		gameOver()
	}
	
	// ---


	// TRAY
	func traySetUp()
	{
		startTrayPosition = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame) + 30)
		let pts: String = NSStringFromCGPoint(startTrayPosition)
		
		let solidStay: [String: String] = [	"ImageName": "Tray",
											"Location": pts,
											/*"PlaceMultiplesOnX": "1",*/]
		
		tray = Tray(theDict: solidStay)
		tray.childNodeWithName("tray")
		addChild(tray)
	}
	
	func moveTray(gesture: UIPanGestureRecognizer)
	{
		if (gesture.locationInView(self.view!).x <= tray.position.x/* + tray.size.width/2*/ + 50  && // <-- tacką można poruszać tylko jak palec jest nad nią
			gesture.locationInView(self.view!).x >= tray.position.x /* - tray.size.width/2*/ - 50)
		{
			var translation: CGPoint! = gesture.velocityInView(self.view!)
			translation.x = (translation.x * 0.055) / 2.8  // Przyspieszenie tacki (iPad Mini 1gen)
			
			if (gesture.locationInView(view!).y >= self.frame.size.height/* - tray.size.height * 2*/) // <-- Ograniczenie pola poruszania tacką do dołu ekranu
			{
				if (gesture.velocityInView(view!).x > 0)
				{
					tray.position.x += translation.x
				}
				else if (gesture.velocityInView(view!).x < 0)
				{
					tray.position.x += translation.x
				}
				
				
				if (tray.position.x/* - tray.size.width/2*/ <= 0)
				{
					tray.position.x = 0 /*+ tray.size.width/2*/
				}
				else if (tray.position.x >= self.frame.size.width /* - tray.size.width/2*/)
				{
					tray.position.x = self.frame.size.width /*- tray.size.width/2*/
				}
			}
			self.tray.runAction(SKAction.moveTo(tray.position, duration: 0))
		}
	}
	// ---
	
	func gameOver()
	{
		print("Game Over!")
		self.addChild(gameOverLabel)
		ball.removeAllActions()
		ball.removeFromParent()
		tray.removeAllActions()
		tray.removeFromParent()
		move = false
		gameIsOver = true
		//ballSetUp()
		//traySetUp()
	}
	
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
		
		if (gameIsOver)
		{
			ballSetUp()
			traySetUp()
			gameOverLabel.removeFromParent()
			gameIsOver = false
		}
		else
		{
			//etBallMove()
			//moveBall()
			//move = true
		}
	}
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
