//
//  Maze.swift
//  Roly Moly
//
//  Created by Future on 1/26/15.
//  Copyright (c) 2015 Future. All rights reserved.
//

import Foundation
import SpriteKit


extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            if j != i{
                swap(&self[i], &self[j])
            }
        }
    }
}


class Maze: SKNode {
    
    var level: Int = 0
    
   // var MAX_DEADENDS = 10
    
    var MAZE_ROWS:Int {
        get{
            return (self.level) + 3
            //return (3 + MAX_DEADENDS/2) * 2 + 1
        }
    }
    var MAZE_COLUMNS:Int {
        get{
            return MAZE_ROWS//(3 + MAX_DEADENDS/2) * 2 + 1
        }
    }
    var myRandomOrderedMazeDirections:[MazeCell.wallLocations] = [ .up, .down, .left, .right ]
    var myMazeCellSize:CGSize = CGSize()
    
    
    var mazeNumberMatrix:[Int] = []
    var mazeCellMatrix:[MazeCell] = []
    var escapePath:[Int] = []
    var currentPath:[Int] = []
    var levelExitArray:[SmashBlock.blockPosition] = []
    
    var visitedCellCount:Int = 0
    var maxPathCount = 0
    var startPoint = 0
    var exitPoint = 0
    var currentPoint = 0
    var deadEndCount = 0
    //let MAX_DEADENDS = 2
    //  func loadMaze(){
    //      self.addChild(myEffectNodeGridResult)
    //  }
    
    override init(){
        super.init()
    }
    init(level:CGFloat){//mazeScene:MazeScene){
        
        super.init()
        
        print("START")
        self.level = Int(level)
        
        //self.removeAllChildren()
        //myMazeGrid = []
        self.mazeNumberMatrix = []
        
        self.myMazeCellSize.width = (gameFrame.width - 2 * cornerBlockFrame.width) / CGFloat(MAZE_COLUMNS)
        //CGFloat((MAZE_ROWS - 1)/2 + 2)
        self.myMazeCellSize.height = (gameFrame.height - 2 * cornerBlockFrame.height) / CGFloat(MAZE_ROWS)        //CGFloat((MAZE_COLUMNS - 1)/2 + 2 )
        
        
        //------------------------
        //Loading all of the cells
        
        for var row = 0; row < MAZE_ROWS; ++row{
            for var column = 0; column < MAZE_COLUMNS; ++column{
                
                //println(" \(row) , \(column)")
                let gridPoint = column + row * MAZE_COLUMNS
                self.mazeNumberMatrix.insert(0, atIndex: gridPoint)
                
            }
        }
        print("START")
        
        
        findAppropiateMaze()
        
        print("START")
        //self.mazeNumberMatrix = mySimpleMazeCalculator
        //loadEscapePath()
        loadRealMaze(level)
        levelPathColored()
        loadEscapePath()
        
    }
    
    func loadEscapePath(){
        //allow only one path
        for var currentStage = 0; currentStage < escapePath.count - 1; ++currentStage{
            let nextPathPoint = escapePath[currentStage + 1]
            let pathPoint = escapePath[currentStage]
            self.levelExitArray.append(SmashBlock.blockPosition.rightTop)
            if nextPathPoint == pathPoint + 1{
                if Int(arc4random_uniform(UInt32(2))) % 2 == 0{
                    self.levelExitArray[currentStage] = .rightTop
                }else{
                    self.levelExitArray[currentStage] = .rightBottom
                }
                
            }else if nextPathPoint == pathPoint - 1{
                if Int(arc4random_uniform(UInt32(2))) % 2 == 0{
                    self.levelExitArray[currentStage] = .leftTop
                }else{
                    self.levelExitArray[currentStage] = .leftBottom
                }
                //self.levelExitArray[currentStage] = .leftTop
            }else if nextPathPoint == pathPoint + MAZE_ROWS{
                if Int(arc4random_uniform(UInt32(2))) % 2 == 0{
                    self.levelExitArray[currentStage] = .topRight
                }else{
                    self.levelExitArray[currentStage] = .topLeft
                }
                //self.levelExitArray[currentStage] = .topRight
            }else if nextPathPoint == pathPoint - MAZE_ROWS{
                if Int(arc4random_uniform(UInt32(2))) % 2 == 0{
                    self.levelExitArray[currentStage] = .bottomRight
                }else{
                    self.levelExitArray[currentStage] = .bottomLeft
                }
                //self.levelExitArray[currentStage] = .bottomRight
            }else{
                
            }
        }
    }
    
    func levelPathColored(){
    
        for var i = 1; i < escapePath.count - 1; ++i{
            let cell = self.mazeCellMatrix[escapePath[i]]
            cell.color = NSColor(calibratedRed: CGFloat(i)/CGFloat(escapePath.count - 1), green: CGFloat(0), blue: CGFloat((escapePath.count - 1)-i)/CGFloat(escapePath.count - 1), alpha: CGFloat(1))
            
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func findAppropiateMaze(){
        var row = 0
        var column = 0
        
        
        repeat{
            
            for row = 0; row < MAZE_ROWS; ++row{
                for column = 0; column < MAZE_COLUMNS; ++column{
                    
                    let gridPoint = column + row * MAZE_COLUMNS
                    self.mazeNumberMatrix[gridPoint] = 0
                    //mySimpleMazeCalculator[gridPoint] = 0
                    
                }
            }
            
            visitedCellCount = 0
            maxPathCount = 0
            exitPoint = 0
            deadEndCount = 0
            self.escapePath = []
            self.currentPath = []
            print("start randomMazeGrid")
            (column, row) = randomMazeGridPosition()
            print("start generateMazeRecursion")
            generateMazeRecursion(column: column, row: row)
            self.mazeNumberMatrix[exitPoint] = 4  //exit point
            print("finish generateMazeRecursion")
            print("path count = \(self.escapePath.count)")
        }while self.escapePath.count <= (MAZE_ROWS - 3) * 2 + 1// maxPathCount > MAZE_ROWS//self.level + 1//deadEndCount != MAX_DEADENDS
        
        //allow only one path
        for pathPoint in escapePath{
            if self.mazeNumberMatrix[pathPoint] == 1 || self.mazeNumberMatrix[pathPoint] == 8{
                self.mazeNumberMatrix[pathPoint] = 5
            }
            
        }
        /*
        //surrounding barriers
        for pathPoint in escapePath{
            if self.mazeNumberMatrix[pathPoint + 1] != 5 && self.mazeNumberMatrix[pathPoint + 1] != 4 && self.mazeNumberMatrix[pathPoint + 1] != 2{
                self.mazeNumberMatrix[pathPoint + 1] = 9
            }
            if self.mazeNumberMatrix[pathPoint - 1] != 5 && self.mazeNumberMatrix[pathPoint - 1] != 4 && self.mazeNumberMatrix[pathPoint - 1] != 2{
                self.mazeNumberMatrix[pathPoint - 1] = 9
            }
            if self.mazeNumberMatrix[pathPoint + MAZE_ROWS] != 5 && self.mazeNumberMatrix[pathPoint + MAZE_ROWS] != 4 && self.mazeNumberMatrix[pathPoint + MAZE_ROWS] != 2{
                self.mazeNumberMatrix[pathPoint + MAZE_ROWS] = 9
            }
            if self.mazeNumberMatrix[pathPoint - MAZE_ROWS] != 5 && self.mazeNumberMatrix[pathPoint - MAZE_ROWS] != 4 && self.mazeNumberMatrix[pathPoint - MAZE_ROWS] != 2{
                self.mazeNumberMatrix[pathPoint - MAZE_ROWS] = 9
            }
        }
        */
        //remove barriers from the holes  ************FIX THIS!!!!*****************
        
        for row = 0; row < MAZE_ROWS; ++row{
            for column = 0; column < MAZE_COLUMNS; ++column{
                let gridPoint = column + row * MAZE_COLUMNS
                if self.mazeNumberMatrix[gridPoint] == 3 || self.mazeNumberMatrix[gridPoint] == 1 || self.mazeNumberMatrix[gridPoint] == 7 { //if hole (or inbetween point) remove barriers around it
                    let barrierToHole = 6
                    if column - 1 > 0 && self.mazeNumberMatrix[(column - 1 ) + (row ) * MAZE_COLUMNS] == 0{
                        self.mazeNumberMatrix[(column - 1 ) + (row ) * MAZE_COLUMNS] = barrierToHole
                    }
                    if column + 1 < MAZE_COLUMNS - 1 && self.mazeNumberMatrix[(column + 1 ) + (row ) * MAZE_COLUMNS] == 0{
                        self.mazeNumberMatrix[(column + 1 ) + (row ) * MAZE_COLUMNS] = barrierToHole
                    }
                    if row - 1 > 0 && self.mazeNumberMatrix[(column ) + (row - 1 ) * MAZE_COLUMNS] == 0{
                        self.mazeNumberMatrix[(column ) + (row - 1 ) * MAZE_COLUMNS] = barrierToHole
                    }
                    if row + 1 < MAZE_ROWS - 1 && self.mazeNumberMatrix[(column ) + (row + 1 ) * MAZE_COLUMNS] == 0{
                        self.mazeNumberMatrix[(column ) + (row + 1 ) * MAZE_COLUMNS] = barrierToHole
                    }
                    
                    
                    
                    
                }
                
                
            }
        }
        
        
    }
    
    func loadRealMaze(level:CGFloat){
        
        for var row = 0; row < MAZE_ROWS; ++row{
            for var column = 0; column < MAZE_COLUMNS; ++column{
                
                let gridPoint = column + row * MAZE_COLUMNS
                
                let cellType = self.mazeNumberMatrix[gridPoint] //mySimpleMazeCalculator[gridPoint]
                //let cell = myMazeGrid[gridPoint]
                //var colCalcX = myMazeCellSize.width/2 + CGFloat((column - 1)/2 + 1) * myMazeCellSize.width
                //var rowCalcY = myMazeCellSize.height/2 + CGFloat((row - 1)/2 + 1) * myMazeCellSize.height
                let colCalcX = myMazeCellSize.width/2 + CGFloat((column - 1) + 1) * myMazeCellSize.width
                let rowCalcY = myMazeCellSize.height/2 + CGFloat((row - 1) + 1) * myMazeCellSize.height
                var sizeCalc = myMazeCellSize
                
                
                if column % 2 == 0 {
                    if cellType == 8{//barrier
                        sizeCalc.width = 1
                    }else{
                        sizeCalc.height = 1
                    }
                   // //sizeCalc.height = 1
                    //sizeCalc.width = 1
                    //colCalcX = CGFloat(column/2 + 1) * myMazeCellSize.width
                    
                }
                if row % 2 == 0 {
                    if cellType == 8{//barrier
                        sizeCalc.height = 1
                    }else{
                        sizeCalc.width = 1
                    }
                   // //sizeCalc.width = 1
                    //sizeCalc.height = 1
                    //rowCalcY = CGFloat(row/2 + 1) * myMazeCellSize.height
                }

                let cell = MazeCell(cellType: MazeCell.positionType.center, gridPoint: gridPoint, cellSize: sizeCalc)
                cell.position = CGPoint(x: colCalcX, y: rowCalcY)
                
                
                cell.zPosition = level * 2
                
                self.mazeCellMatrix.insert(cell, atIndex: gridPoint)
                
                
                
                switch cellType{
                case 1:  // visited
                    var tempLevel:Int = Int(level) % 10
                    //cell.color = Color.colorArray[tempLevel]
                    cell.color = Color.clearColor()//Color.grayColor()
                    cell.visited = true
                    cell.alpha = 0.1
                case 2:  // start point
                    cell.color = Color.blueColor()
                    cell.visited = true
                    self.startPoint = gridPoint
                    self.currentPoint = self.startPoint
                
                case 3:  // deadends
                    cell.color = Color.clearColor()//Color.orangeColor()//Color.yellowColor()
                    cell.visited = true
                    
                case 4:  // exit point
                    cell.color = Color.redColor()
                    cell.visited = true
                    
                case 5: //escape path
                    cell.visited = true
                    cell.alpha = 1
                    //cell.color = NSColor(calibratedRed: CGFloat(0.5), green: CGFloat(0), blue: CGFloat(0.5), alpha: CGFloat(1))
                    /*for var i = 0; i < escapePath.count; ++i{
                        if escapePath[i] == gridPoint{
                            cell.color = NSColor(calibratedRed: CGFloat(i)/CGFloat(escapePath.count - 1), green: CGFloat(0), blue: CGFloat((escapePath.count - 1)-i)/CGFloat(escapePath.count - 1), alpha: CGFloat(1))
                        continue
                        }
                    }*/

                   // var tempLevel:Int = Int(level) % 10
                    //cell.color = Color.colorArray[tempLevel]
                    //cell.color = Color.whiteColor()
                    //cell.visited = true
                    //cell.alpha = 0.5
                
                case 6: //coverted to holes
                    cell.color = Color.clearColor()//Color.greenColor()
                    cell.visited = true
                case 7://inbetween path points
                    cell.color = Color.clearColor()//Color.whiteColor()
                    cell.visited = true
                case 8: // barriers
                    cell.color = Color.yellowColor()
                case 9: //surrounding barriers
                    cell.color = Color.yellowColor()
                default: // barriers = 0
                    cell.color = Color.clearColor()//Color.yellowColor()
                    /*var tempLevel:Int = Int(level) % 10
                    cell.color = Color.colorArray[tempLevel]
                    //cell.color = Color.whiteColor()
                    cell.visited = false
                    cell.alpha = 0.9//0.1
                    */
                    
                    
                    
                    
                }
                
                if row % 2 == 0 && column % 2 == 0{
                 cell.color = Color.clearColor()
                }
                
                self.addChild(cell)
                
                //myEffectNodeGridResult[gridPoint].addChild(cell)
                
            }
        }
        
        print("MAZE = \(MAZE_COLUMNS) X \(MAZE_ROWS)")
    }
    
    func randomMazeGridPosition()->(Int,Int){
        
        //insert random starting point logic
        
        var row = 0
        var column = 0
        
        while row % 2 == 0{
            row = Int(arc4random_uniform(UInt32(MAZE_ROWS)))
        }
        while column % 2 == 0{
            column = Int(arc4random_uniform(UInt32(MAZE_COLUMNS)))
        }
        
        
        //row = 3
        //column = 3
        //println(" \(column), \(row) ")
        
        
        return (column, row)
        
    }
    
    func randomDirections()->[MazeCell.wallLocations]{
        
        //add logic
        myRandomOrderedMazeDirections.shuffle()
        return myRandomOrderedMazeDirections
        
    }
    
    func generateMazeRecursion(column column:Int, row:Int){
        
        /*if deadEndCount > MAX_DEADENDS{
        return
        }
        */
        if escapePath.count >= (MAZE_ROWS - 3) * 2 + 1{//MAZE_ROWS - 2{
            return
        }
        
        ++visitedCellCount
        
        //-----Keep track of currectPath
        self.currentPath.append(column + row * MAZE_COLUMNS)
        
        
        self.mazeNumberMatrix[column + (row) * MAZE_COLUMNS] = 1 //visited general
        
        if self.visitedCellCount == 1{
            self.mazeNumberMatrix[column + (row) * MAZE_COLUMNS] = 2 //start and visited
            //myMazeGrid[column + row * MAZE_COLUMNS].color = UIColor.greenColor()
        }
        
        let currentPoint = column + row * MAZE_COLUMNS
        //myRandomOrderedMazeDirections.shuffle()
        //let cellWalls = myRandomOrderedMazeDirections
        let cellWalls = randomDirections()
        var deadEnd = true
        for direction in cellWalls{
            
            switch direction{
            case .up:
                if row - 2 <= 0{
                    continue
                }
                if self.mazeNumberMatrix[column + (row - 2) * MAZE_COLUMNS] == 0 {
                    deadEnd = false
                    self.mazeNumberMatrix[column + (row - 1) * MAZE_COLUMNS] = 7
                    //myMazeGrid[column + (row - 1) * MAZE_COLUMNS].color = UIColor.redColor()
                    self.currentPath.append((column ) + (row - 1) * MAZE_COLUMNS)
                    generateMazeRecursion(column: column, row: row - 2)
                    self.currentPath.removeLast()
                    
                }else{
                    self.mazeNumberMatrix[column + (row - 1) * MAZE_COLUMNS] = 8
                }
                
            case .right:
                if column + 2 >= MAZE_COLUMNS - 1{
                    continue
                }
                if self.mazeNumberMatrix[(column + 2) + row  * MAZE_COLUMNS] == 0 {
                    deadEnd = false
                    self.mazeNumberMatrix[(column + 1) + row * MAZE_COLUMNS] = 7
                    //myMazeGrid[(column + 1) + row * MAZE_COLUMNS].color = UIColor.redColor()
                    self.currentPath.append((column + 1 ) + (row ) * MAZE_COLUMNS)
                    generateMazeRecursion(column: column + 2, row: row )
                    self.currentPath.removeLast()
                    
                }else{
                    self.mazeNumberMatrix[(column + 1) + row * MAZE_COLUMNS] = 8
                }
            case .down:
                if row + 2 >= MAZE_ROWS - 1{
                    continue
                }
                if self.mazeNumberMatrix[column + (row + 2) * MAZE_COLUMNS] == 0 {
                    deadEnd = false
                    self.mazeNumberMatrix[column + (row + 1) * MAZE_COLUMNS] = 7
                    //myMazeGrid[column + (row + 1) * MAZE_COLUMNS].color = UIColor.redColor()
                    
                    self.currentPath.append((column ) + (row + 1) * MAZE_COLUMNS)
                    generateMazeRecursion(column: column, row: row + 2)
                    self.currentPath.removeLast()
                    
                }else{
                    self.mazeNumberMatrix[column + (row + 1) * MAZE_COLUMNS] = 8
                }
                
            case .left:
                if column - 2 <= 0{
                    continue
                }
                if self.mazeNumberMatrix[(column - 2) + row  * MAZE_COLUMNS] == 0 {
                    deadEnd = false
                    self.mazeNumberMatrix[(column - 1) + row * MAZE_COLUMNS] = 7
                    //myMazeGrid[(column - 1) + row * MAZE_COLUMNS].color = UIColor.redColor()
                    
                    self.currentPath.append((column - 1) + row * MAZE_COLUMNS)
                    generateMazeRecursion(column: column - 2, row: row )
                    self.currentPath.removeLast()
                }else{
                    self.mazeNumberMatrix[(column - 1) + row * MAZE_COLUMNS] = 8
                }
                
            }
            
        }
        if deadEnd{
            //            println("deadend path count = \(visitedCellCount) deadends = \(++deadEndCount)")
            ++deadEndCount
            self.mazeNumberMatrix[column + row * MAZE_COLUMNS] = 3 //deadend cell and visited
            //myMazeGrid[column + row * MAZE_COLUMNS].color = UIColor.yellowColor()
            if maxPathCount < visitedCellCount{
                maxPathCount = visitedCellCount
                
                //---record longest path
                self.escapePath = self.currentPath
                
                exitPoint = column + row * MAZE_COLUMNS
            }
        }
        --visitedCellCount
        //Pop currentPath when changing to new path
        self.currentPath.removeLast()
        
        //myMazeGrid[column + row * MAZE_COLUMNS].color = UIColor.yellowColor()
    }
    
    
    
    
}