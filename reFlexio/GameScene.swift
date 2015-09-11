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
	var bricksCollections: [SKSpriteNode] = []
	
	var gameOverLabel = SKLabelNode()	//fontNamed:"Chalkduster")
	var restartLabel = SKLabelNode()	// fontNamed:"Chalkduster")
	var winnerLabel = SKLabelNode()		// fontNamed:"Chalkduster")
	var playerName = SKLabelNode()
	var pointListLabel = SKLabelNode()
	
	var bgImage = SKSpriteNode()
	var bgLine = SKSpriteNode()

	
	var lifesLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Light")
	var lifeTitleLabel = SKLabelNode()

	var pointsLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Light")
	var pointsTitleLabel = SKLabelNode()
	var pointsNumberFormatter = NSNumberFormatter()
	var pointsNumber = Int()

	var playingTime = SKLabelNode(fontNamed: "AppleSDGothicNeo-Light")		// fontNamed:"Chalkduster")
	var timeTitleLabel = SKLabelNode()
	var timerNumber = Int()
	var timeNumberFormatter = NSNumberFormatter()
	var timer = NSTimer()
	
	var moveBallToDirection = SKAction()
	var startBallPosition = CGPoint() // Pocztkowa pozycja piłeczki
	var startTrayPosition = CGPoint() // Początkowa pozycja tacki
	var movementDirection = CGPoint() // Kierynek w którym porusza się piłeczka
	var gameIsOver: Bool = false
	var ballIsInMiddleOfMoving: Bool = false
	var stillAChance: Bool = false

	/* Set Up Move */
	var ballSpeed: CGFloat = 3.0
	var ballMoveDirection = String()
	//var lastObjectIsBrick: Bool = false
	var ballMoveFromDirection = String()
	
	
	// Collision in SpriteKit
	var inContactWithOneBrick: Bool = false
	var contactWithBrickName = SKPhysicsBody()
	var lastContactObject = String()

	func didBeginContact(contact: SKPhysicsContact)
	{
		
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
			print("Kostka")
			contactWithBrickName = secondBody
			hitInBrick(contact.contactPoint)
		}
	}
	
	
	
	override func didMoveToView(view: SKView)
	{
		
		
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
		
		
		
		labels("Create")
		
		/* Setup your scene here */
		//self.view!.showsPhysics = true
		self.view!.showsFPS = true
		self.view!.showsNodeCount = true
		
		traySetUp()
		ballSetUp()
		brickSetUp()
		//winGame()
		
		

		physicsWorld.gravity = CGVectorMake(0, 0)
		physicsWorld.contactDelegate = self
		
		let panGesture:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveTray:")
		view.addGestureRecognizer(panGesture)
	}
	
	func labels(operation: String)
	{
		if operation == "Create"
		{
			/* Background && Top Line*/
			bgLine = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(self.frame.size.width, 1))
			bgLine.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 60)
			bgLine.name = "TopLine"
			addChild(bgLine)
			
			bgImage = SKSpriteNode(imageNamed: "Background")
			bgImage.position = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2)
			bgImage.name = "Background"
			bgImage.zPosition = -1.0
			addChild(bgImage)
			
			/* Point's Label */
			pointsTitleLabel.name = "PointsTitleLabel"
			pointsTitleLabel.text = "Points"
			pointsTitleLabel.fontSize = 18.0
			//print(UIFontWeightThin.description)
			pointsTitleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
			pointsTitleLabel.position = CGPointMake(CGRectGetMaxX(self.frame) - (pointsTitleLabel.frame.size.height + 40.0), CGRectGetMaxY(self.frame) - 25.0)
			self.addChild(pointsTitleLabel)
			
			pointsNumberFormatter.minimumIntegerDigits = 6
			pointsNumber = 0
			pointsLabel.text = "\(pointsNumberFormatter.stringFromNumber(pointsNumber)!)"
			pointsLabel.name = "PointsLabel"
			//pointsLabel.fontSize = 38 // iPad Mini 1
			pointsLabel.fontSize = 22.0 // iPhone 5
			pointsLabel.position = CGPointMake(CGRectGetMaxX(self.frame) - (pointsLabel.frame.size.width + 13.0), CGRectGetMaxY(self.frame) - 48.0);
			pointsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
			self.addChild(pointsLabel)
			
			/* Life Label */
			lifeTitleLabel.name = "LifeTitleLabel"
			lifeTitleLabel.text = "Life"
			lifeTitleLabel.fontSize = 18.0 // for system font
			lifeTitleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
			lifeTitleLabel.position = CGPointMake(CGRectGetMidX(self.frame) - 3.0, CGRectGetMaxY(self.frame) - 25.0)
			self.addChild(lifeTitleLabel)
			
			lifesLabel.name = "LifeLabel"
			lifesLabel.text = "🏈🏈🏈"
			//lifesLabel.fontSize = 38 // iPad Mini 1
			lifesLabel.fontSize = 18.0 // iPhone 5
			lifesLabel.position = CGPointMake(CGRectGetMidX(self.frame) - lifesLabel.frame.size.width/2.0 - 7.0, CGRectGetMaxY(self.frame) - 48.0)
			lifesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
			self.addChild(lifesLabel)
			
			/* Play Time Label */
			timeTitleLabel.name = "timeTitleLabel"
			timeTitleLabel.text = "Time"
			timeTitleLabel.fontSize = 18.0 // for system font
			timeTitleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
			timeTitleLabel.position = CGPointMake(CGRectGetMinX(self.frame) + 44.0, CGRectGetMaxY(self.frame) - 25.0)
			self.addChild(timeTitleLabel)
			
			timeNumberFormatter.minimumIntegerDigits = 5
			timerNumber = 0
			playingTime.text = "\(timeNumberFormatter.stringFromNumber(timerNumber)!)"
			playingTime.name = "PlayTimeLabel"
			playingTime.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
			//playingTime.fontSize = 38 // iPad Mini 1
			playingTime.fontSize = 22.0 // iPhone 5
			playingTime.position = CGPointMake(CGRectGetMinX(self.frame) + 13.0, CGRectGetMaxY(self.frame) - 48.0)
			self.addChild(playingTime)
		}
		else if (operation == "Create_Win")
		{
			winnerLabel.childNodeWithName("WINNER!!")
			winnerLabel.text = "WINNER !!"
			winnerLabel.fontSize = 36
			winnerLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/1.5);
			addChild(winnerLabel)
			
			
			playerName.text = "Name :" // Create Label for player to craet name
			playerName.position = CGPoint(x: winnerLabel.position.x - winnerLabel.position.x/4, y: winnerLabel.position.y - winnerLabel.position.y/4)
			playerName.fontSize = 22
			addChild(playerName)
			
			pointListLabel.text = "\(pointsLabel.text!)"
			pointListLabel.fontSize = 22
			pointListLabel.position = CGPoint(x: winnerLabel.position.x + winnerLabel.position.x/5 , y: winnerLabel.position.y - winnerLabel.position.y/4)
			addChild(pointListLabel)
		}
		else if (operation == "Remove")
		{
			timer.invalidate()
			playingTime.text = "\(timeNumberFormatter.stringFromNumber(timerNumber)!)"
			
			playingTime.removeFromParent()
			timeTitleLabel.removeFromParent()
			
			pointsLabel.removeFromParent()
			pointsTitleLabel.removeFromParent()
			
			lifesLabel.removeFromParent()
			lifeTitleLabel.removeFromParent()
			
			bgLine.removeFromParent()
		}
		else if (operation == "Restart_GameOver")
		{
			gameOverLabel.removeFromParent()
			winnerLabel.removeFromParent()
		}
		else if (operation == "Restart_Chance")
		{
			restartLabel.removeFromParent()
		}
	}
	
	func counter()
	{
		playingTime.text = "\(timeNumberFormatter.stringFromNumber(timerNumber++)!)"
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
		//print("hitInTray")
		lastContactObject = "tray"
		
		if (ballMoveDirection == "Down_Left")
		{
			moveBall(ballSpeed, direction: "Up_Left")
			ballMoveFromDirection = "Down_Right"
		}
		else if  (ballMoveDirection == "Down_Right")
		{
			moveBall(ballSpeed, direction: "Up_Right")
			ballMoveFromDirection = "Down_Left"
		}
		else
		{
			var directionsArray = ["Up_Right"] //, "Up_Left"] // , "Up"]
			ballMoveFromDirection = "Down_Left"
			let i = Int(arc4random_uniform(UInt32(directionsArray.count)))
			let randomDirection = String(directionsArray[i])
			moveBall(ballSpeed, direction: randomDirection)
		}
		
		pointsLabel.text = "\(pointsNumberFormatter.stringFromNumber(pointsNumber++)!)"
	}
	
	func hitInTop()
	{
		//print("hitInTop")
		
		lastContactObject = "Top"
		
		if (ballMoveDirection == "Up_Left")
		{
			moveBall(ballSpeed, direction: "Down_Left")
			ballMoveFromDirection = "Top_Right" // potrzebne do odbicia pilki od górnej krawędzi kostki
		}
		else if (ballMoveDirection == "Up_Right")
		{
			moveBall(ballSpeed, direction: "Down_Right")
			ballMoveFromDirection = "Top_Left" // potrzebne do odbicia pilki od górnej krawędzi kostki
		}
		else
		{
			moveBall(ballSpeed, direction: "Down")
		}
	}
	
	func hitInLeftWall()
	{
		
		//print("hitInLeftWall")
		lastContactObject = "leftWall"
		
		if (ballMoveDirection == "Down_Left")
		{
			moveBall(ballSpeed, direction: "Down_Right")
			ballMoveFromDirection = "Up_Left"
		}
		else if (ballMoveDirection == "Up_Left")
		{
			moveBall(ballSpeed, direction: "Up_Right")
			ballMoveFromDirection = "Down_Left"
		}
	}
	
	func hitInRightWall()
	{
		//print("hitInRightWall")
		lastContactObject = "rightWall"

		if (ballMoveDirection == "Down_Right")
		{
			moveBall(ballSpeed, direction: "Down_Left")
			ballMoveFromDirection = "Up_Right"
		}
		else if (ballMoveDirection == "Up_Right")
		{
			moveBall(ballSpeed, direction: "Up_Left")
			ballMoveFromDirection = "Down_Right"
		}
	}
	
	
	func hitInBrick(contactPoint: CGPoint)
	{
		if (contactPoint.y >= ((contactWithBrickName.node?.position.y)! + brick.size.height/2 - 2) ||
			contactPoint.y <= ((contactWithBrickName.node?.position.y)! - brick.size.height/2 + 2))
		{
			if (contactPoint.y > (contactWithBrickName.node?.position.y)!)
			{
				print("Góra")
				
				if (ballMoveDirection == "Down_Left")
				{
					moveBall(ballSpeed, direction: "Up_Left")
					inContactWithOneBrick = false
				}
				else if (ballMoveDirection == "Down_Right")
				{
					moveBall(ballSpeed, direction: "Up_Right")
					inContactWithOneBrick = false
				}
			}
			else
			{
				print("Dół")
				
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
			}
		}
		else if (contactPoint.x >= ((contactWithBrickName.node?.position.x)! + brick.size.width/2 - 2) ||
				contactPoint.x <= ((contactWithBrickName.node?.position.x)! - brick.size.width/2 + 2))
		{
			if (contactPoint.x > (contactWithBrickName.node?.position.x)!)
			{
				print("Prawy bok")
				
				if (ballMoveDirection == "Up_Left")
				{
					moveBall(ballSpeed, direction: "Up_Right")
					inContactWithOneBrick = false
				}
				else if (ballMoveDirection == "Down_Left")
				{
					moveBall(ballSpeed, direction: "Down_Right")
					inContactWithOneBrick = false
				}
			}
			else
			{
				print("Lewy bok")
				
				if (ballMoveDirection == "Up_Right")
				{
					moveBall(ballSpeed, direction: "Up_Left")
					inContactWithOneBrick = false
				}
				else if (ballMoveDirection == "Down_Right")
				{
					moveBall(ballSpeed, direction: "Down_Left")
					inContactWithOneBrick = false
				}
			}
		}

		pointsNumber += 50
		pointsLabel.text = "\(pointsNumberFormatter.stringFromNumber(pointsNumber)!)"
		
		contactWithBrickName.node?.removeFromParent()
		
		
		if bricksArray.contains((contactWithBrickName.node?.name)!)
		{
			bricksArray.removeAtIndex(bricksArray.indexOf((contactWithBrickName.node?.name)!)!)
			
			
			if (bricksArray.count == 0)
			{
				// TODO:  Koniec gry! Napis, usuwanie piłki i tacki. Zapis punktów do pamięci(pliku/chmura?), wyświetlenie tablicy z najlepszymi.
				print("You Win!!")
				winGame()
			}
		}
	}
	
	func hitInBottom()
	{
		//var strLenght = distance(lifesLabel.text!.startIndex, lifesLabel.text!.endIndex) // Swift 1.2
		
		//hitInTray()
		
		
		if (lifesLabel.text!.characters.count >= 2)
		{
			var str = lifesLabel.text!
			str.removeAtIndex(str.endIndex.predecessor())
			lifesLabel.text = str
			
			ball.removeAllActions()
			ball.removeFromParent()
			tray.removeAllActions()
			tray.removeFromParent()
			
			restartLabel.text = "Tap to Restart";
			restartLabel.fontSize = 36;
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
			gameOverLabel.fontSize = 36;
			gameOverLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2);
			
			labels("Remove")
			
			// TODO: Usunąc wszystkie kostki przy GameOver!
			for brick in bricksCollections {
				brick.removeFromParent()
			}
			
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
		//let brickSize = SKTexture(imageNamed: "Brick_Green)").size
		let brickSize = UIImage(named: "Brick_Green")?.size

		let bricksNumber: NSInteger = 3 // 0 just for testing
		let brickRowNumber: NSInteger = 3
		print("brickRowNumber: \(brickRowNumber)")
		let c = bricksNumber
		let r = brickRowNumber
 		let spaceBetwenBricks: CGSize = CGSizeMake(15, -78)

		
		let baseOrigin: CGPoint = CGPointMake(CGRectGetMidX(self.frame) - 70 - spaceBetwenBricks.width,CGRectGetMaxY(self.frame) - 160) // powinno byś 140
		
		

		for (var row = 0; row < r; row++)
		{
			let strTemp: String = "brick\(row)"
			
			var brickPosition: CGPoint = CGPointMake(baseOrigin.x, CGFloat(row) * ((brickSize!.height)) + baseOrigin.y)
			
			for (var col = 0; col < c; col++)
			{
				
				brick = Brick(imageNamed: "Brick_Green")
				
				let str = "\(strTemp)\(col)"
				self.brick.name = str
				
				
				self.brick.position.x = brickPosition.x
				self.brick.position.y = brickPosition.y
				
				addChild(brick)
				
				bricksArray.append(str)
				bricksCollections.append(brick)
				
				brickPosition.x += self.brick.size.width + spaceBetwenBricks.width // brickPosition.x - self.frame.width/4
				
			}
		}
	}
	// ---
	
	// TRAY
	func traySetUp()
	{
		startTrayPosition = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame) + 70)
		tray = Tray(imageNamed: "Tray")
		tray.position = startTrayPosition
		
		print(tray.position.y)
		addChild(tray)
	}
	
	func moveTray(gesture: UIPanGestureRecognizer)
	{
		if (gesture.locationInView(self.view!).x <= tray.position.x + tray.size.width/1.3 && // <-- tacką można poruszać tylko jak palec jest nad nią
			gesture.locationInView(self.view!).x >= tray.position.x - tray.size.width/1.3)
		{
			var translation: CGPoint! = gesture.velocityInView(self.view!)
			translation.x = (translation.x * 0.07) / 2.5		// Przyspieszenie tacki iPhone 5 (4")
			//translation.x = (translation.x * 0.055) / 2.8		// Przyspieszenie tacki (iPad Mini 1gen)
			//translation.x = (translation.x * 0.113) / 2.8		// Przyspieszenie tacki (iPhone 6 Symulatot)
			
			if (gesture.locationInView(self.view!).y >= self.frame.size.height - tray.size.height * 5) // <-- Ograniczenie pola poruszania tacką do dołu ekranu
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
	
	func winGame()
	{
		print("WINNER!")
		gameIsOver = true
		
		labels("Create_Win")
		
		
		// Clear display and labels
		labels("Remove")
		
		ball.removeAllActions()
		ball.removeFromParent()
		tray.removeAllActions()
		tray.removeFromParent()
		
		stillAChance = false
		ballIsInMiddleOfMoving = false
	}
	
	//	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) { // Swift 1.2
		override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) { // Swift 2.0
	
		/* Called when a touch begins */
		if (gameIsOver)
		{
			ballSetUp()
			traySetUp()
			brickSetUp()
			
			labels("Restart_GameOver")
			labels("Create")
		
			gameIsOver = false
			stillAChance = false
			ballIsInMiddleOfMoving = false
		}
		else if (stillAChance)
		{
			labels("Restart_Chance")
			
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
				
				//print("ball x: \(ball.position.x)")
				//print("ball y: \(ball.position.y)")
			}
		}
	}
}