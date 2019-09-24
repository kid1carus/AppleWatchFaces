//
//  BezierPath+CircleSegment.swift
//  clockology
//
//  Created by Michael Hill on 9/23/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation
import SpriteKit

extension CGFloat {
    func radians() -> CGFloat {
        let b = CGFloat(Double.pi) * (self/180)
        return b
    }
}

extension BezierPath {
    convenience init(circleSegmentCenter center:CGPoint, radius:CGFloat, startAngle:CGFloat, endAngle:CGFloat, clockwise: Bool)
   {
       self.init()
    self.move(to: CGPoint.init(x: center.x, y: center.y))
    self.addArc(withCenter: center, radius:radius, startAngle:startAngle, endAngle: endAngle, clockwise:clockwise)
    self.close()
    }
}
