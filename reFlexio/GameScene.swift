//
//  GameScene.swift
//  reFlexio
//
//  Created by Tobiasz Czelakowski on 11/06/15.
//  Copyright (c) 2015 Biacho. All rights reserved.
//

import SpriteKit

// For collision purpose

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

protocol GameSceneDelegate {
	func gameOver()
	func isScoreIsOnScreen() -> Bool
}

extension String {
	func toBool() -> Bool? {
		switch self {
		case "True", "true", "yes", "1":
			return true
		case "False", "false", "no", "0":
			return false
		default:
			return nil
		}
	}
}

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	/* Delegate */
	var gameSceneDelegate: GameSceneDelegate?
	
	/* Language in Game */
	let defaults = NSUserDefaults.standardUserDefaults()
	
	/* Model's & Node's */
	var ball:Ball!
	var tray:Tray!
	var wall:Walls!
	var brick:Brick!
	
	var bricksArray: [String] = []
	var bricksCollections: [SKSpriteNode] = []
	
	var gameOverLabel = SKLabelNode()
	var restartLabel = SKLabelNode()
	var winnerLabel = SKLabelNode()
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

	var playingTime = SKLabelNode(fontNamed: "AppleSDGothicNeo-Light")
	var timeTitleLabel = SKLabelNode()
	var timerNumber = Int()
	var timeNumberFormatter = NSNumberFormatter()
	var timer = NSTimer()
	
	var startBallPosition = CGPoint()
	var startTrayPosition = CGPoint()
	var movementDirection = CGPoint()
	var gameIsOver: Bool = false
    var restart: Bool = false
	var gameWasPaused: Bool = false
	var ballIsInMiddleOfMoving: Bool = false
	var stillAChance: Bool = false

	/* Set Up Move */
	var move = SKAction()
	let path: CGMutablePathRef = CGPathCreateMutable()
	
	var ballMoveDirection = String()
	var ballMoveDirectionTemp = String()
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
			bounce("tray", contactPoint: contact.contactPoint)
		}
		else if (secondBody.categoryBitMask == 3)
		{
			bounce("bottom", contactPoint: contact.contactPoint)
		}
		else if (secondBody.categoryBitMask == 4)
		{
			bounce("top", contactPoint: contact.contactPoint)
		}
		else if (secondBody.categoryBitMask == 5)
		{
			bounce("left", contactPoint: contact.contactPoint)
		}
		else if (secondBody.categoryBitMask == 6)
		{
			bounce("right", contactPoint: contact.contactPoint)
		}
		else if (secondBody.categoryBitMask == 7)
		{
            contactWithBrickName = secondBody
            bounce("brick", contactPoint: contact.contactPoint)
        }
	}
	
	
	/* UI && View Config */
	override func didMoveToView(view: SKView)
	{
		
		/* Notifications setUp */
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.menuInGameShow), name: "showMenu", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.menuInGameHide), name: "hideMenu", object: nil)
		//NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector(GameScene.hidePlayerNameView), name: "hidePlayerNameView", object: nil)


		
		/* Setup veriables */
		let sizeWallTop: CGSize = CGSizeMake(self.size.width, 1)
		let locationWallTop: CGPoint = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 60)
		
		let sizeWallBottom: CGSize = CGSizeMake(self.size.width, 1)
		let locationWallBottom: CGPoint = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame))
		
		let sizeWallLeft: CGSize = CGSizeMake(1, self.size.height - 60)
		let locationWallLeft: CGPoint = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMidY(self.frame) - 30)
		
		let sizeWallRight: CGSize = CGSizeMake(1, self.size.height - 60)
		let locationWallRight: CGPoint = CGPointMake(CGRectGetMaxX(self.frame) , CGRectGetMidY(self.frame) - 30)
		
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
		self.view!.showsPhysics = true
		self.view!.showsFPS = true
		self.view!.showsNodeCount = true
        
        labels("Create", lang: defaults.stringForKey("gameLanguage")!)
		traySetUp()
		createBall()
        brickSetUp()
        
		
		physicsWorld.gravity = CGVectorMake(0, 0)
		physicsWorld.contactDelegate = self
		
		let panGesture:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GameScene.moveTray(_:)))
		view.addGestureRecognizer(panGesture)
	}
	
	/* --> Start Notifications Section */
	func menuInGameShow()
	{
		print("Show Menu")
		//pauseGame(true)
	}
	
	func menuInGameHide()
	{
		print("Hide Menu")
		//pauseGame(false)
	}

	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	/* <-- End Notifications Section */
	
	func labels(operation: String, lang: String)
	{
		if let path = NSBundle.mainBundle().pathForResource("Language", ofType: "plist")
		{
			if let dict = NSDictionary(contentsOfFile: path)
			{
				let dic = dict.objectForKey(lang)!
				
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
					pointsTitleLabel.text = dic.objectForKey("points") as? String
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
					lifeTitleLabel.text = dic.objectForKey("life") as? String
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
					timeTitleLabel.text = dic.objectForKey("time") as? String
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
					winnerLabel.text = dic.objectForKey("winner") as? String
					winnerLabel.fontSize = 36
					winnerLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/1.5);
					addChild(winnerLabel)
					
					
					playerName.text = dic.objectForKey("name") as? String // Create Label for player to craet name
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
                    
                    ball.removeFromParent()
                    tray.removeFromParent()
				}
				else if (operation == "Restart_GameOver")
				{
					gameOverLabel.removeFromParent()
					winnerLabel.removeFromParent()
					
					playerName.removeFromParent()
					pointListLabel.removeFromParent()
				}
				else if (operation == "Restart_Chance")
				{
					restartLabel.removeFromParent()
				}
				else if (operation == "HitInBottom")
				{
					var str = lifesLabel.text!
					str.removeAtIndex(str.endIndex.predecessor())
					lifesLabel.text = str
					
					restartLabel.text = dic.objectForKey("tapToRestart") as? String // "Tap to Restart";
					restartLabel.fontSize = 36;
					restartLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2);
					addChild(restartLabel)
				}
				else if (operation == "GameOver")
				{
					gameOverLabel.childNodeWithName("GameOver")
					gameOverLabel.text = dic.objectForKey("gameOver") as? String //"Game Over :(";
					gameOverLabel.fontSize = 36;
					gameOverLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2);
					addChild(gameOverLabel)
				}
			}
		}
	}
	

	func counter()
	{
		playingTime.text = "\(timeNumberFormatter.stringFromNumber(timerNumber + 1 )!)"
        timerNumber = Int(playingTime.text!)!
	}
	
	// BALL
	func createBall()
	{
		ball = Ball(imageNamed: "Ball")
		ball.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
		startBallPosition = ball.position
		addChild(ball)
	}
	
	let ballSpeed: CGFloat = 800.0 // SetUp global ball speed for debug
	var bouncAngle: CGFloat = 0.25 // 0 = 90, 1 = 45 degrees
	var directionIsUp: Bool = false
	var directionIsRight: Bool = false
	var signX = CGFloat()
	var signY = CGFloat()
	
	func moveBall(x: CGFloat, y: CGFloat, speed: CGFloat)
	{
		let path: CGMutablePathRef = CGPathCreateMutable()
		CGPathMoveToPoint(path, nil, 0.0, 0.0)
		CGPathAddLineToPoint(path, nil, x*bouncAngle, y) // how far ball should move
		move = SKAction.followPath(path, asOffset: true, orientToPath: false, speed: speed)
		ball.runAction(move, withKey: "moveBall")
	}
	
	func randomAngle() -> CGFloat
	{
		let angleValueArray = [1, 0.75, 0.5, 0.25, 0]
		let rIndex = Int(arc4random_uniform(UInt32(angleValueArray.count)))
		let rItem = angleValueArray[rIndex]
		return CGFloat(rItem)
	}
	
	func randomDirectionOfBounce()
	{
		let tempArray = ["false", "true"]
		let rIndex = Int(arc4random_uniform(UInt32(tempArray.count)))
		let rItem = tempArray[rIndex]
		directionIsRight = rItem.toBool()!
	}
	
    func bounce(bounce: String, contactPoint: CGPoint)
	{
		switch bounce {
		case "bottom":
            ball.removeFromParent()
            tray.removeFromParent()
            timer.invalidate() // Stop time
            
            if (lifesLabel.text?.characters.count <= 1)
            {
                labels("Remove", lang: defaults.stringForKey("gameLanguage")!)
                labels("GameOver", lang: defaults.stringForKey("gameLanguage")!)
                gameIsOver = true
            }
            else
            {
                labels("HitInBottom", lang: defaults.stringForKey("gameLanguage")!)
                restart = true
            }

            
            
		case "top":
			directionIsUp = false
			if directionIsRight
			{
				signX = 1
				signY = -1
			}
			else
			{
				signX = -1
				signY = -1
			}
			moveBall(signX*(self.view?.frame.size.height)!, y: signY*(self.view?.frame.size.height)!, speed: ballSpeed)

		case "left":
			directionIsRight = true
			if directionIsUp
			{
				signX = 1
				signY = 1
			}
			else
			{
				signX = 1
				signY = -1
			}
			moveBall(signX*(self.view?.frame.size.height)!, y: signY*(self.view?.frame.size.height)!, speed: ballSpeed)

		case "right":
			directionIsRight = false
			if directionIsUp
			{
				signX = -1
				signY = 1
			}
			else
			{
				signX = -1
				signY = -1
			}
			moveBall(signX*(self.view?.frame.size.height)!, y: signY*(self.view?.frame.size.height)!, speed: ballSpeed)

		case "tray":
			print("Tray")
            directionIsUp = true
            
            if directionIsRight
            {
                signX = 1
                signY = 1
            }
            else
            {
                signX = -1
                signY = 1
            }
            pointsLabel.text = "\(pointsNumberFormatter.stringFromNumber(pointsNumber + 1)!)"
            pointsNumber = Int(pointsLabel.text!)!
            bouncAngle = randomAngle()
            moveBall(signX*(self.view?.frame.size.height)!, y: signY*(self.view?.frame.size.height)!, speed: ballSpeed)
			
		case "brick":
            if (contactPoint.y >= ((contactWithBrickName.node?.position.y)! + brick.size.height/2 - 2) ||
                contactPoint.y <= ((contactWithBrickName.node?.position.y)! - brick.size.height/2 + 2))
            {
                if (contactPoint.y > (contactWithBrickName.node?.position.y)!)
                {
                    //print("Top")
                    
                    directionIsUp = true
                    if directionIsRight
                    {
                        signX = 1
                        signY = 1
                    }
                    else
                    {
                        signX = -1
                        signY = 1
                    }
                }
                else
                {
                    //print("Bottom")
                    
                    directionIsUp = false
                    if directionIsRight
                    {
                        signX = 1
                        signY = -1
                    }
                    else
                    {
                        signX = -1
                        signY = -1
                    }
                }
                
            }
            else if (contactPoint.x >= ((contactWithBrickName.node?.position.x)! + brick.size.width/2 - 2) ||
            contactPoint.x <= ((contactWithBrickName.node?.position.x)! - brick.size.width/2 + 2))
            {
                if (contactPoint.x > (contactWithBrickName.node?.position.x)!)
                {
                    //print("Right")
                    
                    directionIsRight = false
                    if directionIsUp
                    {
                        signX = -1
                        signY = 1
                    }
                    else
                    {
                        signX = -1
                        signY = -1
                    }
                }
                else
                {
                    //print("Left")
                    
                    directionIsRight = true
                    if directionIsUp
                    {
                        signX = 1
                        signY = 1
                    }
                    else
                    {
                        signX = 1
                        signY = -1
                    }
                }
            }
            
            moveBall(signX*(self.view?.frame.size.height)!, y: signY*(self.view?.frame.size.height)!, speed: ballSpeed)
            inContactWithOneBrick = false
            removeBrick(contactWithBrickName.node)
            
		default:
			print("Default")
		}
	}
	// ---
	
	
	// BRICK

    func removeBrick(node: SKNode!)
    {
        let fadeOutBrick: SKAction = SKAction.fadeOutWithDuration(0.07)
        let complete = SKAction.runBlock {
            node.removeFromParent()
            self.pointsNumber += 50
            self.pointsLabel.text = "\(self.pointsNumberFormatter.stringFromNumber(self.pointsNumber)!)"
        }
        
        node.runAction(SKAction.sequence([fadeOutBrick, complete]))
        
        if bricksArray.contains((node.name)!)
        {
            bricksArray.removeAtIndex(bricksArray.indexOf((node.name)!)!)
            
            if (bricksArray.count == 0)
            {
                // TODO: Zapis punktów do pamięci(pliku/chmura?), wyświetlenie tablicy z najlepszymi.
                //winGame()
            }
        }
    }
    
	func brickSetUp()
	{
		//let brickSize = SKTexture(imageNamed: "Brick_Green)").size
		let brickSize = UIImage(named: "Brick_Green")?.size

		let bricksNumber: NSInteger = 3 // 0 just for testing
		let brickRowNumber: NSInteger = 3
		//print("brickRowNumber: \(brickRowNumber)")
		let c = bricksNumber
		let r = brickRowNumber
 		let spaceBetwenBricks: CGSize = CGSizeMake(15, -78)

		
		let baseOrigin: CGPoint = CGPointMake(CGRectGetMidX(self.frame) - 70 - spaceBetwenBricks.width,CGRectGetMaxY(self.frame) - 160) // powinno byś 140
		
		

        for row in 0...r-1
		{
			let strTemp: String = "brick\(row)"
			
			var brickPosition: CGPoint = CGPointMake(baseOrigin.x, CGFloat(row) * ((brickSize!.height)) + baseOrigin.y)
			
            for col in 0...c-1
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
		addChild(tray)
	}
	
	func moveTray(gesture: UIPanGestureRecognizer)
	{
		if !gameWasPaused
		{
			if (gesture.locationInView(self.view!).x <= tray.position.x + tray.size.width/1.3 &&
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
						tray.position.x = 1 + tray.size.width/2
					}
					else if (tray.position.x >= self.frame.size.width - tray.size.width/2)
					{
						tray.position.x = self.frame.size.width - 1 - tray.size.width/2
					}
				}
			}
			
			tray.runAction(SKAction.moveTo(tray.position, duration: 0))
		}
	}
	
	// ---
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) { // Swift 2.0
			
		
		/* Called when a touch begins */
		if !ballIsInMiddleOfMoving
		{
			if (!timer.valid)
			{
				timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(GameScene.counter), userInfo: nil, repeats: true)
			}
			//let i = -ball.position.y + 10
			
			randomDirectionOfBounce()
			moveBall(0.0, y: -ball.position.y, speed: ballSpeed)
            //counter()
			ballIsInMiddleOfMoving = true
		}
        
        
        if (restart)
        {
            print("Restart...")
            labels("Restart_Chance", lang: defaults.stringForKey("gameLanguage")!)
            traySetUp()
            createBall()
            
            restart = false
            ballIsInMiddleOfMoving = false
        }
    
        if (gameIsOver)
        {
            labels("Restart_GameOver", lang: defaults.stringForKey("gameLanguage")!)
            labels("Create", lang: defaults.stringForKey("gameLanguage")!)
            brickSetUp()
            traySetUp()
            createBall()
            gameIsOver = false
            ballIsInMiddleOfMoving = false
        }
	}
	
	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
	}
}