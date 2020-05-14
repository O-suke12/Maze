//
//  ViewController.swift
//  Maze
//
//  Created by RS on 2020/05/13.
//  Copyright © 2020 osuke. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let screenSize = UIScreen.main.bounds.size
    
    let maze = [
    [1,0,0,0,1,0],
    [1,0,1,0,1,0],
    [3,0,1,0,1,0],
    [1,1,1,0,0,0],
    [1,0,0,1,1,0],
    [0,0,1,0,0,0],
    [0,1,1,0,1,0],
    [0,0,0,0,1,1],
    [0,1,1,0,0,0],
    [0,0,1,1,1,2],
    ]
    var startview: UIView!
    var goalview: UIView!
    var wallRectArray = [CGRect]()
    var playerView: UIView!
    var playerMotionManager: CMMotionManager!
    var speedx: Double = 0.0
    var speedy: Double = 0.0
    
    
    func createView(x: Int, y: Int, width: CGFloat, height: CGFloat, offsetX: CGFloat, offsetY: CGFloat) -> UIView{
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let view = UIView(frame: rect)
        
        let center = CGPoint(x: offsetX + width * CGFloat(x), y: offsetY + height * CGFloat(y))
        
        view.center = center
        
        return view
    }
    
    func startAccelerometer() {
        let handler: CMAccelerometerHandler = {(CMAccelerometerData: CMAccelerometerData?, error: Error?) -> Void in
            self.speedx += CMAccelerometerData!.acceleration.x
            self.speedy += CMAccelerometerData!.acceleration.y
            
            var posX = self.playerView.center.x + (CGFloat(self.speedx)/3)
            var posY = self.playerView.center.y - (CGFloat(self.speedy)/3)
            
            if posX <= self.playerView.frame.width/2 {
                self.speedx = 0
                posX = self.playerView.frame.width/2
            }
            if posY <= self.playerView.frame.height/2 {
                self.speedy = 0
                posY = self.playerView.frame.height/2
            }
            if posX >= self.screenSize.width - (self.playerView.frame.width/2){
                self.speedx = 0
                posX = self.screenSize.width - (self.playerView.frame.width/2)
            }
            if posY >= self.screenSize.height - (self.playerView.frame.height/2){
                self.speedy = 0
                posY = self.screenSize.height - (self.playerView.frame.height/2)
            }
            for wallRect in self.wallRectArray {
                if wallRect.intersects(self.playerView.frame) {
                    self.gamechecheck(result: "gameover", message: "壁に当たりました")
                    return
                }
            }
                
            if self.goalview.frame.intersects(self.playerView.frame) {
                self.gamechecheck(result: "clear", message: "クリアしました")
                return
            }
                
            self.playerView.center = CGPoint(x: posX, y: posY)
        }
        
        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: handler)
    }
    
    func gamechecheck (result: String, message: String) {
        if playerMotionManager.isAccelerometerActive {
            playerMotionManager.stopAccelerometerUpdates()
        }
        let gamecheckAlert: UIAlertController = UIAlertController(title: result, message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "もう一度", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.retry()
        } )
        gamecheckAlert.addAction(retryAction)
        self.present(gamecheckAlert, animated: true, completion: nil)
    }
    func retry() {
        playerView.center = startview.center
        if !playerMotionManager.isAccelerometerActive{
            self.startAccelerometer()
        }
        speedx = 0.0
        speedy = 0.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let cellWidth = screenSize.width / CGFloat(maze[0].count)
        let cellHeight = screenSize.height/CGFloat(maze.count)
        
        let cellOffsetX = screenSize.width / CGFloat(maze[0].count*2)
        let cellOffsetY = screenSize.height / CGFloat(maze.count*2)
        
        for y in 0 ..< maze.count {
            for x in 0 ..< maze[y].count {
                switch maze[y][x] {
                case 1:
                    let wallView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    wallView.backgroundColor = UIColor.black
                    view.addSubview(wallView)
                    wallRectArray.append(wallView.frame)
                case 2:
                    startview = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    startview.backgroundColor = UIColor.green
                    view.addSubview(startview)
                case 3:
                    goalview = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    goalview.backgroundColor = UIColor.red
                    view.addSubview(goalview)
                default:
                    break
                    
                }
            }
        }
        playerView = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth/6, height: cellHeight/6))
        playerView.center = startview.center
        playerView.backgroundColor = UIColor.gray
        view.addSubview(playerView)
        
        playerMotionManager = CMMotionManager()
        playerMotionManager.accelerometerUpdateInterval = 0.02
        
        startAccelerometer()
    }
}

