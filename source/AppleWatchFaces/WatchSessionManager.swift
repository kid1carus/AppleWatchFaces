//
//  WatchSession.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 3/30/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol WatchSessionManagerDelegate: AnyObject {
    
    //activation handlers
    func sessionActivationDidCompleteError( errorMessage: String)
    func sessionActivationDidCompleteSuccess()
    
    func sessionDidBecomeInactive()
    func sessionDidDeactivate()
    
    //file transfers
    func fileTransferError( errorMessage: String)
    func fileTransferSuccess()
    
    
}

// Note that the WCSessionDelegate must be an NSObject
// So no, you cannot use the nice Swift struct here!
class WatchSessionManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = WatchSessionManager()
    weak var delegate: WatchSessionManagerDelegate?
    
    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    public var validSession: WCSession? {
        // paired - the user has to have their device paired to the watch
        // watchAppInstalled - the user must have your watch app installed
        
        // Note: if the device is paired, but your watch app is not installed
        // consider prompting the user to install it for a better experience
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            return session
        }
        return nil
    }
    
    private override init() {
        super.init()
    }
    
    func startSession() {
        session?.delegate = self
        session?.activate()
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        
        guard let delegate = delegate else { return }
        
        if let error = error  {
            delegate.fileTransferError(errorMessage: error.localizedDescription)
            //self.showError(errorMessage: error.localizedDescription)
        } else {
            delegate.fileTransferSuccess()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        guard let delegate = delegate else { return }
        
        if let error = error  {
            delegate.sessionActivationDidCompleteError(errorMessage: error.localizedDescription)
            //self.showError(errorMessage: error.localizedDescription)
        } else {
            delegate.sessionActivationDidCompleteSuccess()
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        guard let delegate = delegate else { return }
        
        delegate.sessionDidBecomeInactive()
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        guard let delegate = delegate else { return }
        
        delegate.sessionDidDeactivate()
    }
    
}


