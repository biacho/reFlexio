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
    }
	
	func ballSetUp() // Ustawienia piłki
	{
		ball.xScale = 0.3
		ball.yScale = 0.3
		movementDirection = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame)) // początkowy kierunek ruchu piłeczki
		startBallPosition = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
		ball.position = startBallPosition
		self.addChild(ball)
		
		// Log
		println("\(ball.position)")
		// ---
		
		}
	
	func traySetUp()
	{
		tray.size.height = 30
		tray.size.width = 120
		startTrayPosition = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame) + tray.size.height)
		tray.position = startTrayPosition
		self.addChild(tray)
	}
	
	
	
	func letBallMove()
	{
		// Log
		println("letBallMove()")
		// ---
		
		// Wprawić w ruch piłeczkę
		ball.runAction(SKAction.repeatActionForever(SKAction.sequence([
			SKAction.runBlock(moveBall),
			SKAction.waitForDuration(0)
			])))
		// ---
	}
	
	func moveBall()
	{
		// Log
		//println("\(movementDirection)")
		//println("\(ball.position)")
		// ---
		
		if (!move) // realod
		{
			let moveBall = SKAction.moveTo(movementDirection, duration: 4)
			ball.runAction(moveBall)
			move = true
		}
		else
		{
			if (ball.position.y - ball.size.height/2 <= tray.frame.origin.y + tray.size.height)
			{
				if (ball.position.x <= tray.frame.origin.x || ball.position.x >= tray.frame.size.width)
				{
					println("Zief")
					println("\(ball.position)")
					println("\(tray.frame.origin.y - tray.size.height/2), \(tray.size.height), \(tray.frame.size.height)")
					
					movementDirection = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMaxY(self.frame))
					move = false
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
			else if (ball.position.y + ball.size.height/2 >= CGRectGetMaxY(self.frame))
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
	
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
		letBallMove()
	}
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
