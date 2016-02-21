//
//  Pin.swift
//  VirtualTourist
//
//  Created by Janaki Burugula on Feb/06/2016.
//  Copyright © 2016 janaki. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

@objc(Pin)

class Pin : NSManagedObject, MKAnnotation {
    
    struct Keys {
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let photos = "photos"
    }
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: [Photo]
    
    @NSManaged var reference: Int
    @NSManaged var numberDeleted:Int
    @NSManaged var attachedPhotos: NSSet
   

    
    var safeCoordinate: CLLocationCoordinate2D? = nil
    
    var coordinate: CLLocationCoordinate2D {
        return safeCoordinate!
    }
    
  
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        safeCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        safeCoordinate = CLLocationCoordinate2DMake(latitude, longitude)

        // Dictionary
          latitude = dictionary[Keys.latitude] as! Double
          longitude = dictionary[Pin.Keys.longitude] as! Double
        
            }
     
   }