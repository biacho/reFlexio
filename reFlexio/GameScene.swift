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
	
	var brick:Brick!
	var bricksArray: [String] = []
	
	let gameOverLabel = SKLabelNode(fontNamed:"Chalkduster")
	var restartLabel = SKLabelNode(fontNamed:"Chalkduster")

	var pointsLabel = SKLabelNode(fontNamed:"Chalkduster")
	var pointsNumberFormatter = NSNumberFormatter()
	var pointsNumber = Int()
	
	var lifesLabel = SKLabelNode()
	
	var playingTime = SKLabelNode(fontNamed:"Chalkduster")
	var timerNumber = Int()
	var timer = NSTimer()
	
	var moveBallToDirection = SKAction()
	var startBallPosition = CGPoint() // Pocztkowa pozycja piłeczki
	var startTrayPosition = CGPoint() // Początkowa pozycja tacki
	var movementDirection = CGPoint() // Kierynek w którym porusza się piłeczka
	var gameIsOver: Bool = false
	var ballIsInMiddleOfMoving: Bool = false
	var stillAChance: Bool = false


	/* Set Up Move */
	var ballSpeed: CGFloat = 5.0
	var ballMoveDirection = String()
	
	// Collision in SpriteKit
	var inContactWithOneBrick: Bool = false

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
		else if (secondBody.categoryBitMask == 7)
		{
			if (!inContactWithOneBrick)
			{
				inContactWithOneBrick = true
				hitInBrick()
				secondBody.node?.removeFromParent()
			}
		}
	}
	
	
	
	override func didMoveToView(view: SKView) {
		
		
		/* Background && Top Line*/
		let bgImage = SKSpriteNode(imageNamed: "Background")
		bgImage.position = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2)
		bgImage.name = "Background"
		
		let bgLine = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(self.frame.size.width, 1))
		bgLine.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 60)
		bgLine.name = "TopLine"
		
		addChild(bgImage)
		addChild(bgLine)
		
		
		
		/* Setup veriables */
		let sizeWallTop: CGSize = CGSizeMake(self.size.width, 1)
		let locationWallTop: CGPoint = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 60)
		
		let sizeWallBottom: CGSize = CGSizeMake(self.size.width, 1)
		let locationWallBottom: CGPoint = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame))
		
		let sizeWallLeft: CGSize = CGSizeMake(1, self.size.height - 60)
		let locationWallLeft: CGPoint = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMidY(self.frame) - 30)
		
		let sizeWallRight: CGSize = CGSizeMake(1, self.size.height - 60)
		let locationWallRight: CGPoint = CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMidY(self.frame) - 30)
		
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
		
		/* Point's Label */
		pointsNumberFormatter.minimumIntegerDigits = 5
		pointsNumber = 0
		pointsLabel.text = "\(pointsNumberFormatter.stringFromNumber(pointsNumber)!)"
		pointsLabel.name = "PointsLabel"
		pointsLabel.fontSize = 38
		pointsLabel.position = CGPointMake(CGRectGetMaxX(self.frame) - (pointsLabel.frame.size.width + 20), CGRectGetMaxY(self.frame) - 45);
		pointsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
		self.addChild(pointsLabel)
		
		/* Life Label */
		lifesLabel.name = "LifeLabel"
		lifesLabel.text = "🏈🏈🏈"
		lifesLabel.fontSize = 38
		lifesLabel.position = CGPointMake(CGRectGetMidX(self.frame) - lifesLabel.frame.size.width/2, CGRectGetMaxY(self.frame) - 45)
		lifesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
		self.addChild(lifesLabel)
		
		/* Play Time Label */
		timerNumber = 0
		playingTime.text = "Time: \(timerNumber)"
		pointsLabel.name = "PlayTimeLabel"
		playingTime.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
		playingTime.fontSize = 38
		playingTime.position = CGPointMake(CGRectGetMinX(self.frame) + 15, CGRectGetMaxY(self.frame) - 45);
		self.addChild(playingTime)
		
		/* Setup your scene here */
		//self.view!.showsPhysics = true
		self.view!.showsFPS = true
		self.view!.showsNodeCount = true
		
		traySetUp()
		ballSetUp()
		brickSetUp()
		
		physicsWorld.gravity = CGVectorMake(0, 0)
		physicsWorld.contactDelegate = self
		
		let panGesture:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveTray:")
		view.addGestureRecognizer(panGesture)
	}
	
	
	func counter()
	{
		playingTime.text = "Time: \(timerNumber++)"
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
			moveBallToDirection = SKAction.moveBy(CGVectorMake(-1*ballSpeed, 1*ballSpeed), duration: 0.001)
		}
		else if (direction == "Up_Right")
		{
			moveBallToDirection = SKAction.moveBy(CGVectorMake(1*ballSpeed, 1*ballSpeed), duration: 0.001)
		}
		else if (direction == "Down_Left")
		{
			moveBallToDirection = SKAction.moveBy(CGVectorMake(-1*ballSpeed, -1*ballSpeed), duration: 0.001)
		}
		else if (direction == "Down_Right")
		{
			moveBallToDirection = SKAction.moveBy(CGVectorMake(1*ballSpeed, -1*ballSpeed), duration: 0.001)
		}
		else if (direction == "Down")
		{
			moveBallToDirection = SKAction.moveBy(CGVectorMake(0, -1*ballSpeed), duration: 0.001)
		}
		else if (direction == "Up")
		{
			moveBallToDirection = SKAction.moveBy(CGVectorMake(0, 1*ballSpeed), duration: 0.001)
		}
		else if (direction == "Stop")
		{
			moveBallToDirection = SKAction.moveBy(CGVectorMake(0, 0), duration: 0.001)
		}
		
		ballMoveDirection = direction
		ball.runAction(moveBallToDirection)
	}
	
	func hitInTray()
	{
		print("hitInTray")
		
		if (ballMoveDirection == "Down_Left")
		{
			moveBall(ballSpeed, direction: "Up_Left")
		}
		else if  (ballMoveDirection == "Down_Right")
		{
			moveBall(ballSpeed, direction: "Up_Right")
		}
		else
		{
			var directionsArray = ["Up_Right", "Up_Left"] // , "Up"]
			let i = Int(arc4random_uniform(UInt32(directionsArray.count)))
			let randomDirection = String(directionsArray[i])
			moveBall(ballSpeed, direction: randomDirection)
		}
		
		pointsLabel.text = "\(pointsNumberFormatter.stringFromNumber(pointsNumber++)!)"
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
	}
	
	func hitInRightWall()
	{
		print("hitInRightWall")

		if (ballMoveDirection == "Down_Right")
		{
			moveBall(ballSpeed, direction: "Down_Left")
		}
		else
		{
			moveBall(ballSpeed, direction: "Up_Left")
		}
	}
	
	func hitInBrick()
	{
		// TODO: Dodać odbicie z boku i od góry
		
		// Odbicie z gołu
		if (ballMoveDirection == "Up_Left")
		{
			moveBall(ballSpeed, direction: "Down_Left")
			inContactWithOneBrick = false
		}
		else if (ballMoveDirection == "Up_Right")
		{
			moveBall(ballSpeed, direction: "Down_Right")
			inContactWithOneBrick = false
		}
		// Odbicie z Góry
		else if (ballMoveDirection == "Down_Left")
		{
			moveBall(ballSpeed, direction: "Up_Left")
			inContactWithOneBrick = false
		}
		else if (ballMoveDirection == "Down_Right")
		{
			moveBall(ballSpeed, direction: "Up_Right")
			inContactWithOneBrick = false
		}
		// Odbicie z lewej
		else if (ballMoveDirection == "Up_Right")
		{
			moveBall(ballSpeed, direction: "Up_Left")
			inContactWithOneBrick = false
		}
		else if (ballMoveDirection == "Down_Right")
		{
			moveBall(ballSpeed, direction: "Down_Left")
			inContactWithOneBrick = false
		}
		// Odbicie z prawej
		else if (ballMoveDirection == "Up_Left")
		{
			moveBall(ballSpeed, direction: "Up_Right")
			inContactWithOneBrick = false
		}
		else if (ballMoveDirection == "Down_Left")
		{
			moveBall(ballSpeed, direction: "Down_Right")
			inContactWithOneBrick = false
		}
		else
		{
			moveBall(ballSpeed, direction: "Down")
			inContactWithOneBrick = false
		}
		
		pointsNumber += 50
		pointsLabel.text = "\(pointsNumberFormatter.stringFromNumber(pointsNumber)!)"
		
		if (bricksArray.count == 0)
		{
			// TODO:  Koniec gry! Napisa, usuwanie piłki i tacki. Zapis punktów do pamięci(pliku/chmura?), wyświetlenie tablicy z najlepszymi.
			print("You Win!!")
		}
	}
	
	func hitInBottom()
	{
		if (lifesLabel.text?.characters.count >= 2)
		{
			var str = lifesLabel.text!
			str.removeAtIndex(str.endIndex.predecessor())
			lifesLabel.text = str
			
			ball.removeAllActions()
			ball.removeFromParent()
			tray.removeAllActions()
			tray.removeFromParent()
			
			restartLabel.text = "Tap to Restart";
			restartLabel.fontSize = 48;
			restartLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2);
			addChild(restartLabel)
			
			ballIsInMiddleOfMoving = false
			stillAChance = true
		}
		else
		{
			print("Game Over")
			gameOverLabel.childNodeWithName("GameOver")
			gameOverLabel.text = "Game Over :(";
			gameOverLabel.fontSize = 48;
			gameOverLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2);
			pointsNumber = 0
			timer.invalidate()
			timerNumber = 0
			playingTime.text = "Time: 0"
			playingTime.removeFromParent()
			pointsLabel.removeFromParent()
			lifesLabel.removeFromParent()
			addChild(gameOverLabel)
			
			ball.removeAllActions()
			ball.removeFromParent()
			tray.removeAllActions()
			tray.removeFromParent()
			
			gameIsOver = true
			stillAChance = false
			ballIsInMiddleOfMoving = false
		}
	}
	
	// ---
	
	// BRICK
	func brickSetUp()
	{
		
		// Stowrzyć tablice z nazwami danej kostki, i dodawać do niej nazwe nowo stworzonej kostki przy jej tworzeniu, a potem przy niszczeniu usuwać. TAk będzie można policzyć ile kostek jest na planszy i czuwać nad tym czy są jeszcze jakieś czy nie. Tablica pusta znaczy, że zdjeliśmy wszystkie kostki i można kończyć grę.
		let brickSize = SKTexture(imageNamed: "Brick_Green_v2)").size().height
		print("\(brickSize)")
		
		let bricksNumber: NSInteger = 5
		let brickRowNumber: NSInteger = 5
		let c = bricksNumber
		let r = brickRowNumber
 		let spaceBetwenBricks: CGSize = CGSizeMake(20, -108)
		
		let baseOrigin: CGPoint = CGPointMake(brickSize + 14, CGRectGetMaxY(self.frame) - 300)

		for (var row = 0; row < r; row++)
		{
			let strTemp: String = "brick\(row)"
			
			var brickPosition: CGPoint = CGPointMake(baseOrigin.x, CGFloat(row) * (brickSize/3) + baseOrigin.y)
			
			for (var col = 0; col < c; col++)
			{
				brick = Brick(imageNamed: "Brick_Green_v2")
				
				let str = "\(strTemp)\(col)"
				self.brick.name = str
				
				self.brick.position.x = brickPosition.x
				self.brick.position.y = brickPosition.y
				
				print("Create brick nr. \(col)")
				print("Created brick description: \(self.brick.description)")
				
				addChild(brick)
				
				bricksArray.append(str)
				print("\(bricksArray.count)")
				brickPosition.x += self.brick.size.width + spaceBetwenBricks.width // brickPosition.x - self.frame.width/4
			}
		}
		
		print("brick size: \(self.brick.size)")
	}
	// ---
	
	// TRAY
	func traySetUp()
	{
		startTrayPosition = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame) + 70)
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
			translation.x = (translation.x * 0.055) / 2.8		// Przyspieszenie tacki (iPad Mini 1gen)
			//translation.x = (translation.x * 0.113) / 2.8		// Przyspieszenie tacki (iPhone 6 Symulatot)
			
			if (gesture.locationInView(self.view!).y >= self.frame.size.height - tray.size.height * 2) // <-- Ograniczenie pola poruszania tacką do dołu ekranu
			{
				if (gesture.velocityInView(self.view!).x > 0)
				{
					tray.position.x += translation.x
				}
				else if (gesture.velocityInView(self.view!).x < 0)
				{
					tray.position.x += translation.x
				}
				
				if (tray.position.x - tray.size.width/2 <= 1)
				{
					tray.position.x = 1 + tray.size.width/2 // Musi być 1 bo przy wartości 0, tacka zatrzymująca się na ścianie powoduje odbicie piłki, nie wiem czemu tak jest
				}
				else if (tray.position.x >= self.frame.size.width - tray.size.width/2)
				{
					tray.position.x = self.frame.size.width - 1 - tray.size.width/2
				}
			}
		}
		
		tray.runAction(SKAction.moveTo(tray.position, duration: 0))
	}
	// ---
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		/* Called when a touch begins */
		if (gameIsOver)
		{
			ballSetUp()
			traySetUp()
			brickSetUp()
			
			pointsLabel.text = "\(pointsNumberFormatter.stringFromNumber(pointsNumber)!)"
			self.addChild(pointsLabel)
			
			playingTime.text = "Time: \(timerNumber)"
			self.addChild(playingTime)
			
			lifesLabel.text = "🏈🏈🏈"
			self.addChild(lifesLabel)
			
			gameOverLabel.removeFromParent()
			gameIsOver = false
			stillAChance = false
			ballIsInMiddleOfMoving = false
		}
		else if (stillAChance)
		{
			restartLabel.removeFromParent()
			
			ballSetUp()
			traySetUp()
			stillAChance = false
			
			moveBall(ballSpeed, direction:"Down")
			ballIsInMiddleOfMoving = true
		}
		else
		{
			if (!ballIsInMiddleOfMoving)
			{
				if (!timer.valid)
				{
					timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("counter"), userInfo: nil, repeats: true)
				}
				
				moveBall(ballSpeed, direction:"Down")
				ballIsInMiddleOfMoving = true
			}
		}
	}
	
	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
		if (!gameIsOver)
		{
			if (ballIsInMiddleOfMoving)
			{
				moveBall(ballSpeed,direction: ballMoveDirection)
			}
		}
	}
}