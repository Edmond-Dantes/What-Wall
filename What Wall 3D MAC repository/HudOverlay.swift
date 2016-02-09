//
//  HudOverlay.swift
//  What Wall 3D MAC
//
//  Created by Edmond on 12/25/15.
//  Copyright (c) 2015 Future. All rights reserved.
//

import Foundation
import SpriteKit
import Cocoa



class HudOverlay: SKScene {
    
    var restartLabel:SKLabelNode = SKLabelNode()
    var levelNumberLabel:SKLabelNode = SKLabelNode()
    var dogdeCountLabel:SKLabelNode = SKLabelNode()
    var level:Int = 1
    var stage:Int = 0
    var hasMoveToView:Bool = true

    override init(size: CGSize) {
        super.init(size: size)//override func didMoveToView(view: SKView) {
        
        self.level = LEVEL
        //self.stage = STAGE
        
        
        
        //self.levelNumberLabel = myLevelNumberLabel
        self.levelNumberLabel.fontName = "DINAlternate-Bold"//"Chalkduster"
        self.levelNumberLabel.fontSize = 60//65
        self.levelNumberLabel.position = CGPoint(x: self.frame.width/5, y: self.frame.height/10 )//cornerBlockFrame.height)
        self.levelNumberLabel.fontColor = SKColor.orangeColor()
        self.levelNumberLabel.alpha = 1//0.5
        self.levelNumberLabel.hidden = false //true
        self.levelNumberLabel.text = "LEVEL \(LEVEL)"
        
        //self.restartLabel = myRestartLabel
        self.restartLabel.fontName = "DINAlternate-Bold"//"Chalkduster"
        self.restartLabel.fontSize = 60//65
        self.restartLabel.text = "RESTART";
        self.restartLabel.position = CGPoint(x: 4 * self.frame.width/5, y: self.frame.height/10)
        self.restartLabel.fontColor = SKColor.orangeColor()
        self.restartLabel.hidden = false //true
        
        
        
        self.levelNumberLabel.removeFromParent()
        self.restartLabel.removeFromParent()
        self.addChild(self.levelNumberLabel)
        self.addChild(self.restartLabel)
        
        
        
        //self.resignFirstResponder()
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseUp(theEvent: NSEvent) {
        super.mouseUp(theEvent)
//        self.view!.nextResponder!.mouseUp(theEvent)
        
    }
    
    override func mouseDown(theEvent: NSEvent) {
        Swift.print("mouseDown - HudOverlay")
        super.mouseDown(theEvent)
        //Swift.print("\(self.nextResponder)")
        
        
    }

    
    
    override func keyDown(theEvent: NSEvent) {
        //gameScene.keyDown(theEvent)
        Swift.print("KeyDown - HudOverlay")
        super.keyDown(theEvent)
    }
    
    override func keyUp(theEvent: NSEvent) {
        //gameScene.keyUp(theEvent)
        super.keyUp(theEvent)
    }
    
    override func update(currentTime: NSTimeInterval) {

       /* if hasMoveToView{
            self.didMoveToView(self.view!)
            hasMoveToView = false
        }
        */
        
        self.levelNumberLabel.text = myLevelNumberLabel.text
        //self.levelNumberLabel.hidden = myLevelNumberLabel.hidden
        //self.levelNumberLabel.alpha = myLevelNumberLabel.alpha
        
        self.restartLabel.text = myRestartLabel.text
        //self.restartLabel.hidden = myRestartLabel.hidden
        //self.restartLabel.alpha = myRestartLabel.alpha
 
    }
    
    override func didEvaluateActions() {
    
    }
    
    override func didSimulatePhysics() {
        
    }
    
    override func didApplyConstraints() {
        
    }
    
    override func didFinishUpdate() {
        
    }
    
    
    

}