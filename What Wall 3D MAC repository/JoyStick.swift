//
//  JoyStick.swift
//  Roly Moly
//
//  Created by Future on 1/29/15.
//  Copyright (c) 2015 Future. All rights reserved.
//

import Foundation
import SpriteKit
import Quartz




class JoyStick{
    
    private let MATH_PI:CGFloat = CGFloat(M_PI)
    
/*#if os(iOS)
    let joyStickView = UIView()
    let joyStick = UIImageView(image: UIImage(named: "bluecircle"))
#elseif os(OSX)
*/
    let joyStickView = SKSpriteNode()
    let joyStick = SKSpriteNode(imageNamed: "bluecircle")
    
//#endif
    var touchLocation:CGPoint? = nil
    var isChangedDirection: Bool = false
    
    enum direction{
        case left, upLeft, up, upRight, right, downRight, down, downLeft, neutral
    }
    
    /*enum key{
        case left, up, right, down
        
        static var isPressed: Bool = false
    }
    */
    var joyStickDirection:direction = .neutral
    
    func loadJoystick(sceneView sceneView: SKView) {
        //Load view for Joystick play
        //origin: CGPoint(x: sceneView.bounds.width/2 - height/2, y: sceneView.bounds.height - height)
        
        let height = (sceneView.bounds.height - sceneView.bounds.width)/2
        joyStickView.size = CGSize(width: height, height: height)
        joyStickView.color = Color.orangeColor()
        joyStickView.position = CGPoint(x: sceneView.bounds.width/2 - height/2, y: sceneView.bounds.height - height)
        sceneView.scene!.addChild(joyStickView)
        joyStick.size = CGSize(width: joyStickView.frame.width/3, height: joyStickView.frame.height/3)
        joyStick.position = CGPoint(x: joyStickView.frame.width/2, y: joyStickView.frame.height/2)
        joyStickView.addChild(joyStick)
        
        
    }
    func controllDirections() -> CGVector{
        var dx = 0
        var dy = 0
        switch joyStickDirection{
        
        case .neutral:
            dx = 0
            dy = 0
        case .right:
            dx = 1
            dy = 0
            
        case .left:
            dx = -1
            dy = 0
            
        case .up:
            dx = 0
            dy = 1
        case .down:
            dx = 0
            dy = -1
        default:
        dx = 0
        dy = 0
        
        }
        
        return CGVector(dx: dx, dy: dy)
    }
    
    func adjustJoyStick(){
        
        switch joyStickDirection{
        case .neutral:
            joyStick.position = CGPoint(x: joyStickView.frame.width/2, y: joyStickView.frame.height/2)
            
        case .upRight:
            joyStick.position = CGPoint(x: joyStickView.frame.width, y: 0)
        
        case .downRight:
            joyStick.position = CGPoint(x: joyStickView.frame.width, y: joyStickView.frame.height)
            
        case .right:
            joyStick.position = CGPoint(x: joyStickView.frame.width, y: joyStickView.frame.height/2)
            
        case .left:
            joyStick.position = CGPoint(x: 0, y: joyStickView.frame.height/2)
            
        case .upLeft:
            joyStick.position = CGPoint(x: 0, y: 0)
            
        case .downLeft:
            joyStick.position = CGPoint(x: 0, y: joyStickView.frame.height)
            
        case .up:
            joyStick.position = CGPoint(x: joyStickView.frame.width/2, y: 0)
            
        case .down:
            joyStick.position = CGPoint(x: joyStickView.frame.width/2, y: joyStickView.frame.height)
            
        }
        
    }
    
    func JoyStickTouchLogic(stickLocation location:CGPoint)->CGVector{
        
        let pixelBuffer:CGFloat = 0
        let speed:CGFloat = 5
        
        let center = CGPoint(x: joyStickView.frame.width/2, y: joyStickView.frame.height/2)
        let centerRadius = joyStick.frame.width/2 / 2
        
        
        //--------------------------
        //------JoyStick Logic------
        //--------------------------
        let c = sqrt( pow(location.x - center.x , 2) + pow(location.y - center.y, 2) )
        let unitX = location.x - center.x
        let unitY = location.y - center.y
        
        let unitTargetPosition = CGPoint(x: unitX / c, y: unitY / c)
        
        //let player = myPlayer!
        
        // add unitTargetPosition point adjustment here
        let x = unitTargetPosition.x
        let y = unitTargetPosition.y
        
        var dx = 0
        var dy = 0
        
        //------Eight Directions------
        //=========================
/*if c < centerRadius { //neutral
joyStickDirection = .neutral
dx = 0
dy = 0
}
else if x >= cos(3 * MATH_PI / 8) && x <= cos(MATH_PI / 8) && y > 0 { //up-right
//add jointStick position
joyStickDirection = .upRight
dx = 1
dy = 1

}
else if x >= cos(3 * MATH_PI / 8) && x <= cos(MATH_PI / 8) && y < 0 {//down-right
//add jointStick position
joyStickDirection = .downRight
dx = 1
dy = -1

}
else if x >= cos(MATH_PI / 8){//right
//add jointStick position
joyStickDirection = .right
dx = 1
dy = 0

}
else if x <= -1 * cos(MATH_PI / 8){//left
//add jointStick position
joyStickDirection = .left
dx = -1
dy = 0

}
else if x <= -1 * cos(3 * MATH_PI / 8) && x >= -1 * cos(MATH_PI / 8) && y > 0 { //up-left
//add jointStick position
joyStickDirection = .upLeft
dx = -1
dy = 1


}
else if x <= -1 * cos(3 * MATH_PI / 8) && x >= -1 * cos(MATH_PI / 8) && y < 0 {//down-left
//add jointStick position
joyStickDirection = .downLeft
dx = -1
dy = -1


}
else if y >= sin(3 * MATH_PI / 8){//up
//add jointStick position
joyStickDirection = .up
dx = 0
dy = 1

}
else if y <= -1 * sin(3 * MATH_PI / 8){//down
//add jointStick position
joyStickDirection = .down
dx = 0
dy = -1

}*/
        //---------Four Directions -----------
        //===================================
        if c < centerRadius { //neutral
            joyStickDirection = .neutral
            dx = 0
            dy = 0
        }
        else if x >= cos(MATH_PI / 4){//right
            //add jointStick position
            joyStickDirection = .right
            dx = 1
            dy = 0
            
        }
        else if x <= -1 * cos(MATH_PI / 4){//left
            //add jointStick position
            joyStickDirection = .left
            dx = -1
            dy = 0
            
        }
        else if y >= sin(MATH_PI / 4){//up
            //add jointStick position
            joyStickDirection = .up
            dx = 0
            dy = 1
            
        }
        else if y <= -1 * sin(MATH_PI / 4){//down
            //add jointStick position
            joyStickDirection = .down
            dx = 0
            dy = -1
            
        }
        
        adjustJoyStick()
        
        
        return CGVector(dx: dx, dy: dy)
        
    }
    
    
    
    
    
}



