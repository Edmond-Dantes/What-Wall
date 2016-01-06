//
//  CornerEdgeBlock.swift
//  Roly Moly
//
//  Created by Future on 11/27/14.
//  Copyright (c) 2014 Future. All rights reserved.
//

import Foundation
import SpriteKit






//private let gameFrame:CGRect = CGRect(x: 0, y: 0, width: 1000, height: 1000)


class CornerBlock: SKSpriteNode{
    
    enum cornerPosition: Int{
        case leftTop = 0, leftBottom, rightTop, rightBottom
    }
    
    private let pixelBuffer: CGFloat = 2
    var originalPosition = CGPoint()
    let cornerPositionValue: cornerPosition
  
    init(cornerPos: cornerPosition, color: SKColor){
        //color:SKColor = UIColor.blueColor()
        
        let initColor = color
        //let gameFrame = CGRect(x: 0, y: 0, width: 1000, height: 1000)
        
        let width = gameFrame.width / 10 - pixelBuffer/2
        let height = gameFrame.height / 10 - pixelBuffer/2
        let initSize = CGSize(width: width, height: height)
        
        self.cornerPositionValue = cornerPos
        
        super.init(texture: nil, color: initColor, size: initSize)
        
        
        switch cornerPos {
        case .leftTop:
            self.anchorPoint = CGPoint(x: 0,
                y: 1)
            self.position = CGPoint(x: 0,
                y: gameFrame.height)
        case .leftBottom:
            self.anchorPoint = CGPoint(x: 0,
                y: 0)
            self.position = CGPoint(x: 0,
                y: 0)
        case .rightTop:
            self.anchorPoint = CGPoint(x: 1,
                y: 1)
            self.position = CGPoint(x: gameFrame.width,
                y: gameFrame.height)
        case .rightBottom:
            self.anchorPoint = CGPoint(x: 1,
                y: 0)
            self.position = CGPoint(x: gameFrame.width,
                y: 0)
        }
        
        self.originalPosition = self.position
        
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0, width: width, height: height))
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    

    func clone() -> CornerBlock{
        let clone = CornerBlock(cornerPos: self.cornerPositionValue, color: self.color as SKColor)
        clone.physicsBody = nil
        
        
        return clone
    }

   
    
    //---------------------
    
    
    

    
    
    
}