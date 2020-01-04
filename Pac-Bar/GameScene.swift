//
//  GameScene.swift
//  Pac-Bar
//
//  Created by Henry Franks on 18/12/2019.
//  Copyright © 2019 Henry Franks. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

// TODO: Convert to classes
// TODO: GameState enum

class GameScene: SKScene, SKPhysicsContactDelegate {

	//Variables
	var state: GameState = .intro
	var score: Int = 0
	var borderArray = [SKSpriteNode]()
	var numDots = 85
	var PacMan: SKSpriteNode!
	var PacFrames: [SKTexture]!
	var Blinky: SKSpriteNode!
	var BlinkyFrames: [SKTexture]!
	var BlinkyUpFrames: [SKTexture]!
	var BlinkyDownFrames: [SKTexture]!
	var bHorizontalMove: Bool = true
	var bVerticalMove: Bool = true
	var blinkySpeed: CGFloat = 1
	var barIsWhite: Bool = false
	var level: Int = 0
	var tHold1: Bool = false
	var tHold2: Bool = false //These keep Blinky's speed from being increased more than once
	var dotNumber: Bool = true //true = 1, false = 2

	// Sounds
	let munchA = SKAction.playSoundFileNamed("munch A.wav", waitForCompletion: false)
	let munchB = SKAction.playSoundFileNamed("munch B.wav", waitForCompletion: false)
	let gameOverSound = SKAction.playSoundFileNamed("death.wav", waitForCompletion: false)
	let introSound = SKAction.playSoundFileNamed("intro.wav", waitForCompletion: false)
	let slowSiren = SKAction.playSoundFileNamed("siren slow.wav", waitForCompletion: true)
	let mediumSiren = SKAction.playSoundFileNamed("siren medium.wav", waitForCompletion: true)
	let fastSiren = SKAction.playSoundFileNamed("siren fast.wav", waitForCompletion: true)

	//Creating stuff
	func createDots() {
		var dotArray = [SKSpriteNode]()
		for _ in 1...85 {
			dotArray.append(SKSpriteNode(imageNamed: "Dot"))
		}
		var offsetX = 7
		for (index, item) in dotArray.enumerated() {
			item.position.x = CGFloat(offsetX)
			item.position.y = 15
			item.name = "Dot\(index)"
			item.physicsBody = SKPhysicsBody(rectangleOf: item.size)
			item.physicsBody?.categoryBitMask = gamePhysics.Dot
			item.physicsBody?.contactTestBitMask = gamePhysics.PacMan
			item.physicsBody?.isDynamic = true
			item.physicsBody?.affectedByGravity = false
			item.physicsBody?.collisionBitMask = 0
			self.addChild(item)
			offsetX += 8
		}
		level += 1
		blinkySpeed = 1
		if level > 10 {
			bSpeedInc()
		}
		if level > 15 {
			bSpeedInc()
		}
		if level > 20 {
			bSpeedInc()
		}
	}

	func createBorders() {
		var barArray = [SKSpriteNode]()
		barArray.append(SKSpriteNode(imageNamed: "barR"))
		barArray.append(SKSpriteNode(imageNamed: "bbarR"))
		barArray.append(SKSpriteNode(imageNamed: "barL"))
		barArray.append(SKSpriteNode(imageNamed: "bbarL"))
		barArray.append(SKSpriteNode(imageNamed: "barR"))
		barArray.append(SKSpriteNode(imageNamed: "bbarR"))
		for b in barArray {
			b.xScale = 1
			b.yScale = 1
		}
		var sArray = [SKSpriteNode]()
		sArray.append(SKSpriteNode(imageNamed: "barLs"))
		sArray.append(SKSpriteNode(imageNamed: "bbarLs"))
		var offsetX = 107
		var inc: Bool = false
		for (index, item) in barArray.enumerated() {
			item.name = "Bar" + "\(index)"
			item.position.x = CGFloat(offsetX)
			if inc {
				item.position.y = 2
			} else {
				item.position.y = 28
			}
			self.addChild(item)
			if inc {
				offsetX += 214
			}
			inc = !inc
		}
		for (index, item) in sArray.enumerated() {
			item.name = "Bar" + "\(index + 6)"
			item.position.x = 671
			if index == 0 {
				item.position.y = 28
			} else {
				item.position.y = 2
			}
			self.addChild(item)
		}
	}

	func createSprite(texture: [SKTexture], height: Int, width: Int, xPos: Int, yPos: Int, node: inout SKSpriteNode!, catBitMask: UInt32, conTestBitMask: [UInt32]) {
		node = SKSpriteNode(texture: texture[0])
		node.size.height = CGFloat(height)
		node.size.width = CGFloat(width)
		node.position.x = CGFloat(xPos)
		node.position.y = CGFloat(yPos)
		node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
		node.physicsBody?.categoryBitMask = catBitMask
		for mask in conTestBitMask {
			node.physicsBody?.contactTestBitMask = mask
		}
		node.physicsBody?.isDynamic = true
		node.physicsBody?.affectedByGravity = false
		self.addChild(node)
	}

	//Removing stuff
	func removeDot(dot: SKSpriteNode) {
		score += 10
		dot.removeFromParent()
		numDots -= 1
		updateScore(value: String(describing: score))
		if dotNumber {
			PacMan.run(munchA)
		} else {
			PacMan.run(munchB)
		}
		dotNumber = !dotNumber
	}

	func removeDots() {
		self.enumerateChildNodes(withName: "Dot" + "*", using: {
			(node, stop) -> Void in
			node.removeFromParent()
		})
	}

	func hideBars() {
		self.enumerateChildNodes(withName: "Bar" + "*", using: {
			(node, stop) -> Void in
			node.removeFromParent()
		})
	}

	//Miscellaneous
	func GameOver(blinky: SKSpriteNode) {
		if score > highScore {
			highScore = score
		}

		self.view?.scene?.isPaused = true
		for action in ["slowSiren", "mediumSiren", "fastSiren"] {
			self.removeAction(forKey: action)
		}

		blinky.removeFromParent()
		self.removeDots()
		DeathFrames()
	}

	func flashBars() {
		func isWhite() -> String {
			if barIsWhite {
				return ""
			}
			return "w"
		}

		self.enumerateChildNodes(withName: "Bar" + "*", using: {
			(node, stop) -> Void in
			let n = node as? SKSpriteNode
			switch n?.name {
			case "Bar0"?:
				n?.texture = SKTexture(imageNamed: "barR" + isWhite())
			case "Bar1"?:
				n?.texture = SKTexture(imageNamed: "bbarR" + isWhite())
			case "Bar2"?:
				n?.texture = SKTexture(imageNamed: "barL" + isWhite())
			case "Bar3"?:
				n?.texture = SKTexture(imageNamed: "bbarL" + isWhite())
			case "Bar4"?:
				n?.texture = SKTexture(imageNamed: "barR" + isWhite())
			case "Bar5"?:
				n?.texture = SKTexture(imageNamed: "bbarR" + isWhite())
			case "Bar6"?:
				n?.texture = SKTexture(imageNamed: "barLs" + isWhite())
			case "Bar7"?:
				n?.texture = SKTexture(imageNamed: "bbarLs" + isWhite())
			default:
				break
			}
		})
		barIsWhite = !barIsWhite
	}

	func flashAfterDelay(delay: Double) {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
			self.flashBars()
		}
	}

	func findDiv(number: Double, divLength: Double) -> Double {
		//find where 'number' lies in 'total' divided into divisions of 'divlength' width (separation into squares)
		return ((number / divLength)).rounded(.towardZero)
	}

	func findShortestPath(array: [Double]) -> Int {
		var i: Double = array[0]
		var output: Int = 0
		for (index, item) in array.enumerated() {
			if item < i && item > 0 {
				i = item
				output = index
			}
		}
		return output
	}

	func updateScore(value: String) {
		textField?.stringValue = value
		highField?.stringValue = "High Score: \(highScore)"
	}

	func bSpeedInc() {
		blinkySpeed = blinkySpeed * 1.05
	}

	func DeathFrames() {
		var PacManD: SKSpriteNode!
		let DeathAtlas = SKTextureAtlas(named: "PacmanD")
		var deathFrames = [SKTexture]()
		for index in 1...11 {
			let textureName = "PacManD\(index)"
			deathFrames.append(DeathAtlas.textureNamed(textureName))
		}
		PacManD = SKSpriteNode(texture: deathFrames[0])
		PacManD.position.x = self.PacMan.position.x
		PacManD.position.y = self.PacMan.position.y - 2
		Blinky.removeFromParent()
		PacMan.removeAction(forKey: "PacManEat")
		PacMan.texture = SKTexture(imageNamed: "Pacman3")
		updateScore(value: String(describing: score) + "\n GAME OVER")
		self.PacMan.removeFromParent()
		self.addChild(PacManD)
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
			self.view?.scene?.isPaused = false
			PacManD.run(self.gameOverSound)

			for i in 1...11 {
				if i == 1 {
					PacManD.position.y -= 1 //to account for differences in sprite dimensions
				}
				if i == 11 {
					PacManD.position.y += 1
				}
				PacManD.run(SKAction.animate(with: deathFrames, timePerFrame: 0.1, resize: false, restore: true), withKey: "GameOver")
			}
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.3) {
				self.view?.scene?.isPaused = true
			}
		}
	}

	func didBegin(_ contact: SKPhysicsContact) {
		let firstBody: SKPhysicsBody = contact.bodyA
		let secondBody: SKPhysicsBody = contact.bodyB
		if (firstBody.categoryBitMask == gamePhysics.PacMan) && (secondBody.categoryBitMask == gamePhysics.Dot) {
			removeDot(dot: secondBody.node as! SKSpriteNode)
		} else if (firstBody.categoryBitMask == gamePhysics.Blinky) && (secondBody.categoryBitMask == gamePhysics.PacMan) {
			GameOver(blinky: firstBody.node as! SKSpriteNode)
		}
	}

	//Movement
	func checkVertical() {
		if PacMan.position.x < 214.5 && PacMan.position.x > 213.5 { //to account for decimals
			if up {
				PacMan.position.x = 214
				PacMan.xScale = 1
				PacMan.zRotation = CGFloat(0.5 * Double.pi)
				horizontalMove = false
				PacMan.position.y += 1
			} else if down {
				PacMan.xScale = 1
				PacMan.position.x = 214
				PacMan.zRotation = CGFloat(1.5 * Double.pi)
				horizontalMove = false
				PacMan.position.y -= 1
			}
		} else if PacMan.position.x < 642.5 && PacMan.position.x > 641.5 {
			if up {
				PacMan.xScale = 1
				PacMan.position.x = 642
				PacMan.zRotation = CGFloat(0.5 * Double.pi)
				horizontalMove = false
				PacMan.position.y += 1
			} else if down {
				PacMan.xScale = 1
				PacMan.position.x = 642
				PacMan.zRotation = CGFloat(1.5 * Double.pi)
				horizontalMove = false
				PacMan.position.y -= 1
			}
		}
	}

	func checkHorizontal() {
		if !horizontalMove {
			if PacMan.position.y < 16 && PacMan.position.y > 14 {
				if horizontalWait {
					horizontalMove = true
					PacMan.position.y = 15
					PacMan.zRotation = 0
					horizontalWait = false
					up = false
					down = false
				}
			}
		}
	}

	func findNearestPath() -> [Double]? {
		let bXPos = Double(Blinky.position.x)
		let bYPos = Double(Blinky.position.y)
		let pXPos = Double(PacMan.position.x)
		let pYPos = Double(PacMan.position.y)
		var out = [Double]()
		if (bYPos > 14.5 && bYPos < 15.5) && (bXPos < 214.5 && bXPos > 213.5 || bXPos < 642.5 && bXPos > 641.5 ) {
			let pXDiv = findDiv(number: pXPos, divLength: 14)
			let pYDiv = findDiv(number: pYPos, divLength: 14)
			let bXDiv = findDiv(number: bXPos, divLength: 14)
			let bYDiv = findDiv(number: bYPos, divLength: 14)
			let fBXDiv = (findDiv(number: bXPos, divLength: 14) + 1)
			let bBXDiv = (findDiv(number: bXPos, divLength: 14) - 1)
			let uBYDiv = (findDiv(number: bYPos, divLength: 14) + 1)
			let dBYDiv = (findDiv(number: bYPos, divLength: 14) - 1)
			let currentXDiff: Double = abs(pXDiv - bXDiv) * abs(pXDiv - bXDiv)
			let currentYDiff: Double = abs(pYDiv - bYDiv) * abs(pYDiv - bYDiv)
			let forwardsDiff: Double = abs(pXDiv - fBXDiv) * abs(pXDiv - fBXDiv)
			let backwardsDiff: Double = abs(pXDiv - bBXDiv) * abs(pXDiv - bBXDiv)
			let upDiff: Double = abs(pYDiv - uBYDiv) * abs(pYDiv - uBYDiv)
			let downDiff: Double = abs(pYDiv - dBYDiv) * abs(pYDiv - dBYDiv)
			if bHorizontalMove {
				if Blinky.xScale > 0 {
					out = [currentXDiff + upDiff, -1.0, currentXDiff + downDiff, forwardsDiff + currentYDiff]
				} else {
					out = [currentXDiff + upDiff, backwardsDiff + currentYDiff, currentXDiff + downDiff, -1.0]
				}
			} else {
				if bVerticalMove {
					out = [currentXDiff + upDiff, backwardsDiff + currentYDiff, -1.0, forwardsDiff + currentYDiff]
				} else {
					out = [-1.0, backwardsDiff + currentYDiff, currentXDiff + downDiff, forwardsDiff + currentYDiff]
				}
			}
			for (index, item) in out.enumerated() {
				//Broken down to allow it to be solved in reasonable time
				out[index] = sqrt(item)
				out[index] = Double(item)
			}
			return out
		}
		return nil
	}

	func bSpeed(xPos: CGFloat, yPos: CGFloat) -> CGFloat {
		if xPos < 50 || xPos > 650 || yPos > 16 || yPos < 14 {
			return (blinkySpeed - 0.1)
		}
		return blinkySpeed
	}

	func checkOverflow( sprite: SKSpriteNode) {
		if sprite.position.x < 0 {
			sprite.position.x = 700
		} else if sprite.position.x > 700 {
			sprite.position.x = 0
		}
		if sprite.position.y < 0 {
			if sprite.position.x > 213.5 && sprite.position.x < 214.5 {
				sprite.position.x = 642
			} else {
				sprite.position.x = 214
			}
			sprite.position.y = 30
		} else if sprite.position.y > 30 {
			if sprite.position.x > 213.5 && sprite.position.x < 214.5 {
				sprite.position.x = 642
			} else {
				sprite.position.x = 214
			}
			sprite.position.y = 0
		}
	}

	//Initialise the game
	override func didMove(to view: SKView) {
		super.didMove(to: view)

		self.run(introSound)

		updateScore(value: "READY!")

		physicsWorld.contactDelegate = self

		createBorders()
		self.scaleMode = .resizeFill
		self.backgroundColor = .black
		let PacManAtlas = SKTextureAtlas(named: "Pacman")
		var eatFrames = [SKTexture]()
		for index in 1...3 {
			let textureName = "PacMan\(index)"
			eatFrames.append(PacManAtlas.textureNamed(textureName))
		}
		let	BlinkyAtlas = SKTextureAtlas(named: "Blinky")
		var ghostFrames = [SKTexture]()
		for index in 1...2 {
			let textureName = "Blinky\(index)"
			ghostFrames.append(BlinkyAtlas.textureNamed(textureName))
		}
		let	BlinkyUpAtlas = SKTextureAtlas(named: "BlinkyUp")
		var ghostUpFrames = [SKTexture]()
		for index in 1...2 {
			let textureName = "BlinkyUp\(index)"
			ghostUpFrames.append(BlinkyUpAtlas.textureNamed(textureName))
		}
		let	BlinkyDownAtlas = SKTextureAtlas(named: "BlinkyDown")
		var ghostDownFrames = [SKTexture]()
		for index in 1...2 {
			let textureName = "BlinkyDown\(index)"
			ghostDownFrames.append(BlinkyDownAtlas.textureNamed(textureName))
		}
		BlinkyFrames = ghostFrames
		BlinkyUpFrames = ghostUpFrames
		BlinkyDownFrames = ghostDownFrames

		createSprite(texture: BlinkyFrames, height: 14, width: 14, xPos: 50, yPos: 15, node: &Blinky, catBitMask: gamePhysics.Blinky, conTestBitMask: [gamePhysics.PacMan, gamePhysics.Dot])
		PacFrames = eatFrames
		createSprite(texture: PacFrames, height: 13, width: 13, xPos: 300, yPos: 15, node: &PacMan, catBitMask: gamePhysics.PacMan, conTestBitMask: [gamePhysics.Dot, gamePhysics.Blinky])
		PacMan.texture = PacFrames[2]
		Blinky.physicsBody?.collisionBitMask = 0
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.5) {
			self.createDots()
			self.Blinky.zPosition = 5
			self.PacMan.run(SKAction.repeatForever(SKAction.animate(with: self.PacFrames, timePerFrame: 0.05, resize: false, restore: true)), withKey: "PacManEat")
			self.Blinky.run(SKAction.repeatForever(SKAction.animate(with: self.BlinkyFrames, timePerFrame: 0.05, resize: false, restore: true)), withKey: "BlinkyMove")
			self.state = .playing
			self.run(SKAction.repeatForever(self.slowSiren), withKey: "slowSiren")
		}
	}

	//Update everything (calls other functions)
	override func update(_ currentTime: TimeInterval) {
		if self.state == .playing {
			let bXPos = Blinky.position.x
			let bYPos = Blinky.position.y

			checkOverflow(sprite: PacMan)
			checkOverflow(sprite: Blinky)

			if numDots == 10 {
				if !tHold2 {
					bSpeedInc()

					self.removeAction(forKey: "mediumSiren")
					self.run(SKAction.repeatForever(fastSiren), withKey: "fastSiren")
				}

				tHold2 = true
			} else if numDots == 30 {
				if !tHold1 {
					bSpeedInc()

					self.removeAction(forKey: "slowSiren")
					self.run(SKAction.repeatForever(mediumSiren), withKey: "mediumSiren")
				}

				tHold1 = true
			}

			if let array = findNearestPath() {
				if findShortestPath(array: array) == 1 || findShortestPath(array: array) == 3 {
					bHorizontalMove = true
					if Blinky.action(forKey: "BlinkyMoveUp") != nil {
						Blinky.removeAction(forKey: "BlinkyMoveUp")
					}
					if Blinky.action(forKey: "BlinkyMoveDown") != nil {
						Blinky.removeAction(forKey: "BlinkyMoveDown")
					}
					if Blinky.action(forKey: "BlinkyMoveDown") == nil {
						Blinky.run(SKAction.repeatForever(SKAction.animate(with: BlinkyFrames, timePerFrame: 0.05, resize: false, restore: true)), withKey: "BlinkyMove")
					}
					Blinky.position.y = 15
				}
				switch findShortestPath(array: array) {
				case 0:
					if Blinky.action(forKey: "BlinkyMove") != nil {
						Blinky.removeAction(forKey: "BlinkyMove")
					}
					if Blinky.action(forKey: "BlinkyMoveDown") != nil {
						Blinky.removeAction(forKey: "BlinkyMoveDown")
					}
					if Blinky.action(forKey: "BlinkyMoveUp") == nil {
						Blinky.run(SKAction.repeatForever(SKAction.animate(with: BlinkyUpFrames, timePerFrame: 0.05, resize: false, restore: true)), withKey: "BlinkyMoveUp")
					}
					if Blinky.position.x < 214.5 && Blinky.position.x > 213.5 {
						Blinky.position.x = 214
					} else {
						Blinky.position.x = 642
					}
					bHorizontalMove = false
					bVerticalMove = true
					Blinky.position.y += bSpeed(xPos: bXPos, yPos: bYPos)
				case 1:
					bHorizontalMove = true
					Blinky.position.y = 15
					Blinky.position.x -= bSpeed(xPos: bXPos, yPos: bYPos)
					Blinky.xScale = -1
				case 2:
					if Blinky.action(forKey: "BlinkyMove") != nil {
						Blinky.removeAction(forKey: "BlinkyMove")
					}
					if Blinky.action(forKey: "BlinkyMoveUp") != nil {
						Blinky.removeAction(forKey: "BlinkyMoveUp")
					}
					if Blinky.action(forKey: "BlinkyMoveDown") == nil {
						Blinky.run(SKAction.repeatForever(SKAction.animate(with: BlinkyDownFrames, timePerFrame: 0.05, resize: false, restore: true)), withKey: "BlinkyMoveDown")
					}
					if Blinky.position.x < 214.5 && Blinky.position.x > 213.5 {
						Blinky.position.x = 214
					} else {
						Blinky.position.x = 642
					}
					bHorizontalMove = false
					bVerticalMove = false
					Blinky.position.y -= bSpeed(xPos: bXPos, yPos: bYPos)
				case 3:
					bHorizontalMove = true
					Blinky.position.y = 15
					Blinky.position.x += bSpeed(xPos: bXPos, yPos: bYPos)
					Blinky.xScale = 1
				default:
					break
				}
			} else {
				if bHorizontalMove {
					if Blinky.xScale > 0 {
						Blinky.position.x += bSpeed(xPos: bXPos, yPos: bYPos)
						Blinky.xScale = 1
					} else {
						Blinky.position.x -= bSpeed(xPos: bXPos, yPos: bYPos)
						Blinky.xScale = -1
					}
				} else {
					if bVerticalMove {
						Blinky.position.y += bSpeed(xPos: bXPos, yPos: bYPos)
					} else {
						Blinky.position.y -= bSpeed(xPos: bXPos, yPos: bYPos)
					}
				}
			}
			if horizontalMove {
				horizontalWait = false

				if direction {
					if PacMan.xScale < 0 {
						PacMan.xScale = PacMan.xScale * -1;
					}
					PacMan.position.x += 1
				} else {
					if PacMan.xScale > 0 {
						PacMan.xScale = PacMan.xScale * -1;
					}
					PacMan.position.x -= 1
				}
			}
			checkVertical()
			checkHorizontal()
			if counter > 0 {
				counter -= 1
			} else {
				horizontalWait = false
				if !(PacMan.position.x < 214.5 && PacMan.position.x > 213.5) && !(PacMan.position.x < 642.5 && PacMan.position.x > 641.5) {
					up = false
					down = false
				}
			}
			checkOverflow(sprite: Blinky)
			if numDots < 1 {
				self.view?.scene?.isPaused = true

				for action in ["slowSiren", "mediumSiren", "fastSiren"] {
					self.removeAction(forKey: action)
				}

				PacMan.texture = SKTexture(imageNamed: "Pacman3")

				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
					self.Blinky.removeFromParent()

					for i in 1...8 {
						self.flashAfterDelay(delay: Double(i) * 0.2)
					}
				}

				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.3) {
					self.PacMan.removeFromParent()
					self.hideBars()
				}

				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.4) {
					self.addChild(self.PacMan)
					self.createBorders()
					self.addChild(self.Blinky)
					self.Blinky.position.x = 50
					self.Blinky.position.y = 15
					self.PacMan.position.x = 300
					self.PacMan.position.y = 15
				}

				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.6) {
					direction = true
					self.Blinky.xScale = 1
					self.numDots = 85
					self.createDots()
					self.tHold1 = false
					self.tHold2 = false
					self.view?.scene?.isPaused = false

					self.run(SKAction.repeatForever(self.slowSiren), withKey: "slowSiren")
				}
			}
		}
	}
}
