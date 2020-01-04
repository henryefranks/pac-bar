//
//  Definitions.swift
//  Pac-Bar
//
//  Created by Henry Franks on 18/12/2019.
//  Copyright © 2019 Henry Franks. All rights reserved.
//

import Cocoa

public var textField: NSTextField!
public var highField: NSTextField!

var direction: Bool = true //true=right, false=left
var up: Bool = false //trigger to wait until corner reached
var down: Bool = false //ditto
var horizontalWait: Bool = false
var horizontalMove = true
var counter: Int = 15 //To acount for awkwardness in controls

struct gamePhysics {
	static let PacMan: UInt32 = 1
	static let Dot: UInt32 = 2
	static let Blinky: UInt32 = 4
}

enum GameState {
	case intro, playing
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
