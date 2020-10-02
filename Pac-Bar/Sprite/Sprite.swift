//
//  Sprite.swift
//  Pac-Bar
//
//  Created by Henry Franks on 31/08/2020.
//  Copyright © 2020 Henry Franks. All rights reserved.
//

import Foundation
import SpriteKit

enum Direction {
    case up, down, left, right
}

class Sprite: SKSpriteNode {
    var direction: Direction

    init(
        position: CGPoint,
        size: CGSize,
        texture: SKTexture,
        physicsBody: SKPhysicsBody?,
        direction: Direction
    ) {
        self.direction = direction

        super.init(
            texture: texture,
            color: .clear,
            size: size
        )

        self.position = position
        self.physicsBody = physicsBody
    }

    required init?(coder aDecoder: NSCoder) {
        // TODO: Does this need a proper implementation?
        self.direction = .right
        super.init(coder: aDecoder)
    }

    func update() {
        self.checkOverflow()
    }

    func checkOverflow() {
        if self.position.x < 0 {
            self.position.x = 700
        } else if self.position.x > 700 {
            self.position.x = 0
        }

        if self.position.y < 0 {

            if self.xIsClose(to: 214) {
                self.position.x = 642
            } else {
                self.position.x = 214
            }

            self.position.y = 30

        } else if self.position.y > 30 {

            if self.xIsClose(to: 214) {
                self.position.x = 642
            } else {
                self.position.x = 214
            }

            self.position.y = 0
        }
    }

    func currentSquare() -> CGPoint {
        return CGPoint(
            x: (self.position.x / SQUARE_SIZE).rounded(.towardZero),
            y: (self.position.y / SQUARE_SIZE).rounded(.towardZero)
        )
    }

    func xIsClose(to pos: CGFloat) -> Bool {
        return abs(self.position.x - pos) < POS_EPS
    }

    func yIsClose(to pos: CGFloat) -> Bool {
        return abs(self.position.y - pos) < POS_EPS
    }
}
