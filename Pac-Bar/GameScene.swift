//
//  GameScene.swift
//  Pac-Bar
//
//  Created by Henry Franks on 18/12/2019.
//  Copyright © 2019 Henry Franks. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

var level: Int = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Variables
    var state: GameState = .introAnimation
    var score: Int = 0
    var numDots = 85
    var barIsWhite: Bool = false

    // Sounds
    let introSound = SKAction.playSoundFileNamed(
        "intro.wav",
        waitForCompletion: false
    )
    let slowSiren = SKAction.playSoundFileNamed(
        "siren slow.wav",
        waitForCompletion: true
    )
    let mediumSiren = SKAction.playSoundFileNamed(
        "siren medium.wav",
        waitForCompletion: true
    )
    let fastSiren = SKAction.playSoundFileNamed(
        "siren fast.wav",
        waitForCompletion: true
    )

    //Creating stuff
    func createDots() {
        var dotArray = [SKSpriteNode]()
        for _ in 1...85 {
            dotArray.append(SKSpriteNode(imageNamed: "dot"))
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

    func createSprite(
        texture: [SKTexture],
        height: Int,
        width: Int,
        xPos: Int,
        yPos: Int,
        node: inout SKSpriteNode!,
        catBitMask: UInt32,
        conTestBitMask: [UInt32]
    ) {
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
        pacman.playMunchSound()
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

    func updateScore(value: String) {
        textField?.stringValue = value
        highField?.stringValue = "High Score: \(highScore)"
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB

        if firstBody.categoryBitMask == gamePhysics.PacMan &&
           secondBody.categoryBitMask == gamePhysics.Dot
        {
            removeDot(dot: secondBody.node as! SKSpriteNode)
        }
        else if firstBody.categoryBitMask == gamePhysics.PacMan &&
                secondBody.categoryBitMask == gamePhysics.Blinky
        {
            // game over
            self.state = .gameOverAnimation

            if score > highScore {
                highScore = score
            }

            self.view?.scene?.isPaused = true
            for action in ["slowSiren", "mediumSiren", "fastSiren"] {
                self.removeAction(forKey: action)
            }

            blinky.removeFromParent()
            self.removeDots()

            pacman.position.y -= 2
            pacman.removeAction(forKey: "PacManEat")
            pacman.texture = SKTexture(imageNamed: "Pacman3")

            blinky.removeFromParent()

            updateScore(value: String(describing: score) + "\n GAME OVER")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.view?.scene?.isPaused = false
                pacman.gameover()
            }

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.1) {
                pacman.removeFromParent()
                self.state = .waitingForRestart
                self.view?.scene?.isPaused = true
            }
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

        self.addChild(pacman)
        self.addChild(blinky)

        pacman.texture = PacMan.eatFrames[2]

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.5) {
            self.createDots()

            pacman.run(
                SKAction.repeatForever(SKAction.animate(
                    with: PacMan.eatFrames,
                    timePerFrame: 0.05,
                    resize: false,
                    restore: true
                )),
                withKey: "PacManEat"
            )
            blinky.run(
                SKAction.repeatForever(SKAction.animate(
                    with: Blinky.sideFrames,
                    timePerFrame: 0.05,
                    resize: false,
                    restore: true
                )),
                withKey: "horizontalMove"
            )

            self.state = .playing
            self.run(
                SKAction.repeatForever(self.slowSiren),
                withKey: "slowSiren"
            )
        }
    }

    //Update everything (calls other functions)
    override func update(_ currentTime: TimeInterval) {
        if self.state == .playing {
            pacman.update()
            blinky.update()

            if numDots <= 10 && blinky.movementSpeed == .medium {
                blinky.movementSpeed = .fast
                self.removeAction(forKey: "mediumSiren")
                self.run(
                    SKAction.repeatForever(self.fastSiren),
                    withKey: "fastSiren"
                )
            } else if numDots <= 30 && blinky.movementSpeed == .slow {
                blinky.movementSpeed = .medium
                self.removeAction(forKey: "slowSiren")
                self.run(
                    SKAction.repeatForever(self.mediumSiren),
                    withKey: "mediumSiren"
                )
            }

            if counter > 0 {
                counter -= 1

                if directionCache != nil  && pacman.yIsClose(to: 15) &&
                    (pacman.xIsClose(to: 214) ||
                        pacman.xIsClose(to: 642)) {
                    pacman.updateDirection(to: directionCache!)
                    counter = 0
                }

                if counter == 0 {
                    directionCache = nil
                }
            }

            if numDots < 1 {
                self.view?.scene?.isPaused = true

                for action in ["slowSiren", "mediumSiren", "fastSiren"] {
                    self.removeAction(forKey: action)
                }

                pacman.texture = SKTexture(imageNamed: "Pacman3")

                DispatchQueue.main.asyncAfter(
                    deadline: DispatchTime.now() + 0.3)
                {
                    blinky.removeFromParent()

                    for i in 1...8 {
                        self.flashAfterDelay(delay: Double(i) * 0.2)
                    }
                }

                DispatchQueue.main.asyncAfter(
                    deadline: DispatchTime.now() + 2.3)
                {
                    pacman.removeFromParent()
                    self.hideBars()
                }

                DispatchQueue.main.asyncAfter(
                    deadline: DispatchTime.now() + 2.4)
                {
                    self.addChild(pacman)
                    pacman.position = CGPoint(x: 300, y: 15)

                    self.createBorders()

                    self.addChild(blinky)
                    blinky.position = CGPoint(x: 50, y: 15)
                    blinky.movementSpeed = .slow
                }

                DispatchQueue.main.asyncAfter(
                    deadline: DispatchTime.now() + 2.6)
                {
                    self.numDots = 85
                    self.createDots()
                    self.view?.scene?.isPaused = false

                    self.run(
                        SKAction.repeatForever(self.slowSiren),
                        withKey: "slowSiren"
                    )
                }
            }
        }
    }
}
