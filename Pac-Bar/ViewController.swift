//
//  ViewController.swift
//  Pac-Bar
//
//  Created by Henry Franks on 21/11/16.
//  Copyright © 2016 Henry Franks. All rights reserved.
//

import Cocoa

public var textField: NSTextField!
public var highField: NSTextField!

var highScore: Int {
	set {
		UserDefaults.standard.set(newValue, forKey: "highScore")
		UserDefaults.standard.synchronize()
	}

	get {
		return UserDefaults.standard.object(forKey: "highScore") as? Int ?? 0
	}
}

class ViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.wantsLayer = true
		self.view.layer?.backgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1.0)
		textField = NSTextField(frame: NSRect(x: 0, y: 70, width: self.view.frame.width, height: 80))
		textField!.font = .systemFont(ofSize: 30)
		textField!.alignment = NSTextAlignment.center
		textField!.isBezeled = false
		textField!.drawsBackground = false
		textField!.isEditable = false
		textField!.isSelectable = false
		textField!.stringValue = "You need a Touch Bar"
		textField!.textColor = NSColor.yellow
		self.view.addSubview(textField!)
		highField = NSTextField(frame: NSRect(x: 0, y: 10, width: self.view.frame.width, height: 50))
		highField!.font = .systemFont(ofSize: 25)
		highField!.alignment = NSTextAlignment.center
		highField!.isBezeled = false
		highField!.drawsBackground = false
		highField!.isEditable = false
		highField!.isSelectable = false
		highField!.stringValue = ""
		highField!.textColor = NSColor.yellow
		self.view.addSubview(highField!)
		// Do any additional setup after loading the view.
	}
}
