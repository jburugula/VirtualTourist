//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Janaki Burugula on Feb/16/2016.
//  Copyright © 2016 janaki. All rights reserved.
//

import Foundation
import UIKit
import MapKit



class FlickrClient:NSObject {
    /* Shared Session */
    var session: NSURLSession
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
    
}

