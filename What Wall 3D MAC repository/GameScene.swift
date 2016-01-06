//
//  GameScene.swift
//  Roly Moly
//
//  Created by Future on 10/27/14.
//  Copyright (c) 2014 Future. All rights reserved.
//

import Foundation
import SpriteKit
import Cocoa

//let gameFrame:CGRect = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
//let cornerBlockFrame:CGRect = CGRect(x: 0.0, y: 0.0, width: gameFrame.width / 10, height: gameFrame.height / 10)

//Dictionary to hold the corner block objects
var myCorners:[CornerBlock.cornerPosition: CornerBlock] = [:]
var myPresentationCorners:[CornerBlock.cornerPosition: CornerBlock] = [:]
    
var mySmashBlocks:[SmashBlock.blockPosition : SmashBlock] = [:]
var myPresentationSmashBlocks:[SmashBlock.blockPosition : SmashBlock] = [:]
//let circleShape = SKShapeNode(circleOfRadius: 40)


var myPlayer:Player? = nil
var myPresentationPlayer:Player? = nil

//var myMaze = Maze()
//var myLevelMazeGrid = [SKNode]()
//var myMazeCalculator = [Int]()

//let circle:SKShapeNode? = nil

enum CollisionType:UInt32{
    case activeWall = 0b100, staticWall = 0b010, player = 0b001
}


enum keys{
    case left,right,up,down
}

var isKeyPressed:[keys:Bool] = [keys.left: false, .right: false, .up: false, .down: false]


var myEmitterNode:SKEmitterNode? = nil

var myGravityFieldNode = SKFieldNode()


var LEVEL:Int = 1
var STAGE:Int = 0
//var levelExitArray:[SmashBlock.blockPosition] = []



//#if os(iOS)

var myRestartLabel:SKLabelNode = SKLabelNode()
var myLevelNumberLabel:SKLabelNode = SKLabelNode()

//var myJoyStickView = NSView()
//var myJoyStick = NSImageView()
//var myJoyStickLocation:CGPoint? = nil
//var myJoyStickTime:NSTimeInterval? = nil

extension SKSpriteNode{
  //????
    var center:CGPoint{
        get{
            return CGPoint(x: self.position.x - self.frame.width/2, y: self.position.y + self.frame.height/2)
        }
        set{
            //self.center = CGPoint(x: newValue.x, y: newValue.y)
            self.position = CGPoint(x: newValue.x + self.frame.width/2, y: newValue.y - self.frame.height/2)
        }
    }
    
}


private let MATH_PI:CGFloat = CGFloat(M_PI)

let SPEED_PERCENTAGE:CGFloat = 0.5//1//0.25

private let CONSTANT_WALLSPEED:CGFloat = 1000 * SPEED_PERCENTAGE


class GameScene: SKScene, SKPhysicsContactDelegate {
    //private let CONSTANT_WALLSPEED = 1000
    private var level:Int = 1
    //private var levelExitsArray:[SmashBlock.blockPosition] = SmashBlock.levelExitArray(1)//self.level)
    private var stageCount:Int = 0
    private let entranceTime: NSTimeInterval = 0.5 / NSTimeInterval(SPEED_PERCENTAGE)
    
    private var exitBlock: SmashBlock.blockPosition = SmashBlock.blockPosition.bottomLeft
    private let exitBlockColor: SKColor = SKColor.blueColor()
    private let wallColor: SKColor = SKColor.yellowColor()
    private let smashingColor: SKColor = SKColor.redColor()
    private let cornerColor: SKColor = SKColor.blueColor()
    
    /*private*/ var hasWorldMovement:Bool = true//false//true
    /*private*/ var isFirstRound: Bool = true //*****don't change value
    private var isFirstRoundStarted: Bool = false //*****don't change value
    private var isEdgeHitDeathOn: Bool = false//true //false
    private var playerScore:Int = 0
    private var isPlayerTouched: Bool = false //*****don't change value
    //private var isTouchingActiveWall: Bool = true
    
    /*private*/ var isMovingToNextArea: Bool = false
    private var islevelChange:Bool = false
    var isSlowedDown:Bool = false
    
    let controller:JoyStick = JoyStick()
    
    private var WALLSPEED:CGFloat = CONSTANT_WALLSPEED
    private let DEATHVELOCITY:CGFloat = 900
    private var smashBlockStatus: SmashBlock.activity = .waiting
    private var smashStatusChanged: Bool = false
    private var activeSmashBlock: SmashBlock.blockPosition? = nil
    private var oldSmashBlock: SmashBlock.blockPosition? = nil
    private var arrayOfBlocks: [SmashBlock.blockPosition] = SmashBlock.random8array()
    private var restingSmashBlockPosition: CGPoint? = nil
    private var pauseSmashBlockLogic:Bool = false
    
    /*private*/ var deltaTime: CFTimeInterval = 0.0
    /*private*/ var lastUpdatedTime: CFTimeInterval = 0.0
    private var wallTimer: CFTimeInterval = 0.0
    
    /*private*/ var deathTimer: CFTimeInterval = 0.0
    
    
    private var playerHitAndDirection = (hit: false, vertical: false)
    
    
    private var world = SKNode()
    
    

    
    override init(size: CGSize) {
        super.init(size: size)//override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //self.level = LEVEL
        //self.stageCount = STAGE
        
        self.backgroundColor = SKColor.clearColor()
        
        myLevelNumberLabel.text = "LEVEL \(LEVEL)";
        
        if islevelChange{
            isFirstRound = true
            isFirstRoundStarted = false
            if let player = myPlayer{
                
                player.isAlive = false
                //player.isDying = true
                //player.justDied = true
                player.contactActive = false
                //player.deathPosition = player.position
                player.removeFromParent()
                myPresentationPlayer?.removeFromParent()
            }
            reloadSceneTime()
            
            islevelChange = false
        }
        
        if myPlayer == nil{
            
        
        //Level # textbox
        let levelNumberView = SKLabelNode(fontNamed: "Chalkduster")
        
        //restartView.fontName = "Chalkduster"
        levelNumberView.fontSize = 20//65
        //levelNumberView.text = "LEVEL \(LEVEL)";
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
        myLevelNumberLabel = levelNumberView
        myLevelNumberLabel.name = "world"
        myLevelNumberLabel.zPosition = -100
        world.addChild(myLevelNumberLabel)
        myLevelNumberLabel.text = "LEVEL \(LEVEL)"
/************/
            myLevelNumberLabel.hidden = true
/************/
        //Single smash trap box area contained in a SKSpriteNode
        
        
        //Dictionary to hold the corner block objects
        myCorners = [
            CornerBlock.cornerPosition.leftTop: CornerBlock(cornerPos: .leftTop, color: self.cornerColor),
            .leftBottom: CornerBlock(cornerPos: .leftBottom, color: self.cornerColor),
            .rightTop: CornerBlock(cornerPos: .rightTop, color: self.cornerColor),
            .rightBottom: CornerBlock(cornerPos: .rightBottom, color: self.cornerColor)
        ]
        
        myPresentationCorners = [
            CornerBlock.cornerPosition.leftTop: myCorners[.leftTop]!.clone(),
            .leftBottom: myCorners[.leftBottom]!.clone(),
            .rightTop: myCorners[.rightTop]!.clone(),
            .rightBottom: myCorners[.rightBottom]!.clone()
        ]
        
        //for-in loop to add the corners to the scene
        for (position ,corner) in myCorners {
            self.addChild(corner)
            world.addChild( myPresentationCorners[position]! )
        }
        
        
        //---------------------
        //smashing block objects
      
        
        //Dictionary to hold the SMASH block objects
        let smashBlockArray = SmashBlock.array
        for bPosition in smashBlockArray{
            mySmashBlocks[bPosition] =  SmashBlock(blockPos: bPosition, color: self.wallColor)
        myPresentationSmashBlocks[bPosition] = mySmashBlocks[bPosition]!.clone()
        }
        
        for (position ,smashBlock) in mySmashBlocks {
            self.addChild(smashBlock)
            self.physicsWorld.addJoint(smashBlock.slidingJoint)
            world.addChild(myPresentationSmashBlocks[position]!)
        }
        self.activeSmashBlock = arrayOfBlocks[blockArrayCounter]
        print( "\(self.activeSmashBlock!.rawValue)")
        
        mySmashBlocks[self.activeSmashBlock!]?.color = self.smashingColor
        
        //mySmashBlocks[self.exitBlock]!.color = self.exitBlockColor
        
/******///self.exitBlock = SmashBlock.randomBlockPosition()
        
        //-------------------
        // Load Player
        myPlayer = Player()
        if let player = myPlayer{
        //self.addChild(player)
        myPresentationPlayer = player.clone()
        //world.addChild(myPresentationPlayer!)
        }
        myPlayer?.hidden = true
        
        
        //Contact and Collison Delegate setting
        physicsWorld.contactDelegate = self
        
        //Load view Text for restart
        
        let restartView = SKLabelNode(fontNamed: "Chalkduster")
        
        //restartView.fontName = "Chalkduster"
        restartView.fontSize = 20//65
        restartView.text = "RESTART";
        //restartView.s frame = self.view!.frame//CGRect(x: 25, y: 100, width: 500, height: 500)
        //myLabel.fontSize = 65;
        restartView.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        //restartView.backgroundColor = Color.clearColor()
        restartView.fontColor = SKColor.whiteColor()
        // myRestartView.center = self.view.convertPoint(CGPoint(x: gameFrame.width/2, y: gameFrame.height/2), toView: myRestartView)
        //skView.addSubview(myRestartView)
        //restartView.zPosition = 1000
            
/************/
        restartView.hidden = true
/************/
        
        myRestartLabel = restartView
        myRestartLabel.name = "world"
        self.addChild(restartView)
        
        //world.addChild(restartView)
        
        //Load view for Joystick play
        
//        self.controller.loadJoystick(sceneView: self.view!)
        
//        myJoyStickView = controller.joyStickView
//        myJoyStick = controller.joyStick
        /*
        let joyStickView = SKSpriteNode()
        let joyStick = SKSpriteNode(imageNamed: /*SKTexture(imageNamed:*/ "bluecircle")
        let height = (self.view!.bounds.height - self.view!.bounds.width)/2
        joyStickView.size = CGSize(width: height, height: height)
        joyStickView.position = CGPoint(x: self.view!.bounds.width/2 - height/2, y: self.view!.bounds.height - height)
        joyStickView.color = Color.orangeColor()
        self.addChild(joyStickView)
        joyStick.size = CGSize(width: joyStickView.frame.width/3, height: joyStickView.frame.height/3)
        joyStick.position = CGPoint(x: joyStickView.frame.width/2, y: joyStickView.frame.height/2)
        joyStickView.addChild(joyStick)
        
        myJoyStickView = joyStickView
        myJoyStick = joyStick
        */
        
            //-------------------
            // Load Gravity
            self.physicsWorld.gravity = CGVector(dx: 0*9.8, dy: 0*9.8)
            
            let gravityField = SKFieldNode.radialGravityField()
            gravityField.position = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
            gravityField.strength = 9.8 * Float(SPEED_PERCENTAGE)
            gravityField.falloff = 0
            //gravityField.minimumRadius = 30
            gravityField.categoryBitMask = CollisionType.player.rawValue
            myGravityFieldNode = gravityField
            self.addChild(gravityField)
            
            
        
        //Load Particle Emmitter
        let burstPath = NSBundle.mainBundle().pathForResource("MyParticle",
            ofType: "sks")
        
        let burstNode = NSKeyedUnarchiver.unarchiveObjectWithFile(burstPath!)
            as! SKEmitterNode
        
        myEmitterNode = burstNode
        
        if let burst = myEmitterNode{
            self.addChild(burst)
            burst.position = CGPoint(x: 100, y: 100)
            burst.fieldBitMask = CollisionType.player.rawValue
            burst.advanceSimulationTime(2)
            burst.targetNode = self
        }
        
        //my Maze
//        self.addChild(myMaze)
            if myMaze == nil{
                myMaze = Maze(level: CGFloat(self.level))
                
                
            }else{
                if self.level != LEVEL{
                    self.level = LEVEL
                    // myMaze?.removeFromParent()
                    myMaze = Maze(level: CGFloat(self.level))
                }
            }
        
        //LOAD WORLD
        
        world.name = "world"
        self.addChild(world)
        for node in self.children {
            let child = node 
            if child.name != "world"{
                child.hidden = true
            }
        }
        world.hidden = false
        myEmitterNode!.hidden = false
        
        
        //self.speed = SPEED_PERCENTAGE
        
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func slowDownSceneTime(){
        WALLSPEED /= 100
        myGravityFieldNode.strength = 0//  /= 5
        world.runAction(SKAction.fadeAlphaTo(0.5, duration: 1))
        self.isSlowedDown = true
    }
    
    private func reloadSceneTime() {
        WALLSPEED = CONSTANT_WALLSPEED
        myGravityFieldNode.strength = 9.8 * Float(SPEED_PERCENTAGE)
        mySmashBlocks[self.exitBlock]?.color = self.wallColor
        /******/self.exitBlock = myMaze!.levelExitArray[self.stageCount * 2]//self.levelExitsArray[self.stageCount]//SmashBlock.randomBlockPosition()
        arrayOfBlocks.shuffle()
        //mySmashBlocks[self.exitBlock]?.color = self.exitBlockColor
        
        world.runAction(SKAction.fadeInWithDuration(0))
        //        self.view?.transform = CGAffineTransformMakeRotation(0)
        wallTimer = 0
        smashBlockStatus = .waiting
        smashStatusChanged = true
        if let smashBlock = mySmashBlocks[self.activeSmashBlock!]{
            smashBlock.position = smashBlock.orginalPosition
        }
        updatePresentationLayer()
    }
    
    func updateLevelMaze(level:Int){
        
        myMaze = Maze(level: CGFloat(level))
        //self.addChild(myMaze)
    }
    
    private func moveTrapLayoutBy(x:CGFloat, y:CGFloat, duration: NSTimeInterval) {
        /*
      //  self.position
        
        
        //---------------------
        //corner blocks
        for (_ ,corner) in myCorners {
            
            //corner.position.x += x
            //corner.position.y += y
            
            corner.runAction(SKAction.moveToX(x, duration: duration))
            corner.runAction(SKAction.moveToY(y, duration: duration))
        }
        
        
        //---------------------
        //smashing block objects

        for (_ ,smashBlock) in mySmashBlocks {
            
            //smashBlock.position.x += x
            //smashBlock.position.y += y
            smashBlock.runAction(SKAction.moveToX(x, duration: duration))
            smashBlock.runAction(SKAction.moveToY(y, duration: duration))
        }

        
        //return
*/
    }
    
    private func reloadOriginalTrapPositions(duration:NSTimeInterval){
        //---------------------
        //corner blocks
        for (_ ,corner) in myCorners {
            
            //corner.position = corner.originalPosition
            corner.runAction(SKAction.moveTo(corner.originalPosition, duration: duration))
        }
        
        
        //---------------------
        //smashing block objects
        
        for (_ ,smashBlock) in mySmashBlocks {
            
            //smashBlock.position = smashBlock.orginalPosition
            smashBlock.runAction(SKAction.moveTo(smashBlock.orginalPosition, duration: duration))
        }
        
      //  self.runAction(SKAction.waitForDuration(duration)){
            
       // }
    }
    
    private func updateJoyStick(){
      
        //if using a joystick display
        /*
        if let joyStickLocation = myJoyStickLocation{
            
            myGravityFieldNode.enabled = false
        
            let speed = JoyStickTouchLogic(/*stickLocation: joyStickLocation, stickCenter: CGPoint(x: myJoyStickView.frame.width/2, y: myJoyStickView.frame.height/2), stickCenterRadius: myJoyStick.frame.width/2 / 2*/)
            if myJoyStickTime < 0.5 {
                myPlayer?.physicsBody?.applyImpulse(CGVector(dx: 100 * speed.dx, dy: 100 * speed.dy))
                myJoyStickTime = nil
                myJoyStickLocation = nil
                println("FORCE")
            }
            
        }else if myJoyStickLocation == nil{
            myGravityFieldNode.enabled = true
            myJoyStick.center = CGPoint(x: myJoyStickView.frame.width/2, y: myJoyStickView.frame.height/2)
            //myJoyStick.position = CGPoint(x: myJoyStickView.frame.width/2 - myJoyStick.frame.width/2, y: myJoyStickView.frame.height/2 - myJoyStick.frame.height/2)
        }
        
        */
        
    }
    
    
    private func JoyStickTouchLogic(/*stickLocation location:CGPoint, stickCenter center:CGPoint, stickCenterRadius centerRadius:CGFloat*/)->CGVector{
        
        let pixelBuffer:CGFloat = 0
        let speed:CGFloat = 5 * SPEED_PERCENTAGE
        
        //--------------------------
        //------JoyStick Logic------
        //--------------------------
        /*
        var c = sqrt( pow(location.x - center.x , 2) + pow(location.y - center.y, 2) )
        var unitX = location.x - center.x
        var unitY = location.y - center.y
        
        var unitTargetPosition = CGPoint(x: unitX / c, y: unitY / c)
        */
        //var targetPosition = CGPoint(x: gameFrame.width/2 + gameFrame.width/2 * unitX / c, y: gameFrame.height/2 + gameFrame.height/2 * unitY / c)
        
        var targetPosition = CGPoint()
        let player = myPlayer!
        
        // add unitTargetPosition point adjustment here
        /*
        let x = unitTargetPosition.x
        let y = unitTargetPosition.y
        */
        
        if controller.isChangedDirection == true{
            myPlayer!.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            controller.isChangedDirection = false
            myGravityFieldNode.strength = 0
        }
        
        if controller.joyStickDirection == .neutral {//neutral
            targetPosition = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
            
//            myJoyStick.center = CGPoint(x: myJoyStickView.frame.width/2, y: myJoyStickView.frame.height/2)
            
        }
        else if controller.joyStickDirection == .right{//right
            //add jointStick position
            targetPosition = CGPoint(x: gameFrame.width - cornerBlockFrame.width - pixelBuffer - player.radius, y: gameFrame.height/2)
            
//            myJoyStick.center = CGPoint(x: myJoyStickView.frame.width, y: myJoyStickView.frame.height/2)
            
        }
        else if controller.joyStickDirection == .left{//left
            //add jointStick position
            targetPosition = CGPoint(x: cornerBlockFrame.width + pixelBuffer + player.radius, y: gameFrame.height/2)
            
//            myJoyStick.center = CGPoint(x: 0, y: myJoyStickView.frame.height/2)
            
        }
        else if controller.joyStickDirection == .up{//up
            //add jointStick position
            targetPosition = CGPoint(x: gameFrame.width/2, y: gameFrame.height - cornerBlockFrame.height - pixelBuffer - player.radius)
            
//            myJoyStick.center = CGPoint(x: myJoyStickView.frame.width/2, y: 0)
            
        }
        else if controller.joyStickDirection == .down{//down
            //add jointStick position
            targetPosition = CGPoint(x: gameFrame.width/2, y: cornerBlockFrame.height + pixelBuffer + player.radius)
            
//            myJoyStick.center = CGPoint(x: myJoyStickView.frame.width/2, y: myJoyStickView.frame.height)
            
        }
        
        let c:CGFloat = sqrt( pow(targetPosition.x - player.position.x , 2) + pow(targetPosition.y - player.position.y, 2) )
        let unitX:CGFloat = targetPosition.x - player.position.x
        let unitY:CGFloat = targetPosition.y - player.position.y
        
        //var target = CGRect(x: targetPosition.x , y: targetPosition.y, width: cornerBlockFrame.width, height: cornerBlockFrame.height )
        //target.midX = targetPosition.x
        //target.midY = targetPosition.y
        
        if CGRect(x: targetPosition.x - cornerBlockFrame.width, y: targetPosition.y - cornerBlockFrame.height, width: cornerBlockFrame.width * 2, height: cornerBlockFrame.height * 2 ).contains(player.position) {//&& controller.joyStickDirection != .neutral{
            if controller.joyStickDirection == .neutral{
                let velocity = player.physicsBody!.velocity
                //player.physicsBody!.velocity = CGVector(dx: velocity.dx * 0.95, dy: velocity.dy * 0.95 )
                if CGRect(x: targetPosition.x - cornerBlockFrame.width/4, y: targetPosition.y - cornerBlockFrame.height/4, width: cornerBlockFrame.width/2, height: cornerBlockFrame.height/2 ).contains(player.position){
                    player.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                    player.position = targetPosition
                }
            }else{
                player.position = targetPosition
                player.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                controller.joyStickDirection = .neutral
            }
            
            myGravityFieldNode.strength = 9.8 * Float(SPEED_PERCENTAGE)
        }
        else {
            //player.physicsBody!.velocity = CGVector(dx: DEATHVELOCITY * unitX / c, dy: DEATHVELOCITY * unitY / c)
            //player.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            if controller.joyStickDirection != .neutral{
                player.physicsBody!.applyForce(CGVector(dx: speed * unitX / c, dy: speed * unitY / c))
                print(" force =  \(speed * unitX / c), \(speed * unitY / c)")
            }
        
        }
        
        return CGVector(dx: unitX / c, dy: unitY / c)
        
    }
    
/*
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let pixelBuffer:CGFloat = 2
        
        for touch: AnyObject in touches {
            
            let location = touch.locationInNode(self)
            //touch.locatio
            
            //let insideLocation = touch.locationInView(self.view)
            var restartView = myRestartLabel
            var restartLocation:CGPoint? = touch.locationInView(restartView)
            var joyStickLocation:CGPoint? = touch.locationInView(myJoyStickView)
            
           // let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
          //  sprite.xScale = 0.5
          //  sprite.yScale = 0.5
          //  sprite.position = location
           
            
            if let player = myPlayer{
                if playerIsAlive(){
                    
                    //--------------------------
                    //------JoyStick Logic------
                    //--------------------------
                    //if myJoyStickView.pointInside(joyStickLocation!, withEvent: event){
                        
                        
                    //UIView coordinate system is y inverted compared with SKView
                    joyStickLocation!.y = myJoyStickView.frame.height - joyStickLocation!.y
                    //------------------(coordinate correction)------------------
                    
                    myJoyStickLocation = joyStickLocation
                    myJoyStickTime = event.timestamp
                    println("\(myJoyStickTime) - TOUCH BEGIN")
                    
                    
                        //JoyStickTouchLogic(stickLocation: joyStickLocation!, stickCenter: CGPoint(x: myJoyStickView.bounds.width/2, y: myJoyStickView.bounds.height/2))
                        
                    //}
                    
                    
                    //JoyStickTouchLogic(location: location, center: CGPoint(x: gameFrame.width/2, y: gameFrame.height/2))
                    
                    
                    //--------------------------
                    //------JoyStick Logic END--
                    //--------------------------
                    
                    
            
                }
                else if let labelLocation = restartLocation{
                    
                    
                        if restartView.pointInside(labelLocation, withEvent: event){
                            
                            if !player.isDying{
                                self.playerComeBackToLife(player)
                            }
                            
                        }
                    
                }
            
            }
          
        }
    }
    
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            
            
            var joyStickLocation:CGPoint? = touch.locationInView(myJoyStickView)
            
            // let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            //  sprite.xScale = 0.5
            //  sprite.yScale = 0.5
            //  sprite.position = location
            
            
            if let player = myPlayer{
                if playerIsAlive(){
                    
                    //--------------------------
                    //------JoyStick Logic------
                    //--------------------------
                   // if myJoyStickView.pointInside(joyStickLocation!, withEvent: event){
                        
                        
                        //UIView coordinate system is y inverted compared with SKView
                        joyStickLocation!.y = myJoyStickView.frame.height - joyStickLocation!.y
                        //------------------(coordinate correction)------------------
                        
                        myJoyStickLocation = joyStickLocation
                        
                  //  }
            
                }
            }
            
            
        }
        
        
        
    }
    
    
  
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        
       
        
       // myJoyStickTime = event.timestamp - myJoyStickTime!
       // println("\(myJoyStickTime) - TOUCH END")
        
        //if myJoyStickTime < 0.5{
            
        //}
        //else{
       // myJoyStickTime = nil
        myJoyStickLocation = nil
       // }
        
        myJoyStick.center = CGPoint(x: myJoyStickView.frame.width/2, y: myJoyStickView.frame.height/2)
        
        for touch: AnyObject in touches {
            
            
            
            
        }
        
    }
 */
        
         override func keyDown(theEvent: NSEvent) {
            
            let key = theEvent.keyCode
            //if controller.joyStickDirection == .neutral{
            
            //myPlayer!.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            if isMovingToNextArea{
                return
            }
            /*if myPlayer!.contactActive{
                return
            }*/
                switch key{
                case 126://up
                    if controller.joyStickDirection != .up && !isKeyPressed[.up]!{
                        controller.joyStickDirection = .up
                        print("\(key) up")
                        controller.isChangedDirection = true
                        isKeyPressed[.up] = true
                    }
                    if let player = myPlayer{
                        if !player.isDying && (!player.isAlive || isFirstRound){
//                            self.view?.presentScene(mazeScene)
                            
                        }
                    }
                case 124://right
                    if controller.joyStickDirection != .right && !isKeyPressed[.right]!{
                        controller.joyStickDirection = .right
                        print("\(key) right")
                        controller.isChangedDirection = true
                        isKeyPressed[.right] = true
                    }
                case 125://down
                    if controller.joyStickDirection != .down && !isKeyPressed[.down]!{
                        controller.joyStickDirection = .down
                        print("\(key) down")
                        controller.isChangedDirection = true
                        isKeyPressed[.down] = true
                    }
                case 123://left
                    if controller.joyStickDirection != .left && !isKeyPressed[.left]!{
                        controller.joyStickDirection = .left
                        print("\(key) left")
                        controller.isChangedDirection = true
                        isKeyPressed[.left] = true
                    }
                default:
                    //controller.joyStickDirection = .neutral
                    self.isFirstRound = false
                //***    myRestartLabel.hidden = true
                    
                    if let player = myPlayer{
                        if !player.isDying && !player.isAlive{
                            self.playerComeBackToLife(player)
                            
                        }
                    }
                    
                }
            //}
            
            //JoyStickTouchLogic()
            //println("\(key)")
            
            
            
            
        }
        
        override func keyUp(theEvent: NSEvent) {
            //
            let key = theEvent.keyCode
            
            switch key{
            
            
            case 126://up
                isKeyPressed[.up] = false
                
            case 124://right
                isKeyPressed[.right] = false
                
            case 125://down
                isKeyPressed[.down] = false
                
            case 123://left
                isKeyPressed[.left] = false

            default:
                break
            }
            
            
        }
        

        
        
    
    
    private func playerIsAlive() -> Bool{
        
        var playerIsAlive:Bool = false
        
        for kid in self.children{
            if let player = myPlayer{
                if player == kid as? Player {
                    playerIsAlive = true
                }
            }
            
        }
        return playerIsAlive
    }
    
    private func playerDies(message: String){
        
        //if
        
        
        print(message)
        
        if let player = myPlayer{
            
            player.isAlive = false
            player.isDying = true
            player.justDied = true
            player.contactActive = false
            //player.deathPosition = player.position
            player.removeFromParent()
            myPresentationPlayer?.removeFromParent()
            //myRestartLabel.backgroundColor = UIColor.clearColor()
            
            
            //self.paused = true
            //self.runAction(SKAction.speedTo(0.5, duration: 1))
            //WALLSPEED /= 3
            
        }
        
    }
    
    private func playerComeBackToLife(player: Player){
        
      // ****  myRestartLabel.hidden = true
        if let player = myPlayer{
            
            player.isAlive = true
        }
        world.runAction(SKAction.fadeAlphaTo(1.0, duration: 0))
//        self.view!.alphaValue = 1 //before self.alpha
        //self.view!.backgroundColor = UIColor.blackColor()
        //self.paused = false
        //WALLSPEED *= 3
        
    }
    
    private func smashBlockEdgeHit(player: Player) -> Bool{
        //if /*!isEdgeHitDeathOn &&*/ !isMovingToNextArea{
        //    return false
        //}
        
        var died = false
        var smashSpeed:CGFloat = 1 * SPEED_PERCENTAGE //WALLSPEED
        var sign:CGFloat = -1
        
        let pixelBuffer:CGFloat = 2
        
        if self.smashBlockStatus == .returning{
            smashSpeed =  WALLSPEED / WALLSPEED * 1
            sign = -sign
        }
        
        func speed(wallSpeed: CGVector){
            player.physicsBody!.applyImpulse(wallSpeed)
        }
        
        
        if let direction = player.hitDirection{
            // if let
            //player.physicsBody!.velocity = mySmashBlocks[self.activeSmashBlock!]!.physicsBody!.velocity
            
            //println("should work vel = \(mySmashBlocks[self.activeSmashBlock!]!.physicsBody!.velocity.dx), \(mySmashBlocks[self.activeSmashBlock!]!.physicsBody!.velocity.dy)   \(self.activeSmashBlock!.rawValue)")
            
            print("\(player.cornerHitPosition!.x), \(player.cornerHitPosition!.y)")
            
            let unitY:CGFloat = 0.5
            let unitX:CGFloat = 0.5
            let r:CGFloat = 1
            
            switch direction{
                
            case .leftTop:
                if /*player.cornerHitPosition!.y > gameFrame.height/2 - player.radius &&*/ player.cornerHitPosition!.y <= gameFrame.height/2 + pixelBuffer{///2{
                    //let r = player.radius
                    //let unitY = gameFrame.height/2 - player.position.y
                    //let unitX = r - unitY.abs()
                    sign = -sign
                    
                    speed(CGVector(dx: sign * smashSpeed * unitX / r, dy: -smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
            case .leftBottom:
                if /*player.cornerHitPosition!.y < gameFrame.height/2 + player.radius &&*/ player.cornerHitPosition!.y >= gameFrame.height/2 - pixelBuffer{///2{
                    //let r = player.radius
                    //let unitY = gameFrame.height/2 - player.position.y
                    //let unitX = r - unitY.abs()
                    sign = -sign
                    
                    speed(CGVector(dx: sign * smashSpeed * unitX / r, dy: smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
            case .rightTop:
                if /*player.cornerHitPosition!.y > gameFrame.height/2 - player.radius &&*/ player.cornerHitPosition!.y <= gameFrame.height/2 + pixelBuffer{///2 {
                    //let r = player.radius
                    //let unitY = gameFrame.height/2 - player.position.y
                    //let unitX = r - unitY.abs()
                    
                    speed(CGVector(dx: sign * smashSpeed * unitX / r, dy: -smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
            case .rightBottom:
                if /*player.cornerHitPosition!.y < gameFrame.height/2 + player.radius &&*/ player.cornerHitPosition!.y >= gameFrame.height/2 - pixelBuffer{///2 {
                    //let r = player.radius
                    //let unitY = gameFrame.height/2 - player.position.y
                    //let unitX = r - unitY.abs()
                    
                    
                    speed(CGVector(dx: sign * smashSpeed * unitX / r, dy: smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
            case .topLeft:
                if /*player.cornerHitPosition!.x < gameFrame.width/2 + player.radius &&*/ player.cornerHitPosition!.x >= gameFrame.width/2 - pixelBuffer{///2{
                    //let r = player.radius
                    //let unitX = gameFrame.width/2 - player.position.x
                    //let unitY = r - unitX.abs()
                    
                    speed(CGVector(dx: smashSpeed * unitX / r, dy: sign * smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
            case .topRight:
                if /*player.cornerHitPosition!.x > gameFrame.width/2 - player.radius &&*/ player.cornerHitPosition!.x <= gameFrame.width/2 + pixelBuffer{///2{
                    //let r = player.radius
                    //let unitX = gameFrame.width/2 - player.position.x
                    //let unitY = r - unitX.abs()
                    
                    speed(CGVector(dx: -smashSpeed * unitX / r, dy: sign * smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
            case .bottomLeft:
                if /*player.cornerHitPosition!.x < gameFrame.width/2 + player.radius &&*/ player.cornerHitPosition!.x >= gameFrame.width/2 - pixelBuffer{///2{
                    //let r = player.radius
                    //var unitX = player.position.x - gameFrame.width/2 - pixelBuffer/2
                    //if unitX < 0 { unitX = 0}
                    //let unitY = r - unitX.abs()
                    sign = -sign
                    
                    speed(CGVector(dx: smashSpeed * unitX / r, dy: sign * smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
            case .bottomRight:
                if /*player.cornerHitPosition!.x > gameFrame.width/2 - player.radius &&*/ player.cornerHitPosition!.x <= gameFrame.width/2 + pixelBuffer{///2{
                    //let r = player.radius
                    //var unitX = gameFrame.width/2 + pixelBuffer/2 - player.position.x
                    //if unitX < 0 { unitX = 0}
                    //let unitY = r - unitX.abs()
                    sign = -sign
                    
                    speed(CGVector(dx: -smashSpeed * unitX / r, dy: sign * smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
                
            }
            if died && (smashBlockStatus == .smashing || smashBlockStatus == .returning)  {
                if isEdgeHitDeathOn || player.hitCount >= 2{
                playerDies("DIEDEDED")
                //player.deathPosition = player.position
                player.deathPosition = player.cornerHitPosition!
                //player.contactActive = true
                //player.hitCount = 1
                }
                else{
                    died = false
                }
            }
            player.hitDirection = nil
            player.cornerHitPosition = nil
            
            
            
        }
        //player.hitDirection = nil
        //player.cornerHitPosition = nil
    
        return died
    }
    
    
    private func updatePlayerAfterPhysics(){
       
        var smashSpeed:CGFloat = WALLSPEED
        var sign:CGFloat = -1
        
        let pixelBuffer:CGFloat = 2
        
        
        if self.smashBlockStatus == .returning{
            smashSpeed =  WALLSPEED / WALLSPEED * 100
            sign = -sign
        }
        
        if let player = myPlayer{
            
            if player.position.x < cornerBlockFrame.width + player.radius {
                player.position.x = cornerBlockFrame.width + player.radius
            }
            else if player.position.x > gameFrame.width - cornerBlockFrame.width - player.radius{
                player.position.x = gameFrame.width - cornerBlockFrame.width - player.radius
            }
            
            if player.position.y < cornerBlockFrame.height + player.radius{
                player.position.y = cornerBlockFrame.height + player.radius
            }
            else if player.position.y > gameFrame.height - cornerBlockFrame.height - player.radius{
                player.position.y = gameFrame.height - cornerBlockFrame.height - player.radius
            }
            
            //return
            
            if player.isDying{
                
                if let burst = myEmitterNode{
                    if player.deathPosition.x < cornerBlockFrame.width {//+ player.radius {
                        player.deathPosition.x = cornerBlockFrame.width //+ player.radius
                    }
                    else if player.deathPosition.x > gameFrame.width - cornerBlockFrame.width {// - player.radius{
                        player.deathPosition.x = gameFrame.width - cornerBlockFrame.width //- player.radius
                    }
                    
                    if player.deathPosition.y < cornerBlockFrame.height {//+ player.radius{
                        player.deathPosition.y = cornerBlockFrame.height //+ player.radius
                    }
                    else if player.deathPosition.y > gameFrame.height - cornerBlockFrame.height {//- player.radius{
                        player.deathPosition.y = gameFrame.height - cornerBlockFrame.height //- player.radius
                    }
                    
                    if player.justDied{
                        burst.position = player.deathPosition
                        //burst.position = player.position
                        
                        if hasWorldMovement{
                            let playPos = player.deathPosition
                            let centerPoint = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
                            let differenceVector = CGPoint(x: centerPoint.x - playPos.x, y: centerPoint.y - playPos.y)
                        
                            //myGravityFieldNode.position = CGPoint(x: differenceVector.x, y: differenceVector.y)
                            //burst.position = centerPoint
                            
                            myGravityFieldNode.position = self.convertPoint(myGravityFieldNode.position, fromNode: self.world)
                            burst.position = self.convertPoint(burst.position, fromNode: self.world)
                            
                        }
// Mark: change back
                        burst.resetSimulation()
                        player.justDied = false
                    }
                
                }
                
            }
            
            self.smashBlockEdgeHit(player)
            
            
        }
       
       
    }
    
    private func updatePresentationLayer(){
    
        if myPlayer!.isDying{
         //   return
        }
        //for-in loop to add the corners to the scene
        for (position ,corner) in myCorners {
            //self.addChild(corner)
            myPresentationCorners[position]!.position = corner.position
        }
        
        
        //---------------------
        //smashing block objects
        
        
        //Dictionary to hold the SMASH block objects
        let smashBlockArray = SmashBlock.array
        for bPosition in smashBlockArray{
            //mySmashBlocks[bPosition] =  SmashBlock(blockPos: bPosition)
            myPresentationSmashBlocks[bPosition]?.position = mySmashBlocks[bPosition]!.position
            myPresentationSmashBlocks[bPosition]?.color = mySmashBlocks[bPosition]!.color
        }
        
        myPresentationPlayer!.position = myPlayer!.position
    
    }
    
    private func updateWorldMovement(){
        if !hasWorldMovement{
            return
        }
        //if myPlayer!.isDying{
        //    return
        //}
        var playPos = myPresentationPlayer!.position
        if !myPlayer!.isAlive{
            playPos = myPlayer!.deathPosition
        }
        //var playPos = myPresentationPlayer!.position
        let centerPoint = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
        let differenceVector = CGPoint(x: centerPoint.x - playPos.x, y: centerPoint.y - playPos.y)
        
        
        
        world.position = CGPoint(x: differenceVector.x, y: differenceVector.y)
        
        //myPresentationPlayer!.position = centerPoint
        /*
        //for-in loop to add the corners to the scene
        for (position ,corner) in myCorners {
            //self.addChild(corner)
            let mPC = myPresentationCorners[position]!.position
            myPresentationCorners[position]!.position = CGPoint(x: mPC.x + differenceVector.x, y: mPC.y + differenceVector.y)
        }
        
        
        //---------------------
        //smashing block objects
        
        
        //Dictionary to hold the SMASH block objects
        let smashBlockArray = SmashBlock.array
        for bPosition in smashBlockArray{
            //mySmashBlocks[bPosition] =  SmashBlock(blockPos: bPosition)
            let mPSB = myPresentationSmashBlocks[bPosition]!.position
            myPresentationSmashBlocks[bPosition]?.position = CGPoint(x: mPSB.x + differenceVector.x, y: mPSB.y + differenceVector.y)
            myPresentationSmashBlocks[bPosition]?.color = mySmashBlocks[bPosition]!.color
        }
        
        
        */
        
        
    }
    
    
    private func updatePlayer(){
        var smashSpeed:CGFloat = WALLSPEED
        
        if self.smashBlockStatus == .returning{
            smashSpeed =  -WALLSPEED / WALLSPEED * 1000
        }
        
        
        var isChild = false
        
        for child in self.children{
            if let player = myPlayer{
                if player == child as? Player {
                    //playerIsAlive = true
                    isChild = true
                }
            }
        }
        
        if isMovingToNextArea{
            isChild = true
        }
        
        if let player = myPlayer{
            
           // self.smashBlockCornerHit(player) //===========CORNER CORRECTION HIT==============
            
            if isChild{
                if !player.isAlive{
                    //----add code if necessary---
                    
                    
                    
                    if player.isDying{
                        //----add code if necessary---
                        //myRestartLabel.text = "RESTART"
                      
                    }
                }
                else if player.isAlive{
                    //----add code if necessary---
                    //self.isStart = false
                    
                        JoyStickTouchLogic()
                    
                    myRestartLabel.text = "\(playerScore)"
                    
                    /*
                    let region = SKRegion(radius: 5)
                    if region.containsPoint(player.position){
                        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    }
                    */
                    
                }
                
            }
            else if !isChild{
                
                if player.isAlive{
                    
                    self.reloadSceneTime()
                    self.addChild(player)
                    world.addChild(myPresentationPlayer!)
                    player.position = player.originalPosition
                    player.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                    //player.hitCount = 0
                    player.hitCount = 0
                    //player.isDying = false
                    player.contactActive = false
                    player.contactStatic = false
                    controller.joyStickDirection = .neutral
                    isPlayerTouched = false
                    myGravityFieldNode.position = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
                    
                    
                    //self.isStart = false
                    
                }
                else if !player.isAlive{
                    
                    if player.isDying{
                       // myRestartLabel.backgroundColor = UIColor.clearColor()
                        
                        
                   
                    //????
                    }
                    else{
                        myRestartLabel.text = "RESTART"
                        playerScore = 0
                        myGravityFieldNode.strength = 9.8 * Float(SPEED_PERCENTAGE)
                        self.isSlowedDown = false
                    }
                    

                }
                
                
                
                
           }
        }
        
        
        
        
        
    }
    
    // MARK: SKPhysicsContactDelegate
    
    func didBeginContact(contact: SKPhysicsContact) {
        let pixelBuffer:CGFloat = 2//10.0 * 2
        
        func contactLogic(player:SKPhysicsBody, wall:SKPhysicsBody){
            
           // var playerVelocity = player.velocity.dx
            
            if myPlayer!.isAlive{
                
                if let smashBlock = wall.node as? SmashBlock{
                    let smashPosition = smashBlock.smashBlockPosition
                    
                    if wall.dynamic == true{
                        
                        //self.isTouchingActiveWall = true
                        
                        //self.smashBlockEdgeHit(myPlayer!)
                        
                        
                        self.controller.joyStickDirection = .neutral
                        
                        if myPlayer!.contactActive == false{
                            ++myPlayer!.hitCount
                            myPlayer!.contactActive = true
                        }
                        
                        
                        
                        print( "hitCount = \(myPlayer!.hitCount) from \(self.activeSmashBlock!.rawValue) active wall at \(myPlayer!.position.x), \(myPlayer!.position.y)")
                        let playerVelocity = sqrt( pow(player.velocity.dx, 2) + pow(player.velocity.dy, 2) )
                        
                        //println("active Wall contact - velocity = \(playerVelocity) = \(player.velocity.dx), \(player.velocity.dy)")
                        
                        
                        player.velocity = mySmashBlocks[self.activeSmashBlock!]!.physicsBody!.velocity
                        
                        if myPlayer!.hitDirection == nil{
                            myPlayer?.hitDirection = smashPosition
                            myPlayer?.cornerHitPosition = myPlayer!.position
                            //myPlayer?.cornerHitPosition = contact.contactPoint
                            //self.smashBlockCornerHit(myPlayer!)
                            
                        }
                        
                        
                        
                        if myPlayer!.hitCount >= 2 && !myPlayer!.isDying{
                            
                            myPlayer!.deathPosition = contact.contactPoint
                            
                            
                            
                            //myPlayer!.deathPosition = myPlayer!.position
                            
                            //myPlayer?.hitDirection = smashPosition
                            //return
                            var moveAreaBy:CGPoint = CGPoint(x: 0, y: 0)
                            var playerMoveAreaPosition:CGPoint = contact.contactPoint
                            
                            switch smashPosition
                            {
                            case .leftBottom, .leftTop:
                                moveAreaBy.x = gameFrame.width
                                playerMoveAreaPosition.x = cornerBlockFrame.width
                                if smashPosition.opposite() != self.exitBlock{
                                    playerDies(" \(myPlayer!.hitCount) -player died from smashing into the right wall")
                                }
                                
                            case .rightBottom, .rightTop:
                                moveAreaBy.x = -gameFrame.width
                                playerMoveAreaPosition.x = gameFrame.width - cornerBlockFrame.width
                                if smashPosition.opposite() != self.exitBlock{
                                    playerDies(" \(myPlayer!.hitCount) -player died from smashing into the left wall")
                                }
                                
                            case .topLeft, .topRight:
                                moveAreaBy.y = -gameFrame.height
                                playerMoveAreaPosition.y = gameFrame.height - cornerBlockFrame.height
                                if smashPosition.opposite() != self.exitBlock{
                                    playerDies(" \(myPlayer!.hitCount) -player died from smashing into the bottom wall")
                                }
                                
                            case .bottomLeft, .bottomRight:
                                moveAreaBy.y = gameFrame.height
                                playerMoveAreaPosition.y = cornerBlockFrame.height
                                if smashPosition.opposite() != self.exitBlock{
                                    playerDies(" \(myPlayer!.hitCount) -player died from smashing into the top wall")
                                }
                            }
                            
                            if smashPosition.opposite() == self.exitBlock{
                                
                                self.movingToNextArea(moveAreaBy, playerPosition: playerMoveAreaPosition, playerVelocity: SmashBlock.entranceSpeed(self.activeSmashBlock!))
                                
                                return
                            }
                            
                            
                        }
                        
                        isPlayerTouched = true
                       // self.playerScore = 0
                        
                    }
                    else if wall.dynamic == false { //static walls
                        
                        let playerVelocity = sqrt( pow(player.velocity.dx, 2) + pow(player.velocity.dy, 2) )
                        
                       // println("static Wall contact - velocity = \(playerVelocity) = \(player.velocity.dx), \(player.velocity.dy)")
                        
                        var moveAreaBy:CGPoint = CGPoint(x: 0, y: 0)
                        var playerMoveAreaPosition:CGPoint = contact.contactPoint
                        if let activeBlock = self.activeSmashBlock {
                            
                            if myPlayer!.contactStatic == false {
                                /*switch activeBlock
                                {
                                case .leftBottom:
                                    if smashPosition == .rightBottom{
                                        myPlayer!.hitCount++
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.x = gameFrame.width
                                        playerMoveAreaPosition.x = cornerBlockFrame.width
                                    }
                                case .leftTop:
                                    if smashPosition == .rightTop{
                                        myPlayer!.hitCount++
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.x = gameFrame.width
                                        playerMoveAreaPosition.x = cornerBlockFrame.width
                                    }
                                case .rightBottom:
                                    if smashPosition == .leftBottom{
                                        myPlayer!.hitCount++
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.x = -gameFrame.width
                                        playerMoveAreaPosition.x = gameFrame.width - cornerBlockFrame.width
                                    }
                                case .rightTop:
                                    if smashPosition == .leftTop{
                                        myPlayer!.hitCount++
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.x = -gameFrame.width
                                        playerMoveAreaPosition.x = gameFrame.width - cornerBlockFrame.width
                                    }
                                case .topLeft:
                                    if smashPosition == .bottomLeft{
                                        myPlayer!.hitCount++
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.y = -gameFrame.height
                                        playerMoveAreaPosition.y = gameFrame.height - cornerBlockFrame.height
                                    }
                                case .topRight:
                                    if smashPosition == .bottomRight{
                                        myPlayer!.hitCount++
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.y = -gameFrame.height
                                        playerMoveAreaPosition.y = gameFrame.height - cornerBlockFrame.height
                                    }
                                case .bottomLeft:
                                    if smashPosition == .topLeft{
                                        myPlayer!.hitCount++
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.y = gameFrame.height
                                        playerMoveAreaPosition.y = cornerBlockFrame.height
                                    }
                                case .bottomRight:
                                    if smashPosition == .topRight{
                                        myPlayer!.hitCount++
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.y = gameFrame.height
                                        playerMoveAreaPosition.y = cornerBlockFrame.height
                                    }
                                }*/
                                switch activeBlock
                                {
                                case .leftBottom, .leftTop:
                                    if smashPosition == .rightBottom || smashPosition == .rightTop{
                                        myPlayer!.hitCount++
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.x = gameFrame.width
                                        playerMoveAreaPosition.x = cornerBlockFrame.width
                                    }
                                case .rightBottom, .rightTop:
                                    if smashPosition == .leftBottom || smashPosition == .leftTop{
                                        myPlayer!.hitCount++
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.x = -gameFrame.width
                                        playerMoveAreaPosition.x = gameFrame.width - cornerBlockFrame.width
                                    }
                                case .topLeft, .topRight:
                                    if smashPosition == .bottomLeft || smashPosition == .bottomRight{
                                        myPlayer!.hitCount++
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.y = -gameFrame.height
                                        playerMoveAreaPosition.y = gameFrame.height - cornerBlockFrame.height
                                    }
                                case .bottomLeft, .bottomRight:
                                    if smashPosition == .topLeft || smashPosition == .topRight{
                                        myPlayer!.hitCount++
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.y = gameFrame.height
                                        playerMoveAreaPosition.y = cornerBlockFrame.height
                                    }
                                }

                            }
                            print( "hitCount = \(myPlayer!.hitCount) from \(smashPosition.rawValue) static wall")
                            
                            
                            
                            if myPlayer!.hitCount >= 2 && !myPlayer!.isDying{
                                
                                if myPlayer!.hitDirection == nil{
                                    myPlayer?.hitDirection = activeBlock//smashPosition.opposite()
                                    myPlayer?.cornerHitPosition = myPlayer!.position
                                    //myPlayer?.cornerHitPosition = contact.contactPoint
                                    //self.smashBlockCornerHit(myPlayer!)
                                    
                                }
                                
                                
                                
                                if smashPosition == self.exitBlock{
                                    
                                    
                                    player.velocity = mySmashBlocks[self.activeSmashBlock!]!.physicsBody!.velocity
                                    
                                    self.movingToNextArea(moveAreaBy, playerPosition: playerMoveAreaPosition, playerVelocity: SmashBlock.entranceSpeed(self.activeSmashBlock!))
                                    
                                    return
                                }
                                
                                myPlayer!.deathPosition = contact.contactPoint
                                //myPlayer!.deathPosition = myPlayer!.position
                                playerDies(" \(myPlayer!.hitCount) -player died from smashing into the \(smashPosition.rawValue) wall")
                            }else if playerVelocity >= DEATHVELOCITY/3 && !myPlayer!.isDying{
                               // myPlayer!.deathPosition = contact.contactPoint
                                //myPlayer!.deathPosition = myPlayer!.position
                              //  playerDies("TOO FAST - DEATH \(playerVelocity)")
                                
                            }
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                        
                    }
                }
            }
            
            
        }
        
        
        
        if let player = contact.bodyA.node as? Player {
            contactLogic(contact.bodyA, wall: contact.bodyB)
        }else if let player = contact.bodyB.node as? Player {
            contactLogic(contact.bodyB, wall: contact.bodyA)
        }
        
        
    }
    
    
   
    private func movingToNextArea(moveAreaBy:CGPoint, playerPosition:CGPoint, playerVelocity: CGVector){
        self.isMovingToNextArea = true
        if self.smashBlockEdgeHit(myPlayer!){
            self.isMovingToNextArea = false
            return
        }
        
        myPlayer!.hitCount = 0
        //player.isDying = false
        myPlayer!.contactActive = false
        myPlayer!.contactStatic = false
        self.controller.joyStickDirection = .neutral
        self.isPlayerTouched = false
        
        
        
        
        var movingVertically = false
        var newAreaPosition = CGPoint()
        
        let playerPresentationPosition = self.convertPoint(playerPosition, toNode: world)
        //self.isMovingToNextArea = true
        myPlayer?.removeFromParent()
        myPresentationPlayer?.removeFromParent()
        self.addChild(myPresentationPlayer!)
        myPresentationPlayer!.position = self.convertPoint(myPresentationPlayer!.position, fromNode: world)
        let worldOriginalPosition = world.position
        
        //var islevelChange:Bool = false
        
        world.runAction(SKAction.moveTo(CGPoint(x: world.position.x - (2 * moveAreaBy.x), y: world.position.y -  (2 * moveAreaBy.y)), duration: self.entranceTime/2)){
            self.world.position = CGPoint(x: self.world.position.x + (4 * moveAreaBy.x), y: self.world.position.y + (4 * moveAreaBy.y))
            mySmashBlocks[self.exitBlock.opposite()]?.color = self.exitBlockColor
            
            ++self.stageCount
            STAGE = self.stageCount
            if self.stageCount > (myMaze!.escapePath.count - 1)/2 - 1{
                self.stageCount = 0
                self.level++
                //self.levelExitsArray = //SmashBlock.levelExitArray(self.level)
                LEVEL = self.level
                STAGE = self.stageCount
                myLevelNumberLabel.removeFromParent()
                self.world.addChild(myLevelNumberLabel)
                
                self.islevelChange = true
                //return
            }
            
            self.reloadSceneTime()
            //myPresentationPlayer?.removeFromParent()
            //self.world.addChild(myPresentationPlayer!)
            if self.hasWorldMovement{
                myPresentationPlayer?.position = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
            }else{
                
            }
            //myPlayer?.position = playerPosition
            
            
            
            if moveAreaBy.x == 0{
                self.world.position.x = worldOriginalPosition.x
                movingVertically = true
                newAreaPosition.x = worldOriginalPosition.x
                newAreaPosition.y = gameFrame.height/2 - playerPosition.y//playerPresentationPosition.y
                if !self.hasWorldMovement{
                    newAreaPosition.y = 2 * (gameFrame.height/2 - playerPosition.y)
                }
            }else{
                self.world.position.y = worldOriginalPosition.y
                movingVertically = false
                newAreaPosition.x = gameFrame.width/2 - playerPosition.x//playerPresentationPosition.x
                if !self.hasWorldMovement{
                    newAreaPosition.x =  2 * (gameFrame.width/2 - playerPosition.x)
                }
                newAreaPosition.y = worldOriginalPosition.y
            }
            
            self.world.runAction(SKAction.moveTo(newAreaPosition, duration: self.entranceTime/2)){
                //if self.hasWorldMovement{
                
                myPresentationPlayer?.removeFromParent()
                self.world.addChild(myPresentationPlayer!)
                self.addChild(myPlayer!)
                //myPlayer?.position = playerPosition
                self.isMovingToNextArea = false
                
                if let player = myPlayer{
                    
                    //self.addChild(player)
                    player.position = playerPosition
                    myPresentationPlayer!.position = playerPresentationPosition
                    player.physicsBody!.velocity = playerVelocity
                    player.hitCount = 0
                    //player.isDying = false
                    player.contactActive = false
                    player.contactStatic = false
                    self.controller.joyStickDirection = .neutral
                    self.isPlayerTouched = false
                }
                if self.islevelChange{
                    //self.playerDies("HUH")
                    //self.isFirstRound = true
                    //self.isFirstRoundStarted = false
                    // myPlayer?.isAlive = false
                    // myPlayer?.removeFromParent()
                    //self.reloadSceneTime()
                    //self.playerDies("HUH")
// update for map                    myPlayer?.position = myPlayer!.originalPosition
// update for map                   self.view?.presentScene(mazeScene)
                    //return
                }
                
                
                // }else{
                if !self.hasWorldMovement{
                    self.world.runAction(SKAction.moveTo(worldOriginalPosition, duration: self.entranceTime/10)){
                        //self.isMovingToNextArea = false
                    }
                }
                //}
                
            }
        }
        
        
        
    }

    
    
    
    func didEndContact(contact: SKPhysicsContact) {
        
        let pixelBuffer:CGFloat = 10.0
        
        func contactLogic(player:SKPhysicsBody, wall:SKPhysicsBody){
            
            
            if let smashBlock = wall.node as? SmashBlock{
                let smashPosition = smashBlock.smashBlockPosition
            
            
                if wall.dynamic == true{
                    if myPlayer!.contactActive{
                        --myPlayer!.hitCount
                        myPlayer!.contactActive = false
                    }
                    print( "hitCount = \(myPlayer!.hitCount) release from \(self.activeSmashBlock!.rawValue) active wall")
                }
                else{
                
                    if let activeBlock = self.activeSmashBlock {
                    
                        if myPlayer!.contactStatic{
                        
                        
                            switch activeBlock
                            {
                            case .leftBottom, .leftTop:
                                if smashPosition == .rightBottom || smashPosition == .rightTop{
                                    --myPlayer!.hitCount
                                    myPlayer!.contactStatic = false
                                }
                            case .rightBottom, .rightTop:
                                if smashPosition == .leftBottom || smashPosition == .leftTop{
                                    --myPlayer!.hitCount
                                    myPlayer!.contactStatic = false
                                }
                            case .topLeft, .topRight:
                                if smashPosition == .bottomLeft || smashPosition == .bottomRight{
                                    --myPlayer!.hitCount
                                    myPlayer!.contactStatic = false
                                }
                            case .bottomLeft, .bottomRight:
                                if smashPosition == .topLeft || smashPosition == .topRight{
                                    --myPlayer!.hitCount
                                    myPlayer!.contactStatic = false
                                }
                            }
                        
                
                            
                        }
                        
                        print( "hitCount = \(myPlayer!.hitCount) \(activeBlock.rawValue) active wall & release from \(smashPosition.rawValue) static wall")
                    }
                }
            }
        }
        
        
        
        if myPlayer!.isAlive{
        
            if let player = contact.bodyA.node as? Player {
                
                contactLogic(contact.bodyA, wall: contact.bodyB)
                
            }
            else if let player = contact.bodyB.node as? Player {
                
                contactLogic(contact.bodyB, wall: contact.bodyA)
            }
        }
        
    }
    

    private func deathScene(deltaTime: CFTimeInterval){
        
        let centerPoint = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
        var differenceVector = CGPoint(x: centerPoint.x - myPlayer!.deathPosition.x, y: centerPoint.y - myPlayer!.deathPosition.y)
        if !hasWorldMovement{
            differenceVector = CGPoint(x: 0, y: 0)
        }
            if self.deathTimer == 0{
                //updateWorldMovement()
                self.slowDownSceneTime()
                sizeEffectSwitch = true
            }
            
            self.deathTimer += deltaTime
            if self.deathTimer <= 1 || !sizeEffectSwitch{
                //return
                ++sizeEffectSwitchCounter
                if sizeEffectSwitch && sizeEffectSwitchCounter >= 3 {
                    
                    /* Using 3D effect instead
                    
                    self.world.position = CGPoint(x: ( 1 - 1.01 ) * gameFrame.width/2 + differenceVector.x, y: ( 1 - 1.01 ) * gameFrame.height/2 + differenceVector.y)
                    self.world.setScale(1.01)
                    */
                    self.world.position = CGPoint(x: ( 1 - 1.01 ) * gameFrame.width/2 + differenceVector.x, y: ( 1 - 1.01 ) * gameFrame.height/2 + differenceVector.y)
                    
                    sizeEffectSwitch = !sizeEffectSwitch
                    sizeEffectSwitchCounter = 0
                }
                else if !sizeEffectSwitch && sizeEffectSwitchCounter >= 3{
                    
                    /* Using 3D effect instead
                    
                    self.world.setScale(1)
                    self.world.position = differenceVectorght: 1/1.01))
                    */
                    self.world.position = differenceVector
                    sizeEffectSwitch = !sizeEffectSwitch
                    sizeEffectSwitchCounter = 0
                }
                
                
            }
            else{
                //self.view?.transform = CGAffineTransformMakeRotation( CGFloat(1) * 2 * MATH_PI)
                //                self.view?.transform = CGAffineTransformMakeScale(1, 1)
                self.deathTimer = 0
                myPlayer!.isDying = false
//***********//                myRestartLabel.hidden = false
                //                UIView.animateWithDuration( 1.0, animations: { () -> Void in
                // self.view!.alpha = 0.7
                //self.view!.backgroundColor = UIColor.whiteColor()
                //                })
                
            }
        
    }
        
        
        
        
    
    private var sizeEffectSwitch:Bool = false
    private var sizeEffectSwitchCounter = 0
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        //LEVEL = self.level
        //STAGE = self.stageCount
        
        
        if isFirstRound{
            myRestartLabel.text = "Start"
            lastUpdatedTime = currentTime
            return
        }
        else if !isFirstRoundStarted{
           // myRestartLabel.text = "RESTART"
            isFirstRoundStarted = true
        }
        
        if isMovingToNextArea{
            lastUpdatedTime = currentTime
            return
        }
        
        deltaTime = currentTime - lastUpdatedTime
        lastUpdatedTime = currentTime
        
        if myPlayer!.isDying{self.deathScene(deltaTime)}
        
        self.SmashBlockLogic(deltaTime)
        
        self.updatePlayer()
        
        self.updateJoyStick()
        
   /*    // if self.childNodeWithName("player") != nil{
            if let player = myPlayer{
                let r = sqrt( pow(gameFrame.width/2 - player.position.x, 2) + pow(gameFrame.height/2 - player.position.y, 2) )
                let unitX = gameFrame.width/2 - player.position.x
                let unitY = gameFrame.height/2 - player.position.y
        
                self.physicsWorld.gravity = CGVector(dx: 9.8 * unitX / r, dy: 9.8 * unitY / r)
            }
      //  }*/
        
    }
    
    override func didSimulatePhysics() {
        
        myLevelNumberLabel.text = "LEVEL \(LEVEL)"
        myLevelNumberLabel.position = CGPoint(x: world.position.x + gameFrame.width/2, y: world.position.y + gameFrame.height/2 - cornerBlockFrame.height)
        
        if isFirstRound{
            return
        }
        if isMovingToNextArea{
      //      myPresentationPlayer!.position
            return
        }
        
        SmashBlockLogicAfterPhysics()
        updatePlayerAfterPhysics()
        updatePresentationLayer()
        if !myPlayer!.isDying{
            updateWorldMovement()
            //myLevelNumberLabel.position = CGPoint(x: world.position.x + gameFrame.width/2, y: world.position.y + gameFrame.height/2 - cornerBlockFrame.height)
        }
        
    }
    
    override func didFinishUpdate() {
      /*
        var count:Int = 0
        if let playerContacts = myPlayer?.physicsBody?.allContactedBodies(){
            
            for contact in playerContacts{
                if let contactHit = contact as? SmashBlock{
                    if contactHit.physicsBody!.dynamic{
                        count++
                    }
                    else if count == 0 && !contactHit.physicsBody!.dynamic{
                        count++
                    }
                }
            }
        }
        
        if count == 2{
            println("PLAYER DIED")
        }
        */
    }
    
    private var blockArrayCounter:Int = 0
    
    
    private func SmashBlockLogicAfterPhysics(){
        let pixelBuffer:CGFloat = 2//10.0
        let WALL_SPEED = WALLSPEED
        
        
        
        for (position, block) in mySmashBlocks{
            
            if block.physicsBody?.dynamic != true{
                block.position = block.orginalPosition
            }
            else if block.physicsBody!.dynamic{
                switch position{
                case .leftBottom, .leftTop, .rightBottom, .rightTop:
                    block.position.y = block.orginalPosition.y
                default: //the vertical blocks
                    block.position.x = block.orginalPosition.x
                }
            }
            
        }
        
        
        if var trap = self.activeSmashBlock{
            
            let smashBlock = mySmashBlocks[trap]
            
            smashBlock?.zRotation = 0
            
            
            
            switch smashBlockStatus{
                
            case .waiting:
                
                if smashStatusChanged{
                    myPlayer!.hitCount = 0
                    myPlayer!.contactActive = false
                    myPlayer!.contactStatic = false
                    smashStatusChanged = false
                    smashBlock?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    smashBlock?.color = self.wallColor
                    if trap.opposite() == self.exitBlock{
                        mySmashBlocks[self.exitBlock]!.color = self.wallColor
                    }
                    smashBlock?.physicsBody?.dynamic = false
                    smashBlock!.physicsBody!.categoryBitMask = CollisionType.staticWall.rawValue
                    smashBlock!.physicsBody!.contactTestBitMask = CollisionType.player.rawValue
                    self.restingSmashBlockPosition = smashBlock?.orginalPosition
                    self.oldSmashBlock = self.activeSmashBlock
                    wallTimer = 0
                    
                    if let oldBlock = self.oldSmashBlock{
                        mySmashBlocks[oldBlock]?.position = self.restingSmashBlockPosition!
                    }
                    
                    //trap = SmashBlock.randomBlockPosition() // as SmashBlock.blockPosition
                    ++blockArrayCounter
                    if blockArrayCounter > 7 {
                        blockArrayCounter = 0
                        arrayOfBlocks.shuffle()
                        //arrayOfBlocks = SmashBlock.random8array()
                    }
                    trap = arrayOfBlocks[blockArrayCounter]
                    self.activeSmashBlock = trap
                    mySmashBlocks[trap]?.color = self.smashingColor
                    //regular logic change back
                    if trap.opposite() == self.exitBlock{
                        mySmashBlocks[self.exitBlock]!.color = self.exitBlockColor
                    }
                    //self.exitBlock = trap.opposite()
                    //mySmashBlocks[self.exitBlock]!.color = self.exitBlockColor
                    
                }
            case .smashing:
                
                if smashStatusChanged{
                    smashStatusChanged = false
                    smashBlock!.physicsBody!.dynamic = true
                    smashBlock!.physicsBody!.categoryBitMask = CollisionType.activeWall.rawValue
                    smashBlock!.physicsBody!.contactTestBitMask = CollisionType.player.rawValue
                }else{
                    
                    switch trap{
                        
                    case .leftTop, .leftBottom:
                        //
                        if smashBlock?.position.x >= gameFrame.width - cornerBlockFrame.width - smashBlock!.size.width/2 - pixelBuffer {
                            smashBlock?.position.x = gameFrame.width - cornerBlockFrame.width - smashBlock!.size.width/2 - pixelBuffer
                            smashBlock?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                            //smashBlockStatus = .returning
                        }
                        
                        smashBlock?.position.y = smashBlock!.orginalPosition.y
                        
                        
                    case .rightTop, .rightBottom:
                        //
                        if smashBlock?.position.x <= cornerBlockFrame.width + smashBlock!.size.width/2 + pixelBuffer {
                            smashBlock?.position.x = cornerBlockFrame.width + smashBlock!.size.width/2 + pixelBuffer
                            smashBlock?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                            //smashBlockStatus = .returning
                        }
                        
                        smashBlock?.position.y = smashBlock!.orginalPosition.y
                        
                    case .topLeft, .topRight:
                        //
                        if smashBlock?.position.y <= cornerBlockFrame.height + smashBlock!.size.height/2 + pixelBuffer {
                            smashBlock?.position.y = cornerBlockFrame.height + smashBlock!.size.height/2 + pixelBuffer
                            smashBlock?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                            //smashBlockStatus = .returning
                        }
                        
                        smashBlock?.position.x = smashBlock!.orginalPosition.x
                        
                    case .bottomLeft, .bottomRight:
                        //
                        if smashBlock?.position.y >=    gameFrame.height - cornerBlockFrame.height - smashBlock!.size.height/2 - pixelBuffer {
                            smashBlock?.position.y = gameFrame.height - cornerBlockFrame.height - smashBlock!.size.height/2 - pixelBuffer
                            smashBlock?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                            //smashBlockStatus = .returning
                        }
                        
                        smashBlock?.position.x = smashBlock!.orginalPosition.x
                        
                    }
                    
                    
                }
                
                
                
            case .returning:
                if smashStatusChanged{
                    smashStatusChanged = false
                    smashBlock?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    //playerScore++
                    
                }else{
                    
                    
                    switch trap{
                        
                    case .leftTop, .leftBottom:
                        //
                        if smashBlock?.position.x <= cornerBlockFrame.width - smashBlock!.size.width/2 {
                            smashBlock?.position.x = cornerBlockFrame.width - smashBlock!.size.width/2
                            smashBlock?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                        }
                        
                    case .rightTop, .rightBottom:
                        //
                        if smashBlock?.position.x >= gameFrame.width - cornerBlockFrame.width + smashBlock!.size.width/2 {
                            smashBlock?.position.x = gameFrame.width - cornerBlockFrame.width + smashBlock!.size.width/2
                            smashBlock?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                        }
                        
                    case .topLeft, .topRight:
                        //
                        if smashBlock?.position.y >= gameFrame.height - cornerBlockFrame.height + smashBlock!.size.height/2 {
                            smashBlock?.position.y = gameFrame.height - cornerBlockFrame.height + smashBlock!.size.height/2
                            smashBlock?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                        }
                        
                    case .bottomLeft, .bottomRight:
                        //
                        if smashBlock?.position.y <= cornerBlockFrame.height - smashBlock!.size.height/2 {
                            smashBlock?.position.y = cornerBlockFrame.height - smashBlock!.size.height/2
                            smashBlock?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                        }
                    }
                }
            }
            
        }

    }
    
    
    private func SmashBlockLogic(deltaTime: CFTimeInterval) {
        
        var TIME_UNTIL_TRAP = 0.5 /// CFTimeInterval(SPEED_PERCENTAGE)
        if SPEED_PERCENTAGE < 1{
            TIME_UNTIL_TRAP =  0.25/CFTimeInterval(SPEED_PERCENTAGE)
        }
        let WALL_SPEED = WALLSPEED
        let pixelBuffer:CGFloat = 2//10.0
        //smashBlockStatus - private property to keep track of the activty status of each SMASH BLOCK
        //wallTimer - private property to pace the time before a SMASH BLOCK is active
        
        func speed(wallSpeed: CGVector){
            if let trap = self.activeSmashBlock{
                let smashBlock = mySmashBlocks[trap]
                smashBlock?.physicsBody?.velocity = (wallSpeed)
                
            }
        }
        
        
        if pauseSmashBlockLogic{ // if true blocks pause
            speed(CGVector(dx: 0, dy: 0))
            if let trap = self.activeSmashBlock{
                let smashBlock = mySmashBlocks[trap]
                //smashBlock?.physicsBody?.position =
                
            }
            return
        }
        
        if let trap = self.activeSmashBlock{
//            println("trap logic")
            
            switch smashBlockStatus{
            //--------------------------------WAITING
            case .waiting:
                //
                //println("waiting")
                wallTimer += deltaTime
                //mySmashBlocks[trap]?.color = UIColor.redColor()
               /* if let oldBlock = self.oldSmashBlock{
                    mySmashBlocks[oldBlock]?.position = self.restingSmashBlockPosition!
                }*/
                
                if wallTimer >= TIME_UNTIL_TRAP{
                    
                    smashStatusChanged = true
                    smashBlockStatus = .smashing
                    wallTimer = 0.0
                   // mySmashBlocks[trap]!.physicsBody!.dynamic = true
                    
                    
                }
            //--------------------------------SMASHING
            case .smashing:
                //println("smashing")
                let smashBlock = mySmashBlocks[trap]
                
                switch trap{
                    
                case .leftTop, .leftBottom:
                    //
                    if smashBlock?.position.x < gameFrame.width - cornerBlockFrame.width - smashBlock!.size.width/2 - pixelBuffer {
                        speed(CGVector(dx: WALL_SPEED, dy: 0)) //smash right
                    }
                    else {
                        smashBlockStatus = .returning
                        
                      //  smashBlock?.position.x = gameFrame.width - cornerBlockFrame.width - smashBlock!.size.width/2 - pixelBuffer
                    }
                    
                case .rightTop, .rightBottom:
                    //
                    if smashBlock?.position.x > cornerBlockFrame.width + smashBlock!.size.width/2 + pixelBuffer {
                        speed(CGVector(dx: -WALL_SPEED, dy: 0)) //smash left
                    }
                    else {
                        smashBlockStatus = .returning
                        
                       // smashBlock?.position.x = cornerBlockFrame.width + smashBlock!.size.width/2 + pixelBuffer
                    }
                    
                case .topLeft, .topRight:
                    //
                    if smashBlock?.position.y > cornerBlockFrame.height + smashBlock!.size.height/2 + pixelBuffer {
                        speed(CGVector(dx: 0, dy: -WALL_SPEED)) //smash down
                    }
                    else {
                        smashBlockStatus = .returning
                        
                      //  smashBlock?.position.y = cornerBlockFrame.height + smashBlock!.size.height/2 + pixelBuffer
                    }
                    
                case .bottomLeft, .bottomRight:
                    //
                    if smashBlock?.position.y < gameFrame.height - cornerBlockFrame.height - smashBlock!.size.height/2 - pixelBuffer {
                        speed(CGVector(dx: 0, dy: WALL_SPEED)) //smash up
                        //println(" \(smashBlock?.physicsBody?.velocity.dy) bottom smashing")
                    }
                    else {
                        smashBlockStatus = .returning
                        
                       // smashBlock?.position.y = gameFrame.height - cornerBlockFrame.height - smashBlock!.size.height/2 - pixelBuffer
                    }
                }
                if smashBlockStatus == .returning {
                    smashStatusChanged = true
                    //++playerScore
                    
                }
                    
                
                
            //--------------------------------RETURNING
            case .returning:
                //
                //println("returning")
                let smashBlock = mySmashBlocks[trap]
                
                switch trap{
                    
                case .leftTop, .leftBottom:
                    //
                    if smashBlock?.position.x > cornerBlockFrame.width - smashBlock!.size.width/2 {
                        speed(CGVector(dx: -WALL_SPEED, dy: 0)) //return left
                    }
                    else {
                        smashBlockStatus = .waiting
                        
                    }
                    
                case .rightTop, .rightBottom:
                    //
                    if smashBlock?.position.x <= gameFrame.width - cornerBlockFrame.width + smashBlock!.size.width/2 - pixelBuffer {
                        speed(CGVector(dx: WALL_SPEED, dy: 0)) //return right
                    }
                    else {
                        smashBlockStatus = .waiting
                        
                    }
                    
                case .topLeft, .topRight:
                    //
                    if smashBlock?.position.y <= gameFrame.height - cornerBlockFrame.height + smashBlock!.size.height/2 - pixelBuffer {
                        speed(CGVector(dx: 0, dy: WALL_SPEED)) //return up
                    }
                    else {
                        smashBlockStatus = .waiting
                        
                    }
                    
                case .bottomLeft, .bottomRight:
                    //
                    if smashBlock?.position.y >= cornerBlockFrame.height - smashBlock!.size.height/2 + pixelBuffer {
                        speed(CGVector(dx: 0, dy: -WALL_SPEED)) //return down
                    }
                    else {
                        smashBlockStatus = .waiting
                        
                    }
                    
                }
                
                if smashBlockStatus == .waiting {
                    smashStatusChanged = true
                    
                    if !isPlayerTouched{
                        ++playerScore
                    }else{
                        self.playerScore = 0
                        myGravityFieldNode.strength = 9.8 * Float(SPEED_PERCENTAGE)
                    }
                    isPlayerTouched = false
                    //self.playerScore = 0
                }

                //isPlayerTouched = false
                
                
            }
            
            
            
        }
        
        
        
        
        
    }
    
    
}
    
  //  #endif



