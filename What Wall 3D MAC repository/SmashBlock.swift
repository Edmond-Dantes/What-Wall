//
//  SmashJointVolumeBlock.swift
//  Roly Moly
//
//  Created by Future on 11/30/14.
//  Copyright (c) 2014 Future. All rights reserved.
//

import Foundation
import SpriteKit

/* contained in Maze.swift
extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}
*/
let gameFrame:CGRect = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
//let gameFrame:CGRect = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
let cornerBlockFrame:CGRect = CGRect(x: 0.0, y: 0.0, width: gameFrame.width / 10, height: gameFrame.height / 10)

class SmashBlock: SKSpriteNode {
    
    
    enum activity:Int {
        
        case waiting = 0 , smashing, returning
        
    }
    
  
    
    enum blockPosition:String {//, SequenceType{
        case leftTop = "leftTop", leftBottom = "leftBottom", rightTop = "rightTop", rightBottom = "rightBottom"
        case topLeft = "topLeft", topRight = "topRight", bottomLeft = "bottomLeft", bottomRight = "bottomRight"
        
        //static let array = [blockPosition.leftTop, .leftBottom, .rightTop, .rightBottom, .topLeft, .topRight, .bottomLeft, .bottomRight]
        
        func opposite() -> blockPosition{
                switch self{
                case .leftTop:
                    return .rightTop
                case .rightTop:
                    return .leftTop
                case  .leftBottom:
                    return .rightBottom
                case .rightBottom:
                    return .leftBottom
                case .topLeft:
                    return .bottomLeft
                case .bottomLeft:
                    return .topLeft
                case .topRight:
                    return .bottomRight
                case .bottomRight:
                    return .topRight
                default:
                    break
                }
            
        }
        
        func adjacent() -> blockPosition{
            switch self{
            case .leftTop:
                return .leftBottom
            case .rightTop:
                return .rightBottom
            case  .leftBottom:
                return .leftTop
            case .rightBottom:
                return .rightTop
            case .topLeft:
                return .topRight
            case .bottomLeft:
                return .bottomRight
            case .topRight:
                return .topLeft
            case .bottomRight:
                return .bottomLeft
            default:
                break
            }
            
        }
        
        func perpendicularArray()-> [blockPosition]{
            switch self{
            case .leftTop:
                return [.topLeft, .topRight, .bottomLeft, .bottomRight]
            case .rightTop:
                return [.topLeft, .topRight, .bottomLeft, .bottomRight]
            case  .leftBottom:
                return [.topLeft, .topRight, .bottomLeft, .bottomRight]
            case .rightBottom:
                return [.topLeft, .topRight, .bottomLeft, .bottomRight]
            case .topLeft:
                return [.leftBottom, .leftTop, .rightBottom, .rightTop]
            case .bottomLeft:
                return [.leftBottom, .leftTop, .rightBottom, .rightTop]
            case .topRight:
                return [.leftBottom, .leftTop, .rightBottom, .rightTop]
            case .bottomRight:
                return [.leftBottom, .leftTop, .rightBottom, .rightTop]
            }
        }
    }
    
    
    
    





    class var array:[SmashBlock.blockPosition] {
        return [SmashBlock.blockPosition.leftTop, .leftBottom, .rightTop, .rightBottom, .topLeft, .topRight, .bottomLeft, .bottomRight]
    }
    
    class func levelExitArray( level:Int ) ->[blockPosition] {
        
        var tempArray:[blockPosition] = []
        
        
        for index in 0...level - 1 {
            
            if index == 0 {
                tempArray.append(self.randomBlockPosition())
            }else{
                var tempPosition = self.randomBlockPosition()
                while tempPosition == tempArray[index - 1].opposite() || tempPosition == tempArray[index - 1].opposite().adjacent(){
                
                    tempPosition = self.randomBlockPosition()
                    
                }
                tempArray.append(tempPosition)
            }
            
        }
        
        return tempArray
    }
    
    class func random8array() ->[blockPosition] {
        var tempArray = self.array
        tempArray.shuffle()
        return tempArray
    }
    
    class func randomBlockPosition()->blockPosition{
        let tempArray = self.array
        //srandom(UInt32(CFAbsoluteTimeGetCurrent()))
        return tempArray[ Int(arc4random_uniform(8)) ]
    }
    
    class func entranceSpeed(wall:blockPosition) -> CGVector{
        let speed: CGFloat = 1000 * SPEED_PERCENTAGE
        
        switch wall{
        case .leftBottom, .leftTop:
            return CGVector(dx: speed, dy: 0)
        case .rightBottom, .rightTop:
            return CGVector(dx: -speed, dy: 0)
        case .topLeft, .topRight:
            return CGVector(dx: 0, dy: -speed)
        case .bottomLeft, .bottomRight:
            return CGVector(dx: 0, dy: speed)
        default:
            break
        }
        
        
    }
    
    var slidingJoint = SKPhysicsJointSliding()
    var orginalPosition = CGPoint(x: 0.0, y: 0.0)
    let smashBlockPosition: blockPosition
    
    
    //---------------------
    //smashing block objects
    init(blockPos:blockPosition, color: SKColor){
        
        
        
        let initColor = color//Color.yellowColor()
        let initSize = CGSize(width: 0, height: 0)
        var blockCenter:CGPoint = CGPoint()
        var attachToCornerBlock:CornerBlock.cornerPosition
        attachToCornerBlock = .leftTop
        
        self.smashBlockPosition = blockPos
        
        super.init(texture: nil, color: initColor, size: initSize)
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let pixelBuffer:CGFloat = 2
        
        let horizontalSize = CGSize(width: gameFrame.width - cornerBlockFrame.width - pixelBuffer/2, height: gameFrame.height/2 - cornerBlockFrame.height - pixelBuffer)
        let verticalSize = CGSize(width: gameFrame.width/2 - cornerBlockFrame.width - pixelBuffer, height: gameFrame.height - cornerBlockFrame.height - pixelBuffer/2)
        var axis = CGVector(dx: 0, dy: 0)
        //self.texture = SKTexture(imageNamed: "skeletonarm")
        self.colorBlendFactor = 0.5
        
        switch blockPos {
            
        case .leftTop:
            
            self.size = horizontalSize
            self.position = CGPoint(x: cornerBlockFrame.width - self.size.width/2,
                y: gameFrame.height/2 + pixelBuffer/2 + self.size.height/2)
            self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)//, center: self.position)
            //self.anchorPoint = CGPoint(x: 1, y: 0)
            //println(self.position)
            blockCenter = CGPoint(x: self.position.x - self.size.width/2, y: self.position.y + self.size.height/2)
            attachToCornerBlock = .leftTop
            axis = CGVector(dx: 1, dy: 0)
            
        case .leftBottom:
            
            self.size = horizontalSize
            self.position = CGPoint(x: cornerBlockFrame.width - self.size.width/2,
                y: gameFrame.height/2 - pixelBuffer/2 - self.size.height/2)
            self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)//, center: self.position)
            //self.anchorPoint = CGPoint(x: 1, y: 1)
            //println(self.position)
            blockCenter = CGPoint(x: self.size.width/2, y: self.size.height/2)
            attachToCornerBlock = .leftBottom
            axis = CGVector(dx: 1, dy: 0)
            
        case .rightTop:
            
            self.size = horizontalSize
            self.position = CGPoint(x: gameFrame.width - cornerBlockFrame.width + self.size.width/2,
                y: gameFrame.height/2 + pixelBuffer/2 + self.size.height/2)
            self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)//, center: self.position)
            //self.anchorPoint = CGPoint(x: 0, y: 0)
            //println(self.position)
            blockCenter = CGPoint(x: self.position.x + self.size.width/2, y: self.position.y + self.size.height/2)
            attachToCornerBlock = .rightTop
            axis = CGVector(dx: -1, dy: 0)
            
            
        case .rightBottom:
            
            self.size = horizontalSize
            self.position = CGPoint(x: gameFrame.width - cornerBlockFrame.width + self.size.width/2,
                y: gameFrame.height/2 - pixelBuffer/2 - self.size.height/2)
            self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)//, center: self.position)
            //self.anchorPoint = CGPoint(x: 0, y: 1)
            //println(self.position)
            blockCenter = CGPoint(x: self.position.x + self.size.width/2, y: self.position.y - self.size.height/2)
            attachToCornerBlock = .rightBottom
            axis = CGVector(dx: -1, dy: 0)
            
        case .topLeft:
            
            self.size = verticalSize
            self.position = CGPoint(x: gameFrame.width/2 - pixelBuffer/2 - self.size.width/2,
                y: gameFrame.height - cornerBlockFrame.height + self.size.height/2)
            self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)//, center: self.position)
            //self.anchorPoint = CGPoint(x: 1, y: 0)
            //println(self.position)
            blockCenter = CGPoint(x: self.position.x - self.size.width/2, y: self.position.y + self.size.height/2)
            attachToCornerBlock = .leftTop
            axis = CGVector(dx: 0, dy: -1)
            
        case .topRight:
            
            self.size = verticalSize
            self.position = CGPoint(x: gameFrame.width/2 + pixelBuffer/2 + self.size.width/2,
                y: gameFrame.height - cornerBlockFrame.height + self.size.height/2)
            self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)//, center: self.position)
            //self.anchorPoint = CGPoint(x: 0, y: 0)
            //println(self.position)
            blockCenter = CGPoint(x: self.position.x + self.size.width/2, y: self.position.y + self.size.height/2)
            attachToCornerBlock = .rightTop
            axis = CGVector(dx: 0, dy: -1)
            
        case .bottomLeft:
            
            self.size = verticalSize
            self.position = CGPoint(x: gameFrame.width/2 - pixelBuffer/2 - self.size.width/2,
                y: cornerBlockFrame.height - self.size.height/2)
            self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)//, center: self.position)
            //self.anchorPoint = CGPoint(x: 1, y: 1)
            //println(self.position)
            blockCenter = CGPoint(x: self.position.x - self.size.width/2, y: self.position.y - self.size.height/2)
            attachToCornerBlock = .leftBottom
            axis = CGVector(dx: 0, dy: 1)
            
        case .bottomRight:
            
            self.size = verticalSize
            self.position = CGPoint(x: gameFrame.width/2 + pixelBuffer/2 + self.size.width/2,
                y: cornerBlockFrame.height - self.size.height/2)
            self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)//, center: self.position)
            //self.anchorPoint = CGPoint(x: 0, y: 1)
            //println(self.position)
            blockCenter = CGPoint(x: self.position.x + self.size.width/2, y: self.position.y - self.size.height/2)
            attachToCornerBlock = .rightBottom
            axis = CGVector(dx: 0, dy: 1)
            
            
        }
        
        print(blockCenter)
        
        self.orginalPosition = self.position
        //self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
       // self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)//, center: blockCenter)
        //self.physicsBody!.mass = 1
        self.physicsBody!.restitution = 0
        //self.physicsBody.
        self.physicsBody!.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
       
        self.physicsBody!.categoryBitMask = CollisionType.staticWall.rawValue
        self.physicsBody!.collisionBitMask = CollisionType.player.rawValue
        self.physicsBody!.contactTestBitMask = CollisionType.player.rawValue
        self.physicsBody!.fieldBitMask = CollisionType.staticWall.rawValue
        
        //if (blockPos == .leftTop || blockPos == .leftBottom) {
            self.physicsBody!.dynamic = false
       // }
        
        
        //???
        slidingJoint = SKPhysicsJointSliding.jointWithBodyA(self.physicsBody!,
            bodyB: (myCorners[attachToCornerBlock]?.physicsBody)!,
            anchor: self.position,
            axis: axis)
    
       // slidingJoint.shouldEnableLimits = true
       // slidingJoint.upperDistanceLimit = gameFrame.height //- 2 * cornerBlockFrame.height - pixelBuffer
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func clone() -> SmashBlock{
        let clone = SmashBlock(blockPos: self.smashBlockPosition, color: self.color as SKColor)
        clone.physicsBody = nil
        
        
        return clone
    }
    
    
}