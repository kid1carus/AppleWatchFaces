//
//  FlipNode.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 8/19/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation
import SpriteKit

class FlipNode: SKSpriteNode {
    //used when updating
    var currentText = ""
    var fillColor: SKColor = SKColor.darkGray
    var strokeColor: SKColor? = SKColor.white
    var lineWidth: Float = 1.0
    
    //alterable vars
    var cardRect = CGRect.init(x: 0, y: 0, width: 220, height: 300)
    let middleGap:CGFloat = 1.0
    
    let animationDuration = 0.5
    let waitDuration = 1.0
    
    let shadowFullAlpha:CGFloat = 0.8
    
    let xScaleFactor = 1.075 // hoiw much to scale in the X direction
    let xScaleMagicDivider:CGFloat = 20.0 //how much to divide the position movement ( adjust with xScaleFactor )
    
    func getFlipClockCard(labelNode: SKLabelNode) -> SKShapeNode {
        let frameNode = SKShapeNode.init(rect: cardRect, cornerRadius: 10.0)
        frameNode.fillColor = fillColor
        if let strokeColor = self.strokeColor {
            frameNode.strokeColor = strokeColor
            frameNode.lineWidth = CGFloat(lineWidth)
        }
        
        labelNode.position = CGPoint.init(x: cardRect.size.width/2, y: cardRect.size.height/2)
        
        frameNode.addChild(labelNode)
        
        return frameNode
    }
    
    func getMaskNodeBottom() -> SKShapeNode {
        let maskNodeBottom = SKShapeNode.init(rect: CGRect.init(x: 0, y: -middleGap, width: cardRect.size.width, height: cardRect.size.height/2), cornerRadius: 0)
        maskNodeBottom.fillColor = SKColor.white
        
        return maskNodeBottom
    }
    
    func getMaskNodeTop() -> SKShapeNode {
        let maskNodeTop = SKShapeNode.init(rect: CGRect.init(x: 0, y: cardRect.size.height/2, width: cardRect.size.width, height: cardRect.size.height/2), cornerRadius: 0)
        maskNodeTop.fillColor = SKColor.white
        
        return maskNodeTop
    }
    
    func getShadowNode() -> SKSpriteNode {
        //shadow node props
        let color1 = SKColor.black
        let color2 = SKColor.clear
        let colors = [ color2.cgColor, color1.cgColor ]
        let locations:[CGFloat] = [0.0,1.0]
        let startPoint = CGPoint.init(x: 0, y: 0)
        let endPoint = CGPoint.init(x: 0, y: cardRect.size.height/6)
        
        let newSize = CGSize.init(width: cardRect.size.width, height: cardRect.size.height/1.2)
        
        if let gradientImage = UIGradientImage.init(size: newSize, colors: colors,
                                                    locations: locations, startPoint: startPoint, endPoint: endPoint) {
            
            let tex = SKTexture.init(cgImage: gradientImage.cgImage!)
            let shadowNode = SKSpriteNode.init(texture: tex)
            return shadowNode
        }
        
        return SKSpriteNode.init()
    }
    
    func updateToDigit(newLabel: SKLabelNode, newText: String) {
        //exit early if its the same text
        guard  self.currentText != newText else { return }
        self.currentText = newText
        
        //new text, lets update
        guard let effectsNodeWrapper = self.childNode(withName: "effectsNodeWrapper") else { return }
        guard let oldCropNodeTop = effectsNodeWrapper.childNode(withName: "cropNodeTop") else { return }
        guard let oldCropNodeTopShadow = oldCropNodeTop.childNode(withName: "shadowNode") else { return }
        guard let oldCropNodeBottom = effectsNodeWrapper.childNode(withName: "cropNodeBottom") else { return }
        guard let oldCropNodeBottomShadow = oldCropNodeBottom.childNode(withName: "shadowNode") else { return }
        
        //remove any leftovers just in case ( if remove action was skipped )
        if let oldCropNodeTop = effectsNodeWrapper.childNode(withName: "oldCropNodeTop") {
            oldCropNodeTop.removeAllActions()
            oldCropNodeTop.removeFromParent()
        }
//        if let oldCropNodeBottom = effectsNodeWrapper.childNode(withName: "oldCropNodeBottom") {
//            oldCropNodeBottom.removeAllActions()
//            oldCropNodeBottom.removeFromParent()
//        }
        
        oldCropNodeTop.name = "oldCropNodeTop"
        oldCropNodeBottom.name = "oldCropNodeBottom"
        
        let cropNodeBottom = SKCropNode()
        cropNodeBottom.name = "cropNodeBottom"
        
        //add shadow node
        let bottomShadow = getShadowNode()
        bottomShadow.yScale = -1.0
        bottomShadow.position = CGPoint.init(x: cardRect.size.width/2, y: cardRect.size.height/3)
        bottomShadow.name = "shadowNode"
        bottomShadow.alpha = 0.0
        
        let frameNode = getFlipClockCard(labelNode: newLabel)
        
        cropNodeBottom.addChild(frameNode.copy() as! SKShapeNode)
        cropNodeBottom.addChild(bottomShadow)
        cropNodeBottom.maskNode = getMaskNodeBottom()
        
        effectsNodeWrapper.addChild(cropNodeBottom)
        
        let cropNodeTop = SKCropNode()
        cropNodeTop.name = "cropNodeTop"
        
        //add shadow node
        let topShadow = getShadowNode()
        topShadow.position = CGPoint.init(x: cardRect.size.width/2, y: cardRect.size.height/2)
        topShadow.name = "shadowNode"
        topShadow.alpha = shadowFullAlpha
        
        cropNodeTop.addChild(frameNode.copy() as! SKShapeNode)
        cropNodeTop.addChild(topShadow)
        cropNodeTop.maskNode = getMaskNodeTop()
        
        cropNodeTop.position = CGPoint.init(x: 0, y: middleGap)
        
        effectsNodeWrapper.addChild(cropNodeTop)
        
        //push old to top
        oldCropNodeTop.zPosition = 1
        oldCropNodeTopShadow.zPosition = 2
        cropNodeTop.zPosition = 0
        topShadow.zPosition = 1
        bottomShadow.zPosition = 3
        
        //set new bottom to yScale 0 and push it up, so we can scale up and push down
        cropNodeBottom.yScale = 0
        cropNodeBottom.position = CGPoint.init(x: 0, y: cardRect.size.height/2)
        //hide old shadow node
        oldCropNodeTopShadow.alpha = 0.0
        //stretch bottom thats going to come in
        cropNodeBottom.xScale = CGFloat(xScaleFactor)
        cropNodeBottom.position.x = -CGFloat(cardRect.size.width/xScaleMagicDivider)/CGFloat(xScaleFactor)
        
        let timingModeForTop = SKActionTimingMode.easeIn
        let timingModeForBottom = SKActionTimingMode.easeIn
        
        let scaleYAction = SKAction.scaleY(to: 0, duration: animationDuration/2)
        scaleYAction.timingMode = timingModeForTop
        
        let moveYAction = SKAction.moveBy(x: 0, y: CGFloat(cardRect.size.height/2 - middleGap), duration: animationDuration/2)
        moveYAction.timingMode = timingModeForTop
        
        let scaleXAction = SKAction.scaleX(to: CGFloat(xScaleFactor), duration: animationDuration/2)
        scaleXAction.timingMode = timingModeForTop
        
        let moveXAction = SKAction.moveBy(x: -CGFloat(cardRect.size.width/xScaleMagicDivider)/CGFloat(xScaleFactor), y: 0, duration: animationDuration/2)
        moveXAction.timingMode = timingModeForTop
        
        let topDropActionGroup = SKAction.group([scaleXAction, moveXAction, moveYAction, scaleYAction])
        
        let topSeq = SKAction.sequence([topDropActionGroup, SKAction.removeFromParent()])
        
        oldCropNodeTop.run(topSeq)
        
        //animate in shadows
        oldCropNodeTopShadow.run(SKAction.fadeAlpha(to: shadowFullAlpha, duration: animationDuration/2) )
        oldCropNodeBottomShadow.run(SKAction.fadeAlpha(to: shadowFullAlpha/1.1, duration: animationDuration/1.5) )
        topShadow.run(SKAction.fadeAlpha(to: 0, duration: animationDuration/1.5) )
        
        let scaleYBottomAction = SKAction.scaleY(to: 1, duration: animationDuration/4)
        scaleYBottomAction.timingMode = timingModeForBottom
        
        let moveYBottomAction = SKAction.moveBy(x: 0, y: CGFloat(-cardRect.size.height/2), duration: animationDuration/4)
        moveYBottomAction.timingMode = timingModeForBottom
        
        let scaleXBottomAction = SKAction.scaleX(to: 1.0, duration: animationDuration/4)
        scaleXBottomAction.timingMode = timingModeForTop
        
        let moveXBottomAction = SKAction.moveBy(x: CGFloat(cardRect.size.width/xScaleMagicDivider)/CGFloat(xScaleFactor), y: 0, duration: animationDuration/4)
        moveXBottomAction.timingMode = timingModeForTop
        
        let bottomDropActionGroup = SKAction.group([scaleXBottomAction, moveXBottomAction,scaleYBottomAction, moveYBottomAction])
        
        let bottomSeq = SKAction.sequence([SKAction.wait(forDuration: animationDuration/2), bottomDropActionGroup])
        cropNodeBottom.run(bottomSeq)
        
        let oldRemoveSeq = SKAction.sequence([SKAction.wait(forDuration: animationDuration), SKAction.removeFromParent()])
        oldCropNodeBottom.run(oldRemoveSeq)
        
    }
    
    init(label: SKLabelNode, rect: CGRect, text: String, fillColor: SKColor, strokeColor: SKColor?, lineWidth: Float) {
        
        super.init(texture: nil, color: SKColor.clear, size: CGSize())
        
        self.name = "flipText"
        self.cardRect = rect
        self.currentText = text
        
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
        
        let frameNode = getFlipClockCard(labelNode: label )
        
        let effectsNodeWrapper = SKEffectNode.init()
        effectsNodeWrapper.name = "effectsNodeWrapper"
        
        effectsNodeWrapper.shouldRasterize = true
        
        let cropNodeBottom = SKCropNode()
        cropNodeBottom.name = "cropNodeBottom"
        
        //add shadow node
        let bottomShadow = getShadowNode()
        bottomShadow.yScale = -1.0
        bottomShadow.position = CGPoint.init(x: cardRect.size.width/2, y: cardRect.size.height/2)
        bottomShadow.name = "shadowNode"
        bottomShadow.alpha = 0.0
        
        cropNodeBottom.addChild(frameNode.copy() as! SKShapeNode)
        cropNodeBottom.addChild(bottomShadow)
        cropNodeBottom.maskNode = getMaskNodeBottom()
        
        effectsNodeWrapper.shouldRasterize = true
        effectsNodeWrapper.addChild(cropNodeBottom)
        
        //cropNodeBottom.removeAllChildren()
        
        let cropNodeTop = SKCropNode()
        cropNodeTop.name = "cropNodeTop"
        
        cropNodeTop.addChild(frameNode.copy() as! SKShapeNode)
        
        //add shadow node
        let topShadow = getShadowNode()
        topShadow.position = CGPoint.init(x: cardRect.size.width/2, y: cardRect.size.height/2)
        topShadow.name = "shadowNode"
        topShadow.alpha = 0.0
        
        cropNodeTop.addChild(topShadow)
        cropNodeTop.maskNode = getMaskNodeTop()
        
        cropNodeTop.position = CGPoint.init(x: 0, y: middleGap)
        
        effectsNodeWrapper.addChild(cropNodeTop)
        
        self.addChild(effectsNodeWrapper)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
