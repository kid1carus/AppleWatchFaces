
import UIKit
import SpriteKit

public typealias _ImageLiteralType = UIImage
public extension UIImage {
    private convenience init!(failableImageLiteral name: String) {
        self.init(named: name)
    }
    
    convenience init(imageLiteralResourceName name: String) {
        self.init(failableImageLiteral: name)
    }
}

class UIGradientImage: UIImage {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init?(size: CGSize, colors: [CGColor], locations: [CGFloat], startPoint: CGPoint, endPoint: CGPoint) {
        let colors = colors as CFArray
        guard let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: locations) else {return nil}
        self.init(size: size, gradient: grad, startPoint: startPoint, endPoint: endPoint)
    }
    
    convenience init?(size: CGSize, gradient: CGGradient, startPoint: CGPoint, endPoint: CGPoint) {
        UIGraphicsBeginImageContext(size)
        let ref = UIGraphicsGetCurrentContext()
        ref?.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation] )
        if let img = UIGraphicsGetImageFromCurrentImageContext()?.cgImage {
            self.init(cgImage: img)
            UIGraphicsEndImageContext()
        } else {
            UIGraphicsEndImageContext()
            return nil
        }
    }
    
    override init(cgImage: CGImage) {
        super.init(cgImage: cgImage)
    }
    
    override init(cgImage: CGImage, scale: CGFloat, orientation: UIImage.Orientation) {
        super.init(cgImage: cgImage, scale: scale, orientation: orientation)
    }
    
//    @objc required convenience init(imageLiteralResourceName name: String) {
//        fatalError("init(imageLiteralResourceName:) has not been implemented")
//    }
    
    

    
}
