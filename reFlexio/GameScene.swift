//
//  GameScene.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 11/06/15.
//  Copyright (c) 2015 Biacho. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
	
	let ball = SKSpriteNode(imageNamed: "Ball")
	let tray = SKSpriteNode(imageNamed: "Tray")
	var startBallPosition = CGPoint() // Pocztkowa pozycja piłeczki
	var startTrayPosition = CGPoint() // Początkowa pozycja tacki
	var movementDirection = CGPoint() // Kierynek w którym porusza się piłeczka
	var reflectionAngle = 1
	var move = Bool(false)
	
    override func didMoveToView(view: SKView) {
		
        /* Setup your scene here */
		let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "reFlexio";
        myLabel.fontSize = 48;
        myLabel.position = CGPoint(x: size.width, y: size.height);
		
		traySetUp()
		ballSetUp()

		self.addChild(myLabel)
		
		let panGesture:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveTray:")
		view.addGestureRecognizer(panGesture)
    }
	
	
	// BALL
	func ballSetUp() // Ustawienia piłki
	{
		ball.xScale = 0.3
		ball.yScale = 0.3
		movementDirection = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame)) // początkowy kierunek ruchu piłeczki
		startBallPosition = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)) // początkowa pozycja piłeczki
		ball.position = startBallPosition
		self.addChild(ball)
		
		// Log
		println("\(ball.position)")
		// ---
		
		}
	
	func letBallMove()
	{
		// Wprawić w ruch piłeczkę
		ball.runAction(SKAction.repeatActionForever(SKAction.sequence([
			SKAction.runBlock(moveBall),
			SKAction.waitForDuration(0)
			])))
		// ---
	}
	
	func moveBall()
	{
		if (!move) // realod
		{
			let moveBall = SKAction.moveTo(movementDirection, duration: 4.0)
			ball.runAction(moveBall)
			move = true
		}
		else
		{
			// TODO: Zaimplementować pozycje tacki przy odbiciu piłeczki
			if (ball.position.y - ball.size.height/2 <= tray.position.y + tray.size.height) // Tacka
			{
				if (ball.position.x >= tray.position.x - tray.size.width/2 || ball.position.x <= tray.position.x + tray.size.width)
				{
					switch reflectionAngle
					{
					case 0:
						movementDirection = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMaxY(self.frame))
						move = false
					case 1:
						movementDirection = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMaxY(self.frame))
						move = false
					default:
						println("Default")
					}
				}
			}
			else if (ball.position.y - ball.size.height/2 <= CGRectGetMinY(self.frame)) // Dół
			{
				println("Game Over!")
				ball.removeAllActions()
				ball.removeFromParent()
				move = false
				ballSetUp()
			}
			else if (ball.position.y + ball.size.height/2 >= CGRectGetMaxY(self.frame)) // Góra
			{
				movementDirection = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame))
				move = false
			}
			else
			{
				//println("Position: \(ball.position)")
			}
			
		}
	}
	// ---
	
	
	// TRAY
	func traySetUp()
	{
		tray.size.height = 30
		tray.size.width = 120
		startTrayPosition = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame) + tray.size.height)
		tray.position = startTrayPosition
		self.addChild(tray)
	}
	
	func moveTray(gesture: UIPanGestureRecognizer)
	{
		
		let velocity = gesture.velocityInView(view!)
		let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
		let slideMultiplier = magnitude / 20
		
		//let speed: CGFloat = abs(20)
		let speed = gesture.velocityInView(view!).x * 0.05
		
		if (gesture.locationInView(view!).y >= self.frame.size.height - tray.size.height * 1.5) // <-- Ograniczenie pola poruszania tacką do dołu ekranu
		{
			println("translation: \(gesture.translationInView(view!))")
			println("location: \(gesture.locationInView(view!))")
			//println("tray: \(tray.position.x)")
			println("tray: \(gesture.velocityInView(view!).x)")

			if (gesture.velocityInView(view!).x > 0)
			{
				if ((tray.position.x + tray.size.width/2) < self.frame.size.width)
				{
					self.tray.runAction(SKAction.moveToX(tray.position.x + slideMultiplier, duration: 0))
				}
			}
			else if (gesture.velocityInView(view!).x < 0)
			{
				if ((tray.position.x - tray.size.width/2) > 0)
				{
					self.tray.runAction(SKAction.moveToX(tray.position.x - slideMultiplier, duration: 0))
				}
			}
		}
	}
	
	// ---
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
		letBallMove()
	}
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
