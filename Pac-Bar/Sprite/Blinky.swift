//
//  Blinky.swift
//  Pac-Bar
//
//  Created by Henry Franks on 30/08/2020.
//  Copyright © 2020 Henry Franks. All rights reserved.
//

import Foundation
import SpriteKit

class Blinky: Sprite {
    static let atlas = SKTextureAtlas(named: "blinky")

    private var canChangeDirection: Bool = true

    static let sideFrames = [
        Blinky.atlas.textureNamed("BlinkySide1"),
        Blinky.atlas.textureNamed("BlinkySide2")
    ]

    static let upFrames = [
        Blinky.atlas.textureNamed("BlinkyUp1"),
        Blinky.atlas.textureNamed("BlinkyUp2")
    ]

    static let downFrames = [
        Blinky.atlas.textureNamed("BlinkyDown1"),
        Blinky.atlas.textureNamed("BlinkyDown2")
    ]

    enum MovementSpeed {
        case slow, medium, fast
    }

    var movementSpeed: MovementSpeed = .slow

    init() {
        let size = CGSize(width: 14, height: 14)
        let physicsBody = SKPhysicsBody(rectangleOf: size)

        physicsBody.categoryBitMask = gamePhysics.Blinky

        physicsBody.contactTestBitMask = gamePhysics.PacMan

        physicsBody.collisionBitMask = 0

        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = false

        super.init(
            position: CGPoint(x: 50, y: 15),
            size: size,
            texture: Blinky.sideFrames[0],
            physicsBody: physicsBody,
            direction: .right
        )

        self.zPosition = 4
    }

    required init?(coder aDecoder: NSCoder) {
        // TODO: Does this need a proper implementation?
        super.init(coder: aDecoder)
    }

    override func update() {
        super.update()

        // switch direction at corners
        if self.yIsClose(to: 15) && (
            self.xIsClose(to: 214) || self.xIsClose(to: 642)
        ) {
            if self.canChangeDirection {
                self.canChangeDirection = false
                let newDirection = self.findShortestPath()
                if newDirection != self.direction {
                    self.changeDirection(to: newDirection)
                }
            }
        } else { self.canChangeDirection = true }

        var speed: CGFloat = 1

        // increase speed when we've eaten enough dots
        if self.movementSpeed == .medium {
            speed *= 1.05
        } else if self.movementSpeed == .fast {
            speed *= 1.05 * 1.05
        }

        // decrease speed in tunnels
        if (self.position.x < 50 || self.position.y > 650 ||
            self.position.y < 14 || self.position.y > 16) {
            speed -= 0.1
        }

        if level > 10 {
            speed *= 1.05
        }
        if level > 15 {
            speed *= 1.05
        }
        if level > 20 {
            speed *= 1.05
        }


        switch self.direction {
        case .up:
            self.position.y += speed
        case.down:
            self.position.y -= speed
        case .left:
            self.position.x -= speed
        case .right:
            self.position.x += speed
        }
    }

    private func findShortestPath() -> Direction {
        var distances = [CGFloat]() // up, left, down, right

        let blinkySquare = self.currentSquare()
        let pacmanSquare = pacman.currentSquare()

        let xDifferenceSqr = pow(blinkySquare.x - pacmanSquare.x, 2)
        let yDifferenceSqr = pow(blinkySquare.y - pacmanSquare.y, 2)

        let rightDifferenceSqr = pow((blinkySquare.x + 1) - pacmanSquare.x, 2)
        let leftDifferenceSqr = pow((blinkySquare.x - 1) - pacmanSquare.x, 2)
        let upDifferenceSqr = pow((blinkySquare.y + 1) - pacmanSquare.y, 2)
        let downDifferenceSqr = pow((blinkySquare.y - 1) - pacmanSquare.y, 2)

        switch self.direction {
        case .up:
            distances = [
                xDifferenceSqr + upDifferenceSqr,
                -1.0,
                yDifferenceSqr + leftDifferenceSqr,
                yDifferenceSqr + rightDifferenceSqr
            ]
        case .down:
            distances = [
                -1.0,
                xDifferenceSqr + downDifferenceSqr,
                yDifferenceSqr + leftDifferenceSqr,
                yDifferenceSqr + rightDifferenceSqr
            ]
        case .left:
            distances = [
                xDifferenceSqr + upDifferenceSqr,
                xDifferenceSqr + downDifferenceSqr,
                yDifferenceSqr + leftDifferenceSqr,
                -1.0
            ]
        case .right:
            distances = [
                xDifferenceSqr + upDifferenceSqr,
                xDifferenceSqr + downDifferenceSqr,
                -1.0,
                yDifferenceSqr + rightDifferenceSqr
            ]
        }

        var minDistance: CGFloat = distances[0]
        var directionIndex: Int = 0

        for (index, distance) in distances.enumerated() {
            if minDistance < 0 || (distance >= 0 && distance < minDistance) {
                minDistance = distance
                directionIndex = index
            }
        }

        return [.up, .down, .left, .right][directionIndex]
    }

    private func changeDirection(to newDirection: Direction) {
        switch newDirection {
        case .up:
            if self.action(forKey: "moveHorizontal") != nil {
                self.removeAction(forKey: "moveHorizontal")
            }
            else if self.action(forKey: "moveDown") != nil {
                self.removeAction(forKey: "moveDown")
            }

            if self.action(forKey: "moveUp") == nil {
                self.run(
                    SKAction.repeatForever(SKAction.animate(
                        with: Blinky.upFrames,
                        timePerFrame: 0.05,
                        resize: false,
                        restore: true
                    )),
                    withKey: "moveUp"
                )
            }
            if self.xIsClose(to: 214) {
                self.position.x = 214
            } else {
                self.position.x = 642
            }
        case .down:
            if self.action(forKey: "moveHorizontal") != nil {
                self.removeAction(forKey: "moveHorizontal")
            }
            else if self.action(forKey: "moveUp") != nil {
                self.removeAction(forKey: "moveUp")
            }

            if self.action(forKey: "moveDown") == nil {
                self.run(
                    SKAction.repeatForever(SKAction.animate(
                        with: Blinky.downFrames,
                        timePerFrame: 0.05,
                        resize: false,
                        restore: true
                    )),
                    withKey: "moveDown"
                )
            }
            if self.xIsClose(to: 214) {
                self.position.x = 214
            } else {
                self.position.x = 642
            }
        case .left, .right:
            if self.action(forKey: "moveUp") != nil {
                self.removeAction(forKey: "moveUp")
            }
            else if self.action(forKey: "moveDown") != nil {
                self.removeAction(forKey: "moveDown")
            }

            if self.action(forKey: "moveHorizontal") == nil {
                self.run(
                    SKAction.repeatForever(SKAction.animate(
                        with: Blinky.sideFrames,
                        timePerFrame: 0.05,
                        resize: false,
                        restore: true
                    )),
                    withKey: "moveHorizontal"
                )
            }
            self.position.y = 15
            if newDirection == .right {
                self.xScale = 1
            } else {
                self.xScale = -1
            }
        }

        self.direction = newDirection
    }
}
