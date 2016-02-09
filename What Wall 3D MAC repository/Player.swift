//
//  RolyPauly.swift
//  Roly Moly
//
//  Created by Future on 12/24/14.
//  Copyright (c) 2014 Future. All rights reserved.
//

//import Foundation
import SpriteKit

//let gameFrame:CGRect = CGRect(x: 0.0, y: 0.0, width: 1000.0, height: 1000.0)
//let cornerBlockFrame:CGRect = CGRect(x: 0.0, y: 0.0, width: 1000.0 / 10, height: 1000.0 / 10)

class Player: SKSpriteNode{
    
    private var rad:CGFloat = 40 * gameFrame.height/1000
    var radius:CGFloat {
        get {
            return self.rad
        }
        set {
            self.rad = newValue
        }
    }
    //let circleShape:SKShapeNode
    
    var timesTheWeight:CGFloat = 3
    
    var lifeTimer: CFTimeInterval = 0
    
    var isAlive:Bool = true
    
    var isDying:Bool = false
    var justDied:Bool = false
    
    var isStunned:Bool = false
    var hitCount:Int = 0
    var contactStatic:Bool = false
    var contactActive:Bool = false
    
    var deathPosition:CGPoint = CGPoint(x: 0, y: 0)
    var cornerHitPosition:CGPoint? = nil
    
    var deathVelocity:CGVector = CGVector(dx: 0, dy: 0)
    
    let originalPosition = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
    
    enum direction{
        case left, right, down, up
        
        /*   static var opposite:direction{
        switch hitDirection{
        case .left:
        return .right
        case .right:
        return .left
        case .up:
        return .down
        case .down:
        return .up
        }
        
        }*/
        
    }
    
    var hitDirection:SmashBlock.blockPosition? = nil
    
    /*override*/ init(){
        let initTexture:SKTexture? = nil//SKTexture(imageNamed: "bluecircle") //nil
        let initSize = CGSize()//CGSize(width: self.rad*2, height: self.rad*2) //CGSize()
        let initColor = Color.whiteColor()
        //self.circleShape = SKShapeNode(circleOfRadius: self.radius)
        
        super.init(texture: initTexture, color: initColor, size: initSize)
        
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.radius)
        self.position = self.originalPosition
        self.physicsBody?.mass = self.physicsBody!.mass * timesTheWeight//* 2
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = 0
        self.physicsBody!.linearDamping = 0//0.2//1
        self.physicsBody!.categoryBitMask = CollisionType.player.rawValue
        self.physicsBody!.collisionBitMask = CollisionType.activeWall.rawValue | CollisionType.staticWall.rawValue
        self.physicsBody!.contactTestBitMask = CollisionType.activeWall.rawValue | CollisionType.staticWall.rawValue
        
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.physicsBody!.fieldBitMask = CollisionType.player.rawValue
        
    }
    
    init(r:CGFloat){
        //self.radius = self.rad/2
        let initTexture:SKTexture? = nil//SKTexture(imageNamed: "bluecircle") //nil
        let initSize = CGSize()//CGSize(width: self.rad, height: self.rad) //CGSize()
        let initColor = Color.whiteColor()
        //self.circleShape = SKShapeNode(circleOfRadius: self.radius)
        
        super.init(texture: initTexture, color: initColor, size: initSize)
        //self.physicsBody = nil
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.radius/2)
        self.radius = self.radius/2
        self.physicsBody?.restitution = 0//0.01
        self.physicsBody?.friction = 0
        self.physicsBody!.linearDamping = 0//0.2//1
        self.physicsBody!.categoryBitMask = CollisionType.tail.rawValue//0x0
        self.physicsBody!.collisionBitMask = 0x0//CollisionType.staticWall.rawValue //0x0
        self.physicsBody!.contactTestBitMask = 0x0
        //clone.physicsBody!.usesPreciseCollisionDetection = false
        self.physicsBody!.mass = self.physicsBody!.mass / 85
        //self.physicsBody!.density = 0.01//self.physicsBody!.density / 2
        //clone.physicsBody!.density = 1
        //self.physicsBody!.affectedByGravity = true
        //self.physicsBody!.dynamic = false
        self.physicsBody!.fieldBitMask = CollisionType.tail.rawValue
        
        //self.physicsBody!.pinned = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func clone() -> Player{
        let clone = Player()
        clone.physicsBody = nil
        
        
        return clone
    }
    
    func clone(r:CGFloat) -> Player{
        let clone = Player(r: r)
        clone.physicsBody = nil
        
        return clone
    }
    
    
    
    
    
    
    
    
}