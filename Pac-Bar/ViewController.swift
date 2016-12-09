//
//  ViewController.swift
//  Pac-Bar
//
//  Created by Henry Franks on 21/11/16.
//  Copyright © 2016 Henry Franks. All rights reserved.
//

import Cocoa

public var textField: NSTextField?

class ViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.wantsLayer = true
		self.view.layer?.backgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1.0)
		let font: NSFont = .systemFont(ofSize: 30)
		textField = NSTextField(frame: NSRect(x: 0, y: 30, width: self.view.frame.width, height: 80))
		textField!.font = font
		textField!.alignment = NSTextAlignment.center
		textField!.isBezeled = false
		textField!.drawsBackground = false
		textField!.isEditable = false
		textField!.isSelectable = false
		textField!.stringValue = "You need a TouchBar"
		textField!.textColor = NSColor.yellow
		self.view.addSubview(textField!)
		// Do any additional setup after loading the view.
	}

	public func updateLabel(Score: Int) {
		//label.stringValue = String(describing: Score)
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}
