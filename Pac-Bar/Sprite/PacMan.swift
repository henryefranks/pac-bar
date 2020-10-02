//
//  PacMan.swift
//  Pac-Bar
//
//  Created by Henry Franks on 30/08/2020.
//  Copyright © 2020 Henry Franks. All rights reserved.
//

import Foundation
import SpriteKit

class PacMan: SKSpriteNode {
    static let munchA = SKAction.playSoundFileNamed(
        "munch A.wav",
        waitForCompletion: false
    )

    static let munchB = SKAction.playSoundFileNamed(
        "munch B.wav",
        waitForCompletion: false
    )

    static let atlas = SKTextureAtlas(named: "pacman")

    static let eatFrames = [
        PacMan.atlas.textureNamed("PacMan1"),
        PacMan.atlas.textureNamed("PacMan2"),
        PacMan.atlas.textureNamed("PacMan3")
    ]

    init() {
        super.init(
            texture: PacMan.eatFrames[2],
            color: .clear,
            size: CGSize(width: 13, height: 13)
        )

        self.position = CGPoint(x: 300, y: 15)

        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)

        self.physicsBody!.categoryBitMask = gamePhysics.Blinky

        self.physicsBody!.contactTestBitMask = gamePhysics.PacMan &
                                               gamePhysics.Dot
        
        self.physicsBody!.isDynamic = true
        self.physicsBody!.affectedByGravity = false
    }

    required init?(coder aDecoder: NSCoder) {
        // TODO: Does this need a proper implementation?
        super.init(coder: aDecoder)
    }
}
