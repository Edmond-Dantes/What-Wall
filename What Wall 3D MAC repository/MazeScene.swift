//
//  MazeScene.swift
//  Roly Moly
//
//  Created by Future on 1/19/15.
//  Copyright (c) 2015 Future. All rights reserved.
//

import Foundation
import SpriteKit
import Cocoa


//let gameFrame:CGRect = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)

//var myMazeBorder:SKNode = SKNode()
//let MAX_DEADENDS = 10

//let MAZE_ROWS:Int = (5 + MAX_DEADENDS/2) * 2 + 1
//let MAZE_COLUMNS:Int = (5 + MAX_DEADENDS/2) * 2 + 1
//let MAX_TURNABLE_CELLS = 100000//Int(MAZE_ROWS/2) * Int(MAZE_COLUMNS/2)

//var myEffectNodeGridResult = [SKNode]()
//var myPhysicsMazeGrid = [SKNode]()
var mySimpleMazeCalculator = [Int]()

var myMaze:Maze? = nil

//enum CollisionType:UInt32{
//    case activeWall = 0b100, staticWall = 0b010, player = 0b001
//}


//var myMazeCellSize:CGSize = CGSize(width: gameFrame.width / CGFloat(MAZE_ROWS), height: gameFrame.height / CGFloat(MAZE_COLUMNS))
//var myRandomOrderedMazeDirections:[MazeCell.wallLocations] = [ .up, .down, .left, .right ]





class MazeScene: SKScene, SKPhysicsContactDelegate {
    
    
    //let controller:JoyStick = JoyStick()
   // var playerDirectionVector:CGVector = CGVector(dx: 0, dy: 0)
    var allLevelMazes = [Maze]()
    //var finalDisplayedMazeImage = SKEffectNode()
    
    var level:Int = 1
    var stage:Int = 0
    //var mazeCellSize:CGfloat = 0
    
    var isStageBlinking: Bool = false
    var isViewingMap: Bool = false
    var isChangingScene: Bool = false
    
    let levelNumberView = SKLabelNode(fontNamed: "Chalkduster")
    
    override func didMoveToView(view: SKView) {
        
        
        
        isStageBlinking = false
        let currentStage = myMaze?.escapePath[self.stage * 2]
        myMaze?.mazeCellMatrix[currentStage!].alpha = 1.0
        
        isViewingMap = true
        self.runAction(SKAction.waitForDuration(1)){
            
            self.isViewingMap = false
        }
        
        
        //self.level = LEVEL
        self.stage = STAGE
        if myMaze == nil{
        myMaze = Maze(level: CGFloat(level))
        
        //allLevelMazes.append(myMaze)
        self.addChild(myMaze!)
//*********            self.addChild(levelNumberView)
        }else{
            if self.level != LEVEL{
                self.level = LEVEL
                myMaze?.removeFromParent()
                myMaze = Maze(level: CGFloat(level))
                self.addChild(myMaze!)
                levelNumberView.removeFromParent()
//*********                self.addChild(levelNumberView)
            }
        }
        
        //let levelNumberView = SKLabelNode(fontNamed: "Chalkduster")
        
        //restartView.fontName = "Chalkduster"
        levelNumberView.fontSize = 20//65
        levelNumberView.text = "LEVEL \(self.level)";
        //restartView.s frame = self.view!.frame//CGRect(x: 25, y: 100, width: 500, height: 500)
        //myLabel.fontSize = 65;
        levelNumberView.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - cornerBlockFrame.height)
        //restartView.backgroundColor = Color.clearColor()
        levelNumberView.fontColor = SKColor.whiteColor()
        levelNumberView.alpha = 0.5
        // myRestartView.center = self.view.convertPoint(CGPoint(x: gameFrame.width/2, y: gameFrame.height/2), toView: myRestartView)
        //skView.addSubview(myRestartView)
        //restartView.zPosition = 1000
        levelNumberView.hidden = false //true
        levelNumberView.name = "world"
        levelNumberView.zPosition = -100
        
        
        
        
                
        
    }
    
    
    
    
    //------------------------------------------
    //--------------UPDATES--------------------
    //------------------------------------------
    
    
    
    override func keyDown(theEvent: NSEvent) {
        
        let key = theEvent.keyCode
//        if controller.joyStickDirection == .neutral{
            
            switch key{
            case 126://up
//                controller.joyStickDirection = .up
                print("\(key) up")
                if !isViewingMap{
                     //*************************
                    let currentStage = myMaze?.escapePath[self.stage * 2]
                    myMaze?.mazeCellMatrix[currentStage!].alpha = 1.0
                    if isStageBlinking{
                        
                        self.removeAllActions()
                    }
                    
                    isChangingScene = true
                }
            case 124://right
//                controller.joyStickDirection = .right
                print("\(key) right")
            case 125://down
//                controller.joyStickDirection = .down
                print("\(key) down")
            case 123://left
//                controller.joyStickDirection = .left
                print("\(key) left")
            default:
                break
            }
 //       }
        
        
        //println("\(key)")
        
        
        
        
    }
    
    override func keyUp(theEvent: NSEvent) {
        //
        let key = theEvent.keyCode
    /*
        switch key{
        case 126://up
            
            
        case 124://right

            
        case 125://down

            
        case 123://left

        default:
            break
        }
        
    */
    }
    

   
    
    
    override func update(currentTime: NSTimeInterval) {
        
        
        if !isStageBlinking{
            isStageBlinking = true
            let currentStage = myMaze?.escapePath[self.stage * 2]
            myMaze?.mazeCellMatrix[currentStage!].runAction(SKAction.fadeOutWithDuration(0.5)){
                myMaze?.mazeCellMatrix[currentStage!].runAction(SKAction.fadeInWithDuration(0.5)){
                    self.isStageBlinking = false
                }
            }
        }
        

        
    }
    
    override func didEvaluateActions() {
        
        
        
    }
    
    override func didSimulatePhysics() {
        
    }
    
    override func didApplyConstraints() {
        
    }
    
    override func didFinishUpdate() {
        if isChangingScene{
            
            isStageBlinking = false
            isChangingScene = false
            
//*****            self.view?.presentScene(gameScene)
            
        }
    }
    
}