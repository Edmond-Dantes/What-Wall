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
    
    private let rad:CGFloat = 40 * gameFrame.height/1000
    var radius:CGFloat {
        get {
            return self.rad
        }
    }
    //let circleShape:SKShapeNode
    
    var lifeTimer: CFTimeInterval = 0
    
    var isAlive:Bool = true
    
    var isDying:Bool = false
    var justDied:Bool = false
    
    var hitCount:Int = 0
    var contactStatic:Bool = false
    var contactActive:Bool = false
    
    var deathPosition:CGPoint = CGPoint(x: 0, y: 0)
    var cornerHitPosition:CGPoint? = nil
    
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
        let initTexture:SKTexture? = SKTexture(imageNamed: "bluecircle")
        let initSize = CGSize(width: self.rad*2, height: self.rad*2)
        let initColor = Color.whiteColor()
        //self.circleShape = SKShapeNode(circleOfRadius: self.radius)
       
        super.init(texture: initTexture, color: initColor, size: initSize)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.radius)
        self.position = self.originalPosition
        //self.physicsBody?.mass = 0
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = 0
        
        self.physicsBody!.categoryBitMask = CollisionType.player.rawValue
        self.physicsBody!.collisionBitMask = CollisionType.activeWall.rawValue | CollisionType.staticWall.rawValue
        self.physicsBody!.contactTestBitMask = CollisionType.activeWall.rawValue | CollisionType.staticWall.rawValue

        self.physicsBody!.usesPreciseCollisionDetection = true
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func clone() -> Player{
        let clone = Player()
        clone.physicsBody = nil
        
        
        return clone
    }
    
    
    
    
    
    
    
    
    
}