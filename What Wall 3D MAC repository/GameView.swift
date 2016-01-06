//
//  GameView.swift
//  What Wall 3D MAC repository
//
//  Created by Edmond on 1/5/16.
//  Copyright (c) 2016 Future. All rights reserved.
//

import SceneKit

class GameView: SCNView {
    
    override func mouseUp(theEvent: NSEvent) {
        super.mouseUp(theEvent)
        self.nextResponder!.mouseUp(theEvent)
        
    }
   
    override func keyDown(theEvent: NSEvent) {
        //super.keyDown(theEvent)
        self.nextResponder!.keyDown(theEvent)
        //gameScene.keyDown(theEvent)
    }
    
    override func keyUp(theEvent: NSEvent) {
        //super.keyUp(theEvent)
        self.nextResponder!.keyUp(theEvent)
        //gameScene.keyUp(theEvent)
    }

}
