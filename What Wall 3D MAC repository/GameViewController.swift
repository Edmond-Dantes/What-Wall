//
//  GameViewController.swift
//  What Wall 3D MAC repository
//
//  Created by Edmond on 1/5/16.
//  Copyright (c) 2016 Future. All rights reserved.
//

import SceneKit
import QuartzCore
import SpriteKit

extension CGFloat{
    
    func abs()->CGFloat{
        var tempSelf = self
        if self < 0.0 {
            tempSelf = -self
        }
        return tempSelf
    }
    
}

var frameCounter2d:Int = 0
var frameCounter3d:Int = 0

var myPlayerNode:SCNNode!
var myPlayerTailNodeArray:[SCNNode] = []


var gameScene:GameScene!


class GameViewController: NSViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate{ //, SKSceneDelegate{//, SKPhysicsContactDelegate  {
    
    var renderCount:Int = 0
    
    @IBOutlet weak var gameView: GameView!
    var myView:SCNView!
    var myScene:SCNScene!
    
    var myLight:SCNNode!
    var myCamera:SCNCamera!
    var myCameraNode:SCNNode!
    
    //var myPlayerNode:SCNNode!
    var myStageNode:SCNNode!
    var myEmittorNode:SCNNode!
    var myParticleSystem:SCNParticleSystem!
    var myPhysicsFieldNode:SCNNode!
    var myPhysicsField:SCNPhysicsField!
    
    var myGameScene:GameScene!
    //    var myGameSceneView:SKView = SKView()
    var myHudOverlay:HudOverlay!
    //    var myHudOverlayView:SKView = SKView()
    
    /*    private var deltaTime: CFTimeInterval = 0.0
    private var lastUpdatedTime: CFTimeInterval = 0.0
    private var deathTimer: CFTimeInterval = 0.0
    */
    override func viewWillAppear() {
        super.viewWillAppear()
        
        
        
        
        //self.addPlayerNode()
        
        self.setupEnvironment()
        
        //Heads Up Display (SpriteKit Overlay)
        self.setupHUD()
        
        self.addPlayerNode()
        
        
        self.addPhysicsField()
        
        self.addEmittorNode()
        
        //Heads Up Display (SpriteKit Overlay)
        //self.setupHUD()
        
        
        myScene.physicsWorld.contactDelegate = self
        myScene.physicsWorld.gravity = SCNVector3(x: 0, y: 0, z: 0)
        
        
        self.gameView.delegate = self
        //myGameScene.delegate = self
        
        
        //cameraUpdate()
        
        
    }
    private var FIELD_STRENGTH:CGFloat = /*9.8*/ 6 * CGFloat(SPEED_PERCENTAGE) /// 10  9.8
    func addPhysicsField(){
        myPhysicsFieldNode = SCNNode()
        myScene.rootNode.addChildNode(myPhysicsFieldNode)
        myPhysicsFieldNode.position = SCNVector3(x: 0, y: 0, z: 0)//myStageNode.position
        //       myPhysicsField = SCNPhysicsField()
        myPhysicsField = SCNPhysicsField.springField()//radialGravityField() //vortexField()
        myPhysicsFieldNode.physicsField = myPhysicsField
        //myPhysicsField.minimumDistance = CGFloat.infinity// 100
        //       myPhysicsField.active = true
        myPhysicsField.strength = FIELD_STRENGTH
        //myPhysicsField.falloffExponent = CGFloat(0.0)
    }
    
    func addEmittorNode(){
        myEmittorNode = SCNNode()
        myParticleSystem = SCNParticleSystem(named: "MyParticleSystem3.scnp", inDirectory: nil)
        myParticleSystem.affectedByPhysicsFields = true
        //myParticleSystem.birthLocation = ...
        //myEmittorNode.addParticleSystem(myParticleSystem)
        //myParticleSystem.reset()
        //myParticleSystem
        myScene.rootNode.addChildNode(myEmittorNode)
        //myEmittorNode.hidden = true
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        /*
        let exit = myMaze.mazeCellMatrix[myMaze.exitPoint]
        let player = myPlayerNode.presentationNode()
        
        if contact.nodeA == player && contact.nodeB == exit || contact.nodeB == player && contact.nodeA == exit{
        
        isMovingToUpperLevel = true
        
        }
        */
    }
    
    override func mouseDown(theEvent: NSEvent) {
        print("mouseDown - GameViewController")
        super.mouseDown(theEvent)
//        self.nextResponder!.mouseDown(theEvent)
    }
    
    override func mouseUp(theEvent: NSEvent) {
        super.mouseUp(theEvent)
//        self.nextResponder!.mouseUp(theEvent)
    }
    
    override func keyDown(theEvent: NSEvent){
        Swift.print("KeyDown - GameViewController")
        self.myGameScene.keyDown(theEvent)
        //myHudOverlay.keyDown(theEvent)
        //gameScene.keyDown(theEvent)
    }
    
    override func keyUp(theEvent: NSEvent) {
        self.myGameScene.keyUp(theEvent)
        //myHudOverlay.keyUp(theEvent)
        //gameScene.keyUp(theEvent)
    }
    
    func deathEffectUpdate(){
        if myGameScene.isSlowedDown{
            if myParticleSystem.affectedByPhysicsFields{
                myParticleSystem.affectedByPhysicsFields = false
            }
        }else if !myGameScene.isSlowedDown{
            
            if !myParticleSystem.affectedByPhysicsFields{
                myParticleSystem.affectedByPhysicsFields = true
            }
        }
        
        if myPlayer!.isDying{self.deathScene(myGameScene.deltaTime)}
        
    }
    
    func isPlayerMovingToNewAreaVertically()->Bool{
        var vertically:Bool = false
        
        if myGameScene!.leavingVelocity.dx.abs() > myGameScene!.leavingVelocity.dy.abs(){
            vertically = false
        }else if myGameScene!.leavingVelocity.dy.abs() > myGameScene!.leavingVelocity.dx.abs(){
            vertically = true
        }
        
        return vertically
    }
    
    func playerUpdate(){
        
        let presentationPlayer = myPresentationPlayer
        let player = myPlayer
        
        if myGameScene.hasWorldMovement{
            myPlayerNode.position = SCNVector3(x: 0, y: 0, z: myPlayerNode.position.z)
        }
        else{// now done in the GameScene.swift directly
            updateMyPlayerNode()
        }
        
        //check if player is alive and relate it to 3D
        let isAlive = myPlayer!.isAlive
        let isHidden = myPlayerNode.hidden
        if isAlive {//&& myPlayerNode.hidden{
            if isHidden{
                myPlayerNode.hidden = false
                
                for (_, tailPiece) in myPlayerTailNodeArray.enumerate(){
                    tailPiece.hidden = true
                }
                
                let playerLives = myGameScene.playerLives
                if playerLives > 1{
                    for tailIndex in 0...playerLives - 2{
                        myPlayerTailNodeArray[tailIndex].hidden = false
                    }
                    
                }
                
                
                if myGameScene.isFirstRound {
                    myPlayerNode.hidden = true
                    for (_, tailPiece) in myPlayerTailNodeArray.enumerate(){
                        
                        tailPiece.hidden = true
                        
                    }
                }
                //                myEmittorNode.removeParticleSystem(myParticleSystem)
                //***                gameView.scene!.removeParticleSystem(myParticleSystem)
                myPhysicsFieldNode.position = SCNVector3(x: (-gameFrame.size.width/2 + myPlayer!.position.x)  * 10  /*myStageNode.geometry!.*/ / gameFrame.size.width , y: (-gameFrame.size.height/2 + myPlayer!.position.y)  * 10  / gameFrame.size.height, z: 0/*myPlayerNode.position.z*/)
                
                if !myGameScene.hasWorldMovement{
                    myPhysicsFieldNode.position = self.myStageNode.position//SCNVector3(x: (gameFrame.size.width/2 )  * 10  /*myStageNode.geometry!.*/ / gameFrame.size.width , y: (gameFrame.size.height/2)  * 10  / gameFrame.size.height, z: 0/*myPlayerNode.position.z*/)
                }
                
            }
        }else {//if !myPlayerNode.hidden{
            if !isHidden{
                myPhysicsFieldNode.position = SCNVector3(x: (gameFrame.size.width/2 - myPlayer!.deathPosition.x)  * 10  /*myStageNode.geometry!.*/ / gameFrame.size.width , y: (gameFrame.size.height/2 - myPlayer!.deathPosition.y)  * 10  / gameFrame.size.height, z: myPlayerNode.position.z)
                myEmittorNode.position = myPlayerNode.position
                //myEmittorNode.position = SCNVector3(x: (presentationPlayer!.deathPosition.x) * 10/*myStageNode.geometry!.*/ / gameFrame.size.width , y: (presentationPlayer!.deathPosition.y) * 10 / gameFrame.size.height, z: myPlayerNode.position.z)
                
                if !myGameScene.hasWorldMovement{
                    myPhysicsFieldNode.position = self.myStageNode.position//SCNVector3(x: (gameFrame.size.width/2 )  * 10  /*myStageNode.geometry!.*/ / gameFrame.size.width , y: (gameFrame.size.height/2)  * 10  / gameFrame.size.height, z: 0/*myPlayerNode.position.z*/)
                    
                    //myPlayerNode.position = SCNVector3(x: (myPlayer!.deathPosition.x - gameFrame.size.width/2) * 10/*myStageNode.geometry!.*/ / gameFrame.size.width , y: (myPlayer!.deathPosition.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: 0/*myPlayerNode.position.z*/)
                    
                    myEmittorNode.position = myPlayerNode.position
                    
                    
                }
                
                if myPlayer!.isDying{
                    myEmittorNode.addParticleSystem(myParticleSystem)
                }else if !myPlayer!.isDying{
                    
                }
                
                if myGameScene.isFirstRound {
                    
                    for (_, tailPiece) in myPlayerTailNodeArray.enumerate(){
                        
                        tailPiece.hidden = true
                        
                    }
                }
                
                //                gameView.scene!.addParticleSystem(myParticleSystem, withTransform: myPlayerNode.worldTransform)
                //myEmittorNode.remove
                myPlayerNode.hidden = true
                /*for (_, tailPiece) in myPlayerTailNodeArray.enumerate(){
                    tailPiece.hidden = true
                }
                */
                //myParticleSystem.reset()
            }
        }
    }
    
    
    let maxCameraDistance:CGFloat = 15
    let minimumCameraAngle:CGFloat = 25 //Maximum value allowed: 90
    
    var cameraMovingtoNewAreaPosition:SCNVector3 = SCNVector3(x: 0 , y: 0, z: 0)
    var leavingLastUpdateTime: NSTimeInterval = 0
    var leavingDeltaTime: NSTimeInterval = 0
    
    var willChangeCameraForNewArea:Bool = false
    var didChangeCameraForNewArea:Bool = false
    
    func cameraUpdate(currentTime: NSTimeInterval){
        
        
        
        if myCameraNode == nil{
            self.setupCamera()
        }
        
        if myCameraNode.constraints != nil{
            myCameraNode.constraints = nil
        }
        
        if !myGameScene.isLeavingOldArea{
            //if myCameraNode.constraints != nil{
            //    myCameraNode.constraints = nil
            //}
        //}

            leavingDeltaTime = 0
            leavingLastUpdateTime = currentTime
        
        
            //if !myGameScene.hasWorldMovement{
            let playerRadius:CGFloat = (myPlayerNode.geometry as! SCNSphere).radius
            // pathegorian theorem
            let xMaxValuePlayerNode:CGFloat = (myStageNode.geometry as! SCNPlane).width/2 - playerRadius - cornerBlockFrame.width/10
            let yMaxValuePlayerNode:CGFloat = (myStageNode.geometry as! SCNPlane).height/2 - playerRadius - cornerBlockFrame.height/10
            
            // c squared = x squared + y squared
            let cMaxValuePlayerNode:CGFloat = sqrt( pow(xMaxValuePlayerNode, 2) + pow(yMaxValuePlayerNode, 2) )
            
            let midMaxValuePlayerNode:CGFloat = xMaxValuePlayerNode + (cMaxValuePlayerNode - xMaxValuePlayerNode)/2
            
            var xValue:CGFloat = maxCameraDistance * (myPlayerNode.position.x - myStageNode.position.x) / xMaxValuePlayerNode //midMaxValuePlayerNode//cMaxValuePlayerNode //c: makes the camera angle relative to the corners
            var yValue:CGFloat = maxCameraDistance * (myPlayerNode.position.y - myStageNode.position.y) / yMaxValuePlayerNode //midMaxValuePlayerNode//cMaxValuePlayerNode //c: makes the camera angle relative to the corners
            
            
            let cValueCameraScale:CGFloat = sqrt( pow( (xValue), 2) + pow( (yValue), 2))
            
            var zValueAlternative:CGFloat = sqrt( pow(maxCameraDistance, 2) - pow(cValueCameraScale, 2))
            if zValueAlternative <= maxCameraDistance * minimumCameraAngle/90{
                zValueAlternative = maxCameraDistance * minimumCameraAngle/90
                
                xValue = xValue / cValueCameraScale * sqrt( (1 - pow(minimumCameraAngle/90, 2)) * pow(maxCameraDistance,2) )
                yValue = yValue / cValueCameraScale * sqrt( (1 - pow(minimumCameraAngle/90, 2)) * pow(maxCameraDistance,2) )
                
            }
            
            
            
            let x:CGFloat = myPlayerNode.position.x - xValue //-xValue
            let y:CGFloat = myPlayerNode.position.y - yValue //-yValue
            let z:CGFloat = /*myPlayerNode.position.z +*/ zValueAlternative//zValue
            
            /*
            if myPlayer!.isStunned{
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.2)
            myCameraNode.position.x = x
            myCameraNode.position.y = y
            myCameraNode.position.z = z
            //myCameraNode.position = SCNVector3(x: x , y: y, z: z)
            SCNTransaction.commit()
            }else{
                myCameraNode.position = SCNVector3(x: x , y: y, z: z)
            }
            */
            
            /*if myGameScene.isNeutralCamera && myGameScene.hasEnteredNeutral{
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                myCameraNode.position = SCNVector3(x: x , y: y, z: z)
                SCNTransaction.commit()
                myGameScene.isNeutralCamera = false
            }else if !myGameScene.hasEnteredNeutral{
                myCameraNode.position = SCNVector3(x: x , y: y, z: z)
            }*/
            myCameraNode.position = SCNVector3(x: x , y: y, z: z)
            //myCameraNode.position.z = z
            cameraMovingtoNewAreaPosition = myCameraNode.position
            //c = 20 => max distance from camera to player c pow 2 = 400 = (x2 + y2) + z2 //blah
            
            //}else {
            
            //}
        }else if myGameScene.isLeavingOldArea{
            
            leavingDeltaTime += currentTime - leavingLastUpdateTime
            leavingLastUpdateTime = currentTime
            //myCameraNode.position = cameraMovingtoNewAreaPosition
            
            if leavingDeltaTime > myGameScene.leavingTime{
                didChangeCameraForNewArea = false
                willChangeCameraForNewArea = false
                
            
            }else if leavingDeltaTime > myGameScene.leavingTime/2{
                if !didChangeCameraForNewArea{
                    willChangeCameraForNewArea = true
                    
                    if !isPlayerMovingToNewAreaVertically(){
                        //SCNTransaction.begin()
                        //SCNTransaction.setAnimationDuration(0.1)
                        myCameraNode.position = SCNVector3(x: myStageNode.position.x - cameraMovingtoNewAreaPosition.x, y: cameraMovingtoNewAreaPosition.y, z: cameraMovingtoNewAreaPosition.z)
                        //SCNTransaction.commit()
                    }else if isPlayerMovingToNewAreaVertically(){
                        //SCNTransaction.begin()
                        //SCNTransaction.setAnimationDuration(0.1)
                        myCameraNode.position = SCNVector3(x: cameraMovingtoNewAreaPosition.x, y: myStageNode.position.y - cameraMovingtoNewAreaPosition.y, z: cameraMovingtoNewAreaPosition.z)
                        //SCNTransaction.commit()
                    }
                    /*
                    if myGameScene!.leavingVelocity.dx.abs() > myGameScene!.leavingVelocity.dy.abs(){
                        myCameraNode.position = SCNVector3(x: myStageNode.position.x - cameraMovingtoNewAreaPosition.x, y: cameraMovingtoNewAreaPosition.y, z: cameraMovingtoNewAreaPosition.z)
                    
                    }else if myGameScene!.leavingVelocity.dy.abs() > myGameScene!.leavingVelocity.dx.abs(){
                        myCameraNode.position = SCNVector3(x: cameraMovingtoNewAreaPosition.x, y: myStageNode.position.y - cameraMovingtoNewAreaPosition.y, z: cameraMovingtoNewAreaPosition.z)
                        
                    }
                    */
                    
                }
                //fix camera seeing stage problem
                /*
                if myCameraNode.constraints == nil{
                myCameraNode.position = cameraStartPosition
                let lookAtStageConstraint = SCNLookAtConstraint(target: myStageNode)
                lookAtStageConstraint.gimbalLockEnabled = false//true //false
                myCameraNode.constraints = [lookAtStageConstraint]
                
                }
                */
                
            }
            
            
            
            
        }
        
        
        
            if myCameraNode.constraints == nil{
                
                let lookAtPlayerConstraint = SCNLookAtConstraint(target: myPlayerNode)
                lookAtPlayerConstraint.gimbalLockEnabled = false//true//false
                myCameraNode.constraints = [lookAtPlayerConstraint]
                
            }
        
        
        
        
    }
    
    func animationUpdate(){
        //if myPlayerNode.position.x == myGameScene.myPlayerNodeCopy.position.x &&
        //myPlayerNode.position.y == myGameScene.myPlayerNodeCopy.position.y{
            myView.playing = true
        //}
    }
    
    
    var willComeToLife:Bool = true
    func updateMyPlayerNode(){
        if myPlayerNode == nil{
            self.addPlayerNode()
        }
        
        if !myGameScene.isLeavingOldArea{
            
            
        
           // SCNTransaction.begin()
           // SCNTransaction.setAnimationDuration(0)
            //myPlayerNode.position = myGameScene.myPlayerNodeCopy.position
            
            //all the detail added to account for corner hit deaths ie. isEdgeHitDeathOn = true
            
            if myPlayer!.isAlive{
                if willComeToLife{
                    myPlayerNode.position = SCNVector3(x: (myPlayer!.originalPosition.x - gameFrame.size.width/2) * 10/*myStageNode.geometry!.*/ / gameFrame.size.width , y: (myPlayer!.originalPosition.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: 0/*myPlayerNode.position.z*/)
                    willComeToLife = false
                }else{
                    myPlayerNode.position = SCNVector3(x: (myPlayer!.position.x - gameFrame.size.width/2) * 10/*myStageNode.geometry!.*/ / gameFrame.size.width , y: (myPlayer!.position.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: 0/*myPlayerNode.position.z*/)
                }
            
            }else if !myPlayer!.isAlive{
                willComeToLife = true
                myPlayerNode.position = SCNVector3(x: (myPlayer!.deathPosition.x - gameFrame.size.width/2) * 10/*myStageNode.geometry!.*/ / gameFrame.size.width , y: (myPlayer!.deathPosition.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: 0/*myPlayerNode.position.z*/)
                if gameScene.isFirstRound{
                    myPlayerNode.position = SCNVector3(x: (myPlayer!.originalPosition.x - gameFrame.size.width/2) * 10/*myStageNode.geometry!.*/ / gameFrame.size.width , y: (myPlayer!.originalPosition.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: 0/*myPlayerNode.position.z*/)
                }
            }
            
            let playerLives = myGameScene.playerLives
            if playerLives > 0{//1
                for (tailIndex, _/*tailPiece*/) in myPlayerTailNodeArray.enumerate(){
                    
                    if myPlayer!.isAlive{
                        
                        myPlayerTailNodeArray[tailIndex].position = SCNVector3(x: (myPlayerTail[tailIndex].position.x ) * 10 / gameFrame.size.width + myPlayerNode.position.x , y: (myPlayerTail[tailIndex].position.y) * 10 / gameFrame.size.height + myPlayerNode.position.y, z: 0)
                        //myPlayerTailNodeArray[tailIndex].hidden = false
                        
                    }else if !myPlayer!.isAlive{
                        
                        myPlayerTailNodeArray[tailIndex].position = SCNVector3(x: (myPlayerTail[tailIndex].position.x - gameFrame.size.width/2) * 10 / gameFrame.size.width , y: (myPlayerTail[tailIndex].position.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: 0)
                        if myGameScene.isFirstRound{
                            //myPlayerTailNodeArray[tailIndex].hidden = true
                        }
                    }
                    
                }
                
            }
            
            
            //SCNTransaction.commit()
        
        
        }else if myGameScene.isLeavingOldArea{
            let speedReductionFactor:CGFloat = 20
            
            var velocityX = myPlayer!.physicsBody!.velocity.dx
            var velocityY = myPlayer!.physicsBody!.velocity.dy
            
            if velocityX.abs() > (myGameScene!.leavingVelocity.dx / speedReductionFactor).abs(){
                velocityX = myGameScene!.leavingVelocity.dx / speedReductionFactor
            }
            if velocityY.abs() > (myGameScene!.leavingVelocity.dy / speedReductionFactor).abs(){
                velocityY = myGameScene!.leavingVelocity.dy / speedReductionFactor
            }
            
            //SCNTransaction.begin()
            //SCNTransaction.setAnimationDuration(0)
            
            myPlayerNode.position = SCNVector3(x: myPlayerNode.position.x + (velocityX * 10 / gameFrame.size.width) , y: myPlayerNode.position.y + (velocityY * 10 / gameFrame.size.height), z: 0/*myPlayerNode.position.z*/)
            
            for (tailIndex, _/*tailPiece*/) in myPlayerTailNodeArray.enumerate(){
                
                //if myPlayer!.isAlive{
                    
                    myPlayerTailNodeArray[tailIndex].position = SCNVector3(x: (myPlayerTail[tailIndex].position.x ) /* * velocityX */ * 10 / gameFrame.size.width + myPlayerNode.position.x, y: (myPlayerTail[tailIndex].position.y) /* * velocityY */ * 10 / gameFrame.size.height + myPlayerNode.position.y, z: 0)
                    //myPlayerTailNodeArray[tailIndex].hidden = false
                    
               // }
            }
            //SCNTransaction.commit()
            
            //check if the Player has arrived in the new area
            if leavingDeltaTime > myGameScene.leavingTime/2{
                var didReachNewArea:Bool = false
                
                if myPlayerNode.position.x.abs() < myGameScene.arrivingPosition.x.abs() && !isPlayerMovingToNewAreaVertically(){
                    
                    if leavingDeltaTime > myGameScene.leavingTime {
                        didReachNewArea = true
                    }
                    
                    
                }else if myPlayerNode.position.y.abs() < myGameScene.arrivingPosition.y.abs() && isPlayerMovingToNewAreaVertically(){
                    
                    if leavingDeltaTime > myGameScene.leavingTime {
                        didReachNewArea = true
                    }
                    
                }
                
                if didReachNewArea{
                    myGameScene.isLeavingOldArea = false
                    //Increase stage count / Level count
                    myGameScene.stageUpLevelUp()
                    //********************************
                    
                    myGameScene.arrivedInNewArea(myGameScene.arrivingPosition, playerVelocity: myGameScene.leavingVelocity)
                    //self.paused = true
                    
                    myGameScene.afterArrivingInNewAreaAction(myGameScene.arrivingPosition, playerVelocity: myGameScene.leavingVelocity)
                    
                    //didReachNewArea = false
                }
                
            }
            
            
            if willChangeCameraForNewArea{
                willChangeCameraForNewArea = false
                didChangeCameraForNewArea = true
                let newPlayerNodePositionX = myStageNode.position.x - myPlayerNode.position.x
                let newPlayerNodePositionY = myStageNode.position.y - myPlayerNode.position.y
                
                if !isPlayerMovingToNewAreaVertically(){
                    myPlayerNode.position = SCNVector3(x: newPlayerNodePositionX, y: myPlayerNode.position.y , z: myPlayerNode.position.z)
                    
                }else if isPlayerMovingToNewAreaVertically(){
                    myPlayerNode.position = SCNVector3(x: myPlayerNode.position.x, y: newPlayerNodePositionY , z: myPlayerNode.position.z)
                    
                }
                
                
                
                for (tailIndex, _/*tailPiece*/) in myPlayerTailNodeArray.enumerate(){
                    
                    //if myPlayer!.isAlive{
                    
                    myPlayerTailNodeArray[tailIndex].position = SCNVector3(x: myPlayerTailNodeArray[tailIndex].position.x - newPlayerNodePositionX , y: myPlayerTailNodeArray[tailIndex].position.y - newPlayerNodePositionY, z: 0)
                    //myPlayerTailNodeArray[tailIndex].hidden = false
                    
                    // }
                }
            }
            
            
            
        }
    }
    
    
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
        
        //self.cameraUpdate()
        
        //updateMyPlayerNode()
        //print("3D")
        
        //self.update(time, forScene: myGameScene)
        
        self.animationUpdate()
        
        
       
        
        
        self.deathEffectUpdate() // if isSlowedDown or not
        self.playerUpdate()
        
        // Moving to a new stage
        /*        if myGameScene.isMovingToNextArea{
        myGameScene.lastUpdatedTime = currentTime
        return
        }
        */
        // animating a death scene shaking...
        /*        deltaTime = currentTime - lastUpdatedTime
        lastUpdatedTime = currentTime
        */
        
        //if myPlayer!.isDying{self.deathScene(myGameScene.deltaTime)}
        
        
        self.cameraUpdate(time)
        
    }
    
    func renderer(aRenderer: SCNSceneRenderer, didApplyAnimationsAtTime time: NSTimeInterval) {
        
        
    }
    
    func renderer(aRenderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        //myGameScene.didSimulatePhysics()
        //self.playerUpdate()
        //print("3D")
        //didSimulatePhysicsForScene(myGameScene)
    }
    
    func renderer(aRenderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        //self.playerUpdate()
        //self.animationUpdate()
        //print("3D")
        
    }
    
    func renderer(aRenderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        //self.playerUpdate()
        //myPlayerNode.position = myGameScene.myPlayerNodeCopy.position
        //animationUpdate()
        
        //print("3D")
       // updateMyPlayerNode()
        
        if self.myStageNode == nil{
            print("FUUUUUUUUUUUCK")//self.setupEnvironment()
        }
        
    }
    //******************************
    //*****************************
    
    
    func addPlayerNode(){
        //myGlobalPlayerNode = self.myPlayerNode
        myPlayerNode = SCNNode()
        //myGlobalPlayerNode.position = self.myPlayerNode.position
        let player = myPlayerNode
//        let presentationPlayer = myPresentationPlayer
        /*presentationPlayer!.hidden = true
        for child in presentationPlayer!.children {
            //let child = node
            child.hidden = false
            
        }
        */
        
        player.geometry = SCNSphere(radius: myPlayer!.radius * 10 / gameFrame.width)// SCNSphere(radius: 5)
        
        //player.rotation = SCNVector4(x: 1, y: 0, z: 0, w: CGFloat(M_PI)/4 )
        player.position = SCNVector3(x: 0, y: 0, z: 0)
        player.geometry!.firstMaterial!.diffuse.contents = NSColor.blueColor()
        //myTestTrap.geometry?.firstMaterial?.doubleSided = true
        
        //fix the ratio so that it works for all resizing - stageNode size vs gameFrame size
//        player.position = SCNVector3(x: (presentationPlayer!.position.x - gameFrame.size.width/2) * 10/*myStageNode.geometry!.*/ / gameFrame.size.width , y: (presentationPlayer!.position.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: 0)
        
        myScene.rootNode.addChildNode(player)
        //myPlayerNode.hidden = true
        player.hidden = true
        
        func addPlayerTailNode()->SCNNode{
            let tail = SCNNode()
            tail.geometry = SCNSphere(radius: myPlayerTail[0].radius * 10 / gameFrame.width)// SCNSphere(radius: 5)
            
            //player.rotation = SCNVector4(x: 1, y: 0, z: 0, w: CGFloat(M_PI)/4 )
            tail.position = SCNVector3(x: 0, y: 0, z: 0)
            tail.geometry!.firstMaterial!.diffuse.contents = NSColor.blueColor()
            
            return tail
            
        }
        
        
        
        if myGameScene.playerLivesMAX > 1{
            myPlayerTailNodeArray = []
            
            for life in 0...(myGameScene.playerLivesMAX - 2){
                //myPlayerTail.append(Player(r: radius))
                
                myPlayerTailNodeArray.append(addPlayerTailNode())
                myPlayerTailNodeArray[life].hidden = true
                myScene.rootNode.addChildNode(myPlayerTailNodeArray[life])
            }
        }
        
        
        /*
        let playerLives = myGameScene.playerLives
        if playerLives > 1{
            for tailIndex in 0...playerLives - 2{
                
                let tailPiece = myPlayerTail[tailIndex]
                if tailPiece.parent == nil{
                    //self.addChild(tailPiece)
                    myPlayer!.addChild(tailPiece)
                }
                
                let presentationTailPiece = myPresentationTail[tailIndex]
                if presentationTailPiece.parent == nil{
                    //self.world.addChild(presentationTailPiece)
                    myPresentationPlayer!.addChild(presentationTailPiece)
                }
            }
        }
    */
        
    }
    
    
    
    
    
    func setupEnvironment(){
        let myTestTrap = SCNNode()
        self.myStageNode = myTestTrap
        /*
        let myMaterial = SCNMaterial()
        myMaterial.diffuse.contents = gameScene
        gameScene!.size = CGSize(width: 10, height: 10)
        //myMaterial.diffuse.contents = SKScene(size: <#CGSize#>)
        myTestTrap.geometry?.materials = [myMaterial]
        */
        if myGameScene == nil{
            myGameScene = GameScene(size: CGSize(width: 100, height: 100))
        }
        gameScene = self.myGameScene
        let materialScene = myGameScene//SKScene(size: CGSize(width: 100, height: 100))
        //materialScene.size = CGSize(width: 100, height: 100)
        //        myGameSceneView.presentScene(myGameScene)
        //        materialScene.didMoveToView(myGameSceneView)
        //materialScene.yScale = CGFloat(-1)
        
        myTestTrap.geometry = SCNPlane(width: 10, height: 10)// SCNSphere(radius: 5)
        myTestTrap.position = SCNVector3(x: 0, y: 0, z: 0)
        //        myTestTrap.rotation = SCNVector4(x: 1, y: 0, z: 0, w: CGFloat(M_PI) )
        myTestTrap.rotation = SCNVector4(x: 1, y: 0, z: 0, w: CGFloat(M_PI))//3 * CGFloat(M_PI)/4 ) //CGFloat(M_PI))
        myTestTrap.geometry!.firstMaterial!.diffuse.contents = materialScene
        //myTestTrap.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeTranslation(5, 5, 1)
        //myTestTrap.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(2, 2, 2)
        myTestTrap.geometry!.firstMaterial!.doubleSided = true   //****** Fix sides
        //        myTestTrap.transform = SCNMatrix4MakeRotation(CGFloat(M_PI), 1, 0, 0) //******* Fix sides
        
        //        myTestTrap.geometry?.firstMaterial?.cullMode = SCNCullMode.Front
        
        myScene.rootNode.addChildNode(myTestTrap)
        
    }
    
    func setupLights(){
        
        /*
        let myLight = SCNLight()
        let myLightNode = SCNNode()
        myLight.type = SCNLightTypeOmni
        myLightNode.light = myLight
        myLightNode.position = SCNVector3(x: -30, y: 30, z: 60)
        myScene.rootNode.addChildNode(myLightNode)
        */
        myView.autoenablesDefaultLighting = true
        
    }
    
    let cameraStartPosition:SCNVector3 = SCNVector3(x: 0, y: 0, z: 15)// 15 = maxCameraDistance
    
    func setupCamera(){
        // create and add a camera to the scene
        if myCameraNode == nil{
            myCamera = SCNCamera()
            myCamera.xFov = 40
            myCamera.yFov = 40
            myCameraNode = SCNNode()
            myCameraNode.camera = myCamera
            // allows the user to manipulate the camera
            self.gameView!.allowsCameraControl = true
            myScene.rootNode.addChildNode(myCameraNode)
        }
        myCameraNode.camera = myCamera
        myCameraNode.position = SCNVector3(x: 0, y: 0 /*-gameFrame.size.height/2 / 10*/ , z: maxCameraDistance)//12)//CGFloat(levelHeight) + 12)
        
        //myCameraNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: 1*CGFloat(M_PI)/4)
        //myScene.rootNode.addChildNode(myCameraNode)
        
        // allows the user to manipulate the camera
        //self.gameView.allowsCameraControl = true
    }
    
    func setupHUD(){
        //add Heads Up Display (SpriteKit Overlay) code here!!!
        
        myHudOverlay = HudOverlay(size: self.view.bounds.size)//CGSize(width: 1000, height: 1000))
        // myHudOverlay.size = CGSize(width: 100, height: 100)
        //        myHudOverlayView.presentScene(myHudOverlay)
        //        myHudOverlay.didMoveToView(myHudOverlayView)
        
        self.myView.overlaySKScene = myHudOverlay
        //self.myView.overlaySKScene = myGameScene
        
        
//        self.myView.overlaySKScene!.delegate = self
//        self.myView!.window!.makeFirstResponder(myHudOverlay)
//        self.myView.noResponderFor("mouseDown:")
                
        
    }
    
    func setupDebugDisplay(){
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
    }
    
    override func awakeFromNib(){
        
        
        myView = self.gameView!
        myScene = SCNScene()
        myView.scene = myScene
        self.view.addSubview(myView)
        
        myView.backgroundColor = NSColor.blackColor()//NSColor.whiteColor()//NSColor.blackColor()
        //setup scene
        //self.setupEnvironment()
        self.setupLights()
        self.setupCamera()
        //self.addPlayerNode()
        
        
        
        // DEBUG
        self.setupDebugDisplay()
        
        // configure the view
        // self.gameView!.backgroundColor = NSColor.blackColor()
        
        
        //*********************************
        //override func nextResponder() -> UIResponder? (for iOS in GameView Class)
        //self.gameView.delegate = self
        //self.gameView.nextResponder = self
        //*********************************
        
    }
    
    private var sizeEffectSwitch:Bool = false
    private var sizeEffectSwitchCounter = 0
    
    private func deathScene(deltaTime: CFTimeInterval){
        
        let centerPoint = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
        var differenceVector = CGPoint(x: centerPoint.x - myPlayer!.deathPosition.x, y: centerPoint.y - myPlayer!.deathPosition.y)
        if !myGameScene.hasWorldMovement{
            differenceVector = CGPoint(x: 0, y: 0)
        }
        if self.myGameScene.deathTimer == 0{
            // --- used in GameScene -- 2D
            //self.slowDownSceneTime()
            // --------------------------
            sizeEffectSwitch = true
        }
        
        //        self.deathTimer += deltaTime
        if self.myGameScene.deathTimer <= 1 || !sizeEffectSwitch{
            //return
            ++sizeEffectSwitchCounter
            if sizeEffectSwitch && sizeEffectSwitchCounter >= 3 {
                
                //                self.myStageNode.position = SCNVector3(x: ( 1 - 1.01 ) * gameFrame.width/2 + differenceVector.x, y: ( 1 - 1.01 ) * gameFrame.height/2 + differenceVector.y, z: 0)
                self.myStageNode.scale = SCNVector3(x: 1.01, y: 1.01, z: 1)  //.setScale(1.01)
                sizeEffectSwitch = !sizeEffectSwitch
                sizeEffectSwitchCounter = 0
            }
            else if !sizeEffectSwitch && sizeEffectSwitchCounter >= 3{
                self.myStageNode.scale = SCNVector3(x: 1, y: 1, z: 1)//.setScale(1)
                //                self.myStageNode.position = SCNVector3(x: differenceVector.x, y: differenceVector.y, z: 0) //differenceVector
                sizeEffectSwitch = !sizeEffectSwitch
                sizeEffectSwitchCounter = 0
            }
            
            
        }
        else{
            //           self.deathTimer = 0
            //           myPlayer!.isDying = false
            
        }
        
    }
    
    
    
}
