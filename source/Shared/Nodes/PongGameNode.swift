//
//  PongGameNode.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 3/9/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit

enum PongModes: String {
    case Normal, Paused, ScoringLeft, ScoringRight, GameOver
}

class PongGameNode: SKSpriteNode {
    
    //defines
    let ballSize = CGSize.init(width: 7, height: 10)
    let paddleSize = CGSize.init(width: 7, height: 50)
    let paddlePaddingFromEdges:CGFloat = 20.0
    let globalFriction:CGFloat = 0.0
    let globalRestitution:CGFloat = 1.0
    let linerDamping:CGFloat = 0.0
    var ballVelocity: CGFloat = 1
    var leftPaddleOffset:CGFloat = 0.0
    var rightPaddleOffset:CGFloat = 0.0
    
    //game vars
    var gameMode:PongModes = .Paused
    
    func positionHands( hour: CGFloat, min: CGFloat ) {
        //          debugPrint("position hour")
        guard let scoreLeft = self.childNode(withName: "scoreLeft") as? SKLabelNode else { return }
        scoreLeft.text = String(format: "%02d", Int(hour))
        //            debugPrint("position min")
        guard let scoreRight = self.childNode(withName: "scoreRight") as? SKLabelNode else { return }
        scoreRight.text = String(format: "%02d", Int(min))
    }
    
    func updateTime() {
        let date = ClockTimer.currentDate
        var calendar = Calendar.current
        calendar.locale = NSLocale.current
        
        let minutes = CGFloat(calendar.component(.minute, from: date))
        let hours = CGFloat(calendar.component(.hour, from: date))
        
        positionHands(hour: hours, min: minutes)
    }
    
    func resetLevel() {
        leftPaddleOffset = 0.0
        rightPaddleOffset = 0.0
        if let leftPaddle = self.childNode(withName: "leftPaddle") {
            leftPaddle.position = CGPoint.init(x: leftPaddle.position.x, y: 0)
        }
        if let rightPaddle = self.childNode(withName: "rightPaddle") {
            rightPaddle.position = CGPoint.init(x: rightPaddle.position.x, y: 0)
        }
        launchBall()
    }
    
    func launchBall() {
        gameMode = .Normal
        guard let ball = self.childNode(withName: "ball") else { return }
        
        //start the ball in motion
        let dx = drand48() > 0.5 ? -ballVelocity : ballVelocity
        let dy = drand48() > 0.5 ? -ballVelocity : ballVelocity
        
        ball.position = CGPoint.zero
        ball.physicsBody?.velocity = CGVector.zero
        ball.physicsBody?.applyImpulse(CGVector(dx: dx+0.05, dy: dy))
    }
    
    func getPhysicBody(size: CGSize) -> SKPhysicsBody {
        
        let physicsBody = SKPhysicsBody.init(rectangleOf: size)
        //ball.physicsBody!.affectedByGravity = false
        physicsBody.friction = globalFriction
        physicsBody.restitution = globalRestitution
        physicsBody.linearDamping = linerDamping
        
        return physicsBody
    }
    
    @objc func onNotificationForMinuteChanged(notification:Notification) {
        gameMode = .ScoringRight
    }
    
    @objc func onNotificationForHourChanged(notification:Notification) {
        gameMode = .ScoringLeft
    }
    
    init(size: CGSize, material: String, strokeColor: SKColor, lineWidth: CGFloat) {
        
        super.init(texture: nil, color: SKColor.clear, size: size)
        
        let color = SKColor.init(hexString: material)
        
        //self.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
    
        //draw line
        let line = SKLabelNode.init(fontNamed: "PixelMillennium")
        line.text = "------------"
        line.fontSize = 50.0
        line.zRotation = CGFloat(Double.pi/2)
        line.verticalAlignmentMode = .center
        line.zPosition = -1.0
        line.fontColor = color
        
        self.addChild(line)
        
        //draw score L
        let scoreLeft = SKLabelNode.init(fontNamed: "PixelMillennium")
        scoreLeft.text = "00"
        scoreLeft.fontSize = 60.0
        scoreLeft.zPosition = -1.0
        scoreLeft.fontColor = color
        scoreLeft.name = "scoreLeft"
        scoreLeft.position = CGPoint.init(x: -size.width/4, y: size.height/2 - 50)
        
        self.addChild(scoreLeft)
        
        //draw score R
        let scoreRight = SKLabelNode.init(fontNamed: "PixelMillennium")
        scoreRight.text = "00"
        scoreRight.fontSize = 60.0
        scoreRight.zPosition = -1.0
        scoreRight.fontColor = color
        scoreRight.name = "scoreRight"
        scoreRight.position = CGPoint.init(x: size.width/4, y: size.height/2 - 50)
        
        self.addChild(scoreRight)
        
        let ball = SKShapeNode.init(rectOf: ballSize)
        ball.fillColor = color
        ball.lineWidth = 0.0
        ball.name = "ball"
        ball.physicsBody = getPhysicBody(size: ballSize)
        //ball.physicsBody!.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody!.allowsRotation = false
        
        self.addChild(ball)
        
        let leftPaddle = SKShapeNode.init(rectOf: paddleSize)
        leftPaddle.fillColor = color
        leftPaddle.lineWidth = 0.0
        leftPaddle.name = "leftPaddle"
        leftPaddle.physicsBody = getPhysicBody(size: paddleSize)
        leftPaddle.physicsBody!.isDynamic = false
        leftPaddle.position = CGPoint.init(x: -size.width/2 + paddlePaddingFromEdges , y: 0)
        self.addChild(leftPaddle)
        
        let rightPaddle = SKShapeNode.init(rectOf: paddleSize)
        rightPaddle.fillColor = color
        rightPaddle.lineWidth = 0.0
        rightPaddle.name = "rightPaddle"
        rightPaddle.physicsBody = getPhysicBody(size: paddleSize)
        rightPaddle.physicsBody!.isDynamic = false
        rightPaddle.position = CGPoint.init(x: size.width/2 - paddlePaddingFromEdges , y: 0)
        self.addChild(rightPaddle)
        
        updateTime()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForMinuteChanged(notification:)), name: ClockTimer.timeChangedMinuteNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForHourChanged(notification:)), name: ClockTimer.timeChangedHourNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationFrameUpdate(notification:)), name: SKWatchScene.sceneSlowFrameUpdateNotificationName, object: nil)
        
        delay(1.0) {
            self.launchBall()
        }
        //launchBall()
        
    }
    
    func updateOffsets(clampL:Bool, clampR: Bool) {
        let rang = 0.5
        let mult = 8.0
        
        if gameMode == .Normal {
            leftPaddleOffset += CGFloat(mult * Double.random(in: -rang ... rang))
            rightPaddleOffset += CGFloat(mult * Double.random(in: -rang ... rang))
        }
        
        //time to lose !!
        let deadManSpeed:CGFloat = 3.0
        if gameMode == .ScoringLeft {
            if leftPaddleOffset>0 {
                leftPaddleOffset += deadManSpeed
            } else {
                leftPaddleOffset -= deadManSpeed
            }
        }
        if gameMode == .ScoringRight {
            if rightPaddleOffset>0 {
                rightPaddleOffset += deadManSpeed
            } else {
                rightPaddleOffset -= deadManSpeed
            }
        }
        
        //clamp
        let bumpBackAmt = paddleSize.height/10
        let edge = paddleSize.height/3
        
        if (clampL && gameMode == .Normal) {
            if leftPaddleOffset > edge { leftPaddleOffset -= bumpBackAmt }
            if leftPaddleOffset < -edge { leftPaddleOffset += bumpBackAmt }
        }
        if (clampR && gameMode == .Normal) {
            if rightPaddleOffset > edge { rightPaddleOffset -= bumpBackAmt }
            if rightPaddleOffset < -edge { rightPaddleOffset += bumpBackAmt }
        }
        
    }
    
    @objc func onNotificationFrameUpdate(notification:Notification) {
        
        if gameMode == .Paused { return }
        
        // Called before each frame is rendered
        guard let ball = self.childNode(withName: "ball") else { return }
        
        //check for end of level
        let edgeBuffer:CGFloat = 20.0
        if ball.position.x > (self.frame.size.width/2 - edgeBuffer) || ball.position.x < (-self.frame.size.width/2 + edgeBuffer) {
            updateTime()
            resetLevel()
        }
        
        var clampL = true
        var clampR = true
        
        //move left paddle
        if let leftPaddle = self.childNode(withName: "leftPaddle") {
            let paddleDist = abs(ball.position.x - leftPaddle.position.x)
            if paddleDist>50 { clampL = false }
            leftPaddle.position = CGPoint.init(x: leftPaddle.position.x, y: ball.position.y + leftPaddleOffset)
        }
        
        //move right paddle
        if let rightPaddle = self.childNode(withName: "rightPaddle") {
            let paddleDist = abs(ball.position.x - rightPaddle.position.x)
            if paddleDist>50 { clampR = false }
            rightPaddle.position = CGPoint.init(x: rightPaddle.position.x, y: ball.position.y + rightPaddleOffset)
        }
    
        updateOffsets(clampL: clampL, clampR: clampR)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

