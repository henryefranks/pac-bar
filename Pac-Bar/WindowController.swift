//
//  WindowController.swift
//  Pac-Bar
//
//  Created by Henry Franks on 21/11/16.
//  Copyright © 2016 Henry Franks. All rights reserved.
//

import Cocoa
import SpriteKit

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBar.CustomizationIdentifier {
    static let customizationIdentifier = """
    com.henryefranks.touchbar.customizationIdentifier
    """
}

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItem.Identifier {
    static let identifier = NSTouchBarItem.Identifier(
        "com.henryefranks.touchbar.items.identifier")
}

class WindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.title = "Pac-Bar"
        self.window?.titleVisibility = .hidden
        self.window?.titlebarAppearsTransparent = true
        self.window?.styleMask.insert(.fullSizeContentView)
        self.window?.styleMask.remove(.resizable)
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .customizationIdentifier
        touchBar.defaultItemIdentifiers = [.identifier]
        touchBar.customizationAllowedItemIdentifiers = [.identifier]
        return touchBar
    }
    
    @IBOutlet public weak var mainView: NSWindow!
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        //Control Pac-Man movement
        case 123:
            //left
            if horizontalMove {
                up = false
                down = false
            }
            direction = false
            horizontalWait = true
            counter = 15
        case 124:
            //right
            if horizontalMove {
                up = false
                down = false
            }
            direction = true
            horizontalWait = true
            counter = 15
        case 125:
            //down
            down = true
            up = false
            counter = 15
        case 126:
            //up
            up = true
            down = false
            counter = 15
        default:
            break
        }
    }
}

@available(OSX 10.12.2, *)
extension WindowController: NSTouchBarDelegate {
    
    func touchBar(
        _ touchBar: NSTouchBar,
        makeItemForIdentifier identifier: NSTouchBarItem.Identifier
    ) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.identifier:
            let gameView = SKView()
            let scene = GameScene()
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = gameView
            gameView.presentScene(scene)
            return item
        default:
            return nil
        }
    }
}
