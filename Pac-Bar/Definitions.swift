//
//  Definitions.swift
//  Pac-Bar
//
//  Created by Henry Franks on 18/12/2019.
//  Copyright © 2019 Henry Franks. All rights reserved.
//

import Cocoa

let POS_EPS: CGFloat = 0.5 // epsilon for position checking accuracy
let SQUARE_SIZE: CGFloat = 14

public var textField: NSTextField!
public var highField: NSTextField!

var counter: Int = 15 // To acount for awkwardness in controls
var directionCache: Direction? = nil

struct gamePhysics {
    static let PacMan: UInt32 = 1
    static let Dot: UInt32 = 2
    static let Blinky: UInt32 = 4
}

enum GameState {
    case introAnimation, playing, gameOverAnimation, waitingForRestart
}

protocol DetailsDelegate: class {
    func updateLabel(Score: Int)
}

var highScore: Int {
    set {
        UserDefaults.standard.set(newValue, forKey: "highScore")
        UserDefaults.standard.synchronize()
    }
    
    get {
        return UserDefaults.standard.object(forKey: "highScore") as? Int ?? 0
    }
}

let pacman = PacMan()
let blinky = Blinky()
