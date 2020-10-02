//
//  PacMan.swift
//  Pac-Bar
//
//  Created by Henry Franks on 30/08/2020.
//  Copyright © 2020 Henry Franks. All rights reserved.
//

import Foundation
import SpriteKit

class PacMan: Sprite {

    private enum DotSoundABState {
        case A, B
    }

    private var munchAB: DotSoundABState = .A

    // sounds
    static let munchA = SKAction.playSoundFileNamed(
        "munch A.wav",
        waitForCompletion: false
    )

    static let munchB = SKAction.playSoundFileNamed(
        "munch B.wav",
        waitForCompletion: false
    )

    static let gameOverSound = SKAction.playSoundFileNamed(
        "death.wav",
        waitForCompletion: false
    )

    // graphics
    static let eatAtlas = SKTextureAtlas(named: "pacman")

    static let eatFrames = [
        PacMan.eatAtlas.textureNamed("PacMan1"),
        PacMan.eatAtlas.textureNamed("PacMan2"),
        PacMan.eatAtlas.textureNamed("PacMan3")
    ]

    static let gameoverAtlas = SKTextureAtlas(named: "gameover")

    static let gameoverFrames = [
        PacMan.gameoverAtlas.textureNamed("gameover1"),
        PacMan.gameoverAtlas.textureNamed("gameover2"),
        PacMan.gameoverAtlas.textureNamed("gameover3"),
        PacMan.gameoverAtlas.textureNamed("gameover4"),
        PacMan.gameoverAtlas.textureNamed("gameover5"),
        PacMan.gameoverAtlas.textureNamed("gameover6"),
        PacMan.gameoverAtlas.textureNamed("gameover7"),
        PacMan.gameoverAtlas.textureNamed("gameover8"),
        PacMan.gameoverAtlas.textureNamed("gameover9"),
        PacMan.gameoverAtlas.textureNamed("gameover10"),
        PacMan.gameoverAtlas.textureNamed("gameover11")
    ]


    init() {
        let size = CGSize(width: 13, height: 13)
        let physicsBody = SKPhysicsBody(rectangleOf: size)

        physicsBody.categoryBitMask = gamePhysics.PacMan

        physicsBody.contactTestBitMask = gamePhysics.Blinky &
                                          gamePhysics.Dot

        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = false

        super.init(
            position: CGPoint(x: 300, y: 15),
            size: size,
            texture: PacMan.eatFrames[2],
            physicsBody: physicsBody,
            direction: .right
        )

        self.zPosition = 5
    }

    required init?(coder aDecoder: NSCoder) {
        // TODO: Does this need a proper implementation?
        super.init(coder: aDecoder)
    }

    override func update() {
        super.update()

        switch self.direction {
        case .up:
            self.position.y += 1
        case.down:
            self.position.y -= 1
        case .left:
            self.position.x -= 1
        case .right:
            self.position.x += 1
        }
    }

    func playMunchSound() {
        if self.munchAB == .A {
            self.run(PacMan.munchA)
            self.munchAB = .B
        } else {
            self.run(PacMan.munchB)
            self.munchAB = .A
        }
    }

    func updateDirection(to newDirection: Direction) {
        switch newDirection {
        case .up:
            if self.xIsClose(to: 214) { self.position.x = 214 }
            else { self.position.x = 642 }

            self.xScale = 1
            self.zRotation = CGFloat(0.5 * Double.pi)

        case .down:
            if self.xIsClose(to: 214) { self.position.x = 214 }
            else { self.position.x = 642 }

            self.xScale = 1
            self.zRotation = CGFloat(1.5 * Double.pi)

        case .left:
            pacman.position.y = 15
            self.xScale = -1
            pacman.zRotation = 0

        case .right:
            pacman.position.y = 15
            self.xScale = 1
            pacman.zRotation = 0
        }

        self.direction = newDirection
    }

    func gameover() {
        self.xScale = 1
        self.zRotation = 0
        self.position.y -= 2

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.position.y += 1
        }

        self.run(PacMan.gameOverSound)
        self.run(
            SKAction.animate(
                with: PacMan.gameoverFrames,
                timePerFrame: 0.1,
                resize: false,
                restore: true
            ),
            withKey: "gameover"
        )
    }
}
