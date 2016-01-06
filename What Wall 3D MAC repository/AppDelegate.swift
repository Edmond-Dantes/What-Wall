//
//  AppDelegate.swift
//  What Wall 3D MAC repository
//
//  Created by Edmond on 1/5/16.
//  Copyright (c) 2016 Future. All rights reserved.
//

import Cocoa
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! SKNode //as! MazeScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}



//let gameScene = GameScene.unarchiveFromFile("GameScene") as? GameScene
//let mazeScene = MazeScene.unarchiveFromFile("MazeScene") as? MazeScene




@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        //      gameScene!.scaleMode = .AspectFit//*/ .AspectFill
        //      gameScene!.size = gameFrame.size
        
//        mazeScene!.scaleMode = .AspectFit
//        mazeScene!.size = gameFrame.size
        
        //    !.scaleMode = .AspectFit
        //    mazeScene!.size = gameFrame.size
    }
    
}
