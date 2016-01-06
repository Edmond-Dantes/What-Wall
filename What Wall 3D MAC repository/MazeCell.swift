//
//  MazeCell.swift
//  Roly Moly
//
//  Created by Future on 1/20/15.
//  Copyright (c) 2015 Future. All rights reserved.
//

//import Foundation
import SpriteKit


class MazeCell:SKSpriteNode {
    
    enum positionType{
        case topLeftCorner, topRightCorner, bottomLeftCorner, bottomRightCorner
        case leftEgde, rightEdge, topEdge, bottomEdge
        case center
    }
    
    enum wallLocations{
        case up, down, left, right
    }
    
    //    var path:
    var cellPosition:positionType
    var walls:[wallLocations:Bool] = [ .up: false, .down: false, .left: false, .right: false ]
    var gridPoint:Int
    var visited:Bool = false
    
    init(cellType:positionType, gridPoint:Int, cellSize: CGSize){
        
        self.cellPosition = cellType
        self.gridPoint = gridPoint
        super.init(texture: nil, color: Color.blackColor(), size: cellSize)
        
        
        
        
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}