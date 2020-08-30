//
//  ViewController.swift
//  Pac-Bar
//
//  Created by Henry Franks on 21/11/16.
//  Copyright © 2016 Henry Franks. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    func createTextField(
        origin: CGPoint,
        size: CGSize,
        fontSize: CGFloat,
        stringValue: String
    ) -> NSTextField {
        let field = NSTextField(frame: NSRect(origin: origin, size: size))
        field.font = .systemFont(ofSize: fontSize)
        field.alignment = NSTextAlignment.center
        field.isBezeled = false
        field.drawsBackground = false
        field.isEditable = false
        field.isSelectable = false
        field.stringValue = stringValue
        field.textColor = NSColor.yellow
        return field
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = CGColor(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 1.0
        )
        
        // Warning/Score text field
        textField = self.createTextField(
            origin: CGPoint(x: 0, y: 70),
            size: CGSize(
                width: self.view.frame.width,
                height: 80
            ),
            fontSize: 30,
            stringValue: "You need a Touch Bar"
        )
        
        // High score text field
        highField = self.createTextField(
            origin: CGPoint(x: 0, y: 10),
            size: CGSize(
                width: self.view.frame.width,
                height: 50
            ),
            fontSize: 25,
            stringValue: ""
        )
        
        self.view.addSubview(textField)
        self.view.addSubview(highField)
    }
}
