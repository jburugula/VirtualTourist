//
//  Photo.swift
//  VirtualTourist
//
//  Created by Janaki Burugula on Feb/06/2016.
//  Copyright © 2016 janaki. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc(Photo)

class Photo : NSManagedObject {
    
    struct Keys {
        static let imageUrl = "url_m"
    }
    
    @NSManaged var imageFilename : String?
    @NSManaged var imageUrl : String
    @NSManaged var pins : Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
    }
    
    init(dictionary: [String : AnyObject], pin: Pin, context: NSManagedObjectContext) {
        // Core Data
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        // Dictionary
        self.imageUrl = dictionary[Keys.imageUrl] as! String
        self.pins = pin
    }
    
    var image: UIImage? {
        
        if let _ = imageFilename {
            
            let fileURL =   NSURL(string: self.imageUrl)!
            
            if let data = NSData(contentsOfURL:fileURL){
                return UIImage(data: data)
                
            }
            
        }
        return nil
    }
    
    override func prepareForDeletion() {
        //Delete the associated image file when the Photo managed object is deleted.
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let imageURL =   NSURL(string: self.imageUrl)!
        let filepathcomp = imageURL.pathComponents
        let fileName =  filepathcomp!.last! as String
        let pathArray = [dirPath,fileName]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!
        
        do {
            try NSFileManager.defaultManager().removeItemAtURL(fileURL)
        } catch let error as NSError {
            print ("Error removing picture \(error)")
        }
    }
    
    
    
}
