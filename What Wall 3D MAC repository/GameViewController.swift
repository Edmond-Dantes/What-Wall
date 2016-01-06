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

var gameScene:GameScene!


class GameViewController: NSViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate{//, SKPhysicsContactDelegate  {
    
    @IBOutlet weak var gameView: GameView!
    var myView:SCNView!
    var myScene:SCNScene!
    
    var myLight:SCNNode!
    var myCamera:SCNCamera!
    var myCameraNode:SCNNode!
    
    var myPlayerNode:SCNNode!
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
        
        //Heads Up Display (SpriteKit Overlay)
        self.setupHUD()
        
        self.setupEnvironment()
        
        self.addPlayerNode()
        
        self.addPhysicsField()
        
        self.addEmittorNode()
        
        //Heads Up Display (SpriteKit Overlay)
        //self.setupHUD()
        
        
        myScene.physicsWorld.contactDelegate = self
        myScene.physicsWorld.gravity = SCNVector3(x: 0, y: 0, z: 0)
        
        
        self.gameView.delegate = self
        
    }
    private var FIELD_STRENGTH:CGFloat = 9.8 * CGFloat(SPEED_PERCENTAGE) /// 10
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
    
    override func keyDown(theEvent: NSEvent){
        self.myGameScene.keyDown(theEvent)
        //myHudOverlay.keyDown(theEvent)
        //gameScene.keyDown(theEvent)
    }
    
    override func keyUp(theEvent: NSEvent) {
        self.myGameScene.keyUp(theEvent)
        //myHudOverlay.keyUp(theEvent)
        //gameScene.keyUp(theEvent)
    }
    
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
        let presentationPlayer = myPresentationPlayer
        let currentTime = time
        
        if myGameScene.isSlowedDown /*&& myPhysicsField.strength == FIELD_STRENGTH*/{
          /* if myPhysicsFieldNode.physicsField != nil{
                myPhysicsFieldNode.physicsField = nil
            }*/
            print("\(myGameScene.isSlowedDown)")
//find fix
            if myParticleSystem.affectedByPhysicsFields{
                myParticleSystem.affectedByPhysicsFields = false
            }
        }else if /*myPhysicsField.strength != FIELD_STRENGTH &&*/ !myGameScene.isSlowedDown{
            /*if myPhysicsFieldNode.physicsField == nil{
               myPhysicsFieldNode.physicsField = myPhysicsField
            }*/
//find fix
            print("\(myGameScene.isSlowedDown)")
            if !myParticleSystem.affectedByPhysicsFields{
                myParticleSystem.affectedByPhysicsFields = true
            }
        }
        
        
        
        //self.gameView!.backgroundColor = NSColor.clearColor()//NSColor.blackColor()
        
        //account for hasWorldMovement
        //myPlayerNode.deathposition = SCNVector3(x: (presentationPlayer!.deathPosition.x - gameFrame.size.width/2) * 10/*myStageNode.geometry!.*/ / gameFrame.size.width , y: (presentationPlayer!.deathPosition.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: 0)
        if myGameScene.hasWorldMovement{
            myPlayerNode.position = SCNVector3(x: 0, y: 0, z: myPlayerNode.position.z)
        }
        else{
            myPlayerNode.position = SCNVector3(x: (presentationPlayer!.position.x - gameFrame.size.width/2) * 10/*myStageNode.geometry!.*/ / gameFrame.size.width , y: (presentationPlayer!.position.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: myPlayerNode.position.z)
        }
        
        //check if player is alive and relate it to 3D
        let isAlive = myPlayer!.isAlive
        let isHidden = myPlayerNode.hidden
        if isAlive {//&& myPlayerNode.hidden{
            if isHidden{
                myPlayerNode.hidden = false
                if myGameScene.isFirstRound {
                    myPlayerNode.hidden = true
                }
                //                myEmittorNode.removeParticleSystem(myParticleSystem)
                //***                gameView.scene!.removeParticleSystem(myParticleSystem)
                myPhysicsFieldNode.position = SCNVector3(x: (gameFrame.size.width/2) * 10/*myStageNode.geometry!.*/ / gameFrame.size.width , y: (gameFrame.size.height/2) * 10 / gameFrame.size.height, z: myPlayerNode.position.z)
            }
        }else {//if !myPlayerNode.hidden{
            if !isHidden{
                myPhysicsFieldNode.position = SCNVector3(x: (myGravityFieldNode.position.x - gameFrame.size.width/2) * 10/*myStageNode.geometry!.*/ / gameFrame.size.width , y: (myGravityFieldNode.position.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: myPlayerNode.position.z)
                myEmittorNode.position = SCNVector3(x: (presentationPlayer!.deathPosition.x) * 10/*myStageNode.geometry!.*/ / gameFrame.size.width , y: (presentationPlayer!.deathPosition.y) * 10 / gameFrame.size.height, z: myPlayerNode.position.z)
                myEmittorNode.addParticleSystem(myParticleSystem)
                
                //                gameView.scene!.addParticleSystem(myParticleSystem, withTransform: myPlayerNode.worldTransform)
                //myEmittorNode.remove
                myPlayerNode.hidden = true
                
                //myParticleSystem.reset()
            }
        }
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
        if myPlayer!.isDying{self.deathScene(myGameScene.deltaTime)}
        
        
        
    }
    
    func renderer(aRenderer: SCNSceneRenderer, didApplyAnimationsAtTime time: NSTimeInterval) {
        
    }
    
    func renderer(aRenderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
        //myGameScene.didSimulatePhysics()
    }
    
    func renderer(aRenderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        
    }
    
    func renderer(aRenderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        
    }
    //******************************
    //*****************************
    
    
    func addPlayerNode(){
        self.myPlayerNode = SCNNode()
        let player = self.myPlayerNode
        let presentationPlayer = myPresentationPlayer
        
        player.geometry = SCNSphere(radius: myPlayer!.radius * 10 / gameFrame.width)// SCNSphere(radius: 5)
        
        //player.rotation = SCNVector4(x: 1, y: 0, z: 0, w: CGFloat(M_PI)/4 )
        player.position = SCNVector3(x: 0, y: 0, z: 0)
        player.geometry?.firstMaterial?.diffuse.contents = NSColor.blueColor()
        //myTestTrap.geometry?.firstMaterial?.doubleSided = true
        
        //fix the ratio so that it works for all resizing - stageNode size vs gameFrame size
        player.position = SCNVector3(x: (presentationPlayer!.position.x - gameFrame.size.width/2) * 10/*myStageNode.geometry!.*/ / gameFrame.size.width , y: (presentationPlayer!.position.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: 0)
        
        myScene.rootNode.addChildNode(player)
        //myPlayerNode.hidden = true
        player.hidden = true
        //***************************
        //Dumbass temperary fix to draw calls
        // animate the 3d object ///
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(SCNVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(M_PI)*2))
        animation.duration = 3
        animation.repeatCount = MAXFLOAT //repeat forever
        player.addAnimation(animation, forKey: nil)
        //***************************
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
        myGameScene = GameScene(size: CGSize(width: 100, height: 100))
        gameScene = self.myGameScene
        let materialScene = myGameScene//SKScene(size: CGSize(width: 100, height: 100))
        //materialScene.size = CGSize(width: 100, height: 100)
        //        myGameSceneView.presentScene(myGameScene)
        //        materialScene.didMoveToView(myGameSceneView)
        //materialScene.yScale = CGFloat(-1)
        
        myTestTrap.geometry = SCNPlane(width: 10, height: 10)// SCNSphere(radius: 5)
        myTestTrap.position = SCNVector3(x: 0, y: 0, z: 0)
        //        myTestTrap.rotation = SCNVector4(x: 1, y: 0, z: 0, w: CGFloat(M_PI) )
        myTestTrap.rotation = SCNVector4(x: 1, y: 0, z: 0, w: 3 * CGFloat(M_PI)/4 )
        myTestTrap.geometry?.firstMaterial?.diffuse.contents = materialScene
        //myTestTrap.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeTranslation(5, 5, 1)
        //myTestTrap.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(2, 2, 2)
        myTestTrap.geometry?.firstMaterial?.doubleSided = true   //****** Fix sides
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
    
    func setupCamera(){
        // create and add a camera to the scene
        if myCameraNode == nil{
            myCamera = SCNCamera()
            myCamera.xFov = 40
            myCamera.yFov = 40
            myCameraNode = SCNNode()
            //myCameraNode.camera = myCamera
            // allows the user to manipulate the camera
            self.gameView!.allowsCameraControl = true
            myScene.rootNode.addChildNode(myCameraNode)
        }
        myCameraNode.camera = myCamera
        myCameraNode.position = SCNVector3(x: 0, y: 0, z: 20)//12)//CGFloat(levelHeight) + 12)
        
        //myCameraNode.orientation = SCNQuaternion(x: 0.1, y: 0, z: 0, w: CGFloat(M_PI))
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
        //self.myView.overlaySKScene.delegate
        
        
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
        //self.gameView.nextResponder = self//.view
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
