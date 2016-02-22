//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Janaki Burugula on Jan/30/2016.
//  Copyright © 2016 janaki. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController,MKMapViewDelegate ,NSFetchedResultsControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedPin : Pin!
    
    var pins = [Pin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // method for getting the map's state before app exited
        restoreMapRegion(true)
        // long press gesture recognizer instance
        let longPressGR = UILongPressGestureRecognizer(target: self, action: "longTap:")
        mapView.addGestureRecognizer(longPressGR)
        
        // this class is MKMapViewDelegate
        self.mapView.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        // this class is NSFetchedResultsControllerDelegate
        fetchedResultsController.delegate = self
        
        // add annotations from Core Data
        self.createAnnotations()
        
    }
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
     func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            self.performSegueWithIdentifier("showPinView", sender: self)
        }
        
    }
    
    // Segue to photo album view when Pin is selected
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)    {
        let touchedPoint = view.annotation
        
         for pin in pins {
             if touchedPoint!.coordinate.latitude == pin.latitude && touchedPoint!.coordinate.longitude == pin.longitude {
                self.selectedPin = pin
                self.selectedPin.longitude = pin.longitude
                self.selectedPin.latitude = pin.latitude
                
            }
        }
        let touchedPin = view.annotation as! Pin
        self.selectedPin = touchedPin
        mapView.deselectAnnotation(touchedPin, animated: false)
        self.performSegueWithIdentifier("showPinView", sender: self)
        
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        saveMapRegion()
    }
    
    
    // A convenient property
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL;
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    // Save the Map zoom state
    
    func saveMapRegion() {
        
        // Place the "center" and "span" of the map into a dictionary
        // The "span" is the width and height of the map in degrees.
        // It represents the zoom level of the map.
        
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        // Archive the dictionary into the filePath
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
    
    // Display the previously saved map region 
    
    func restoreMapRegion(animated: Bool) {
        
        // if we can unarchive a dictionary, we will use it to set the map back to its
        // previous center and span
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            mapView.setRegion(savedRegion, animated: animated)
        }
    }
    
    
  // set the selected pin and prepare to seque to photo labum view
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showPinView" {
            let navController = segue.destinationViewController as! UINavigationController
            let destController = navController.topViewController as! PhotoAlbumViewController
            destController.selectedPin = self.selectedPin
            destController.latitude = self.selectedPin.latitude
            destController.longitude = self.selectedPin.longitude
            
        }
    }
    
    // Create annotaions on Map for fetched pins 
    func createAnnotations(){
        
        var annotations = [Pin]()
        
        if let locations = fetchedResultsController.fetchedObjects {
            for location in locations {
                annotations.append(location as! Pin)
            }
            
            
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    // MARK: - NSFetchedResultsController delegate methods
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        let pin = anObject as! Pin
        
        switch (type){
        case .Insert:
            mapView.addAnnotation(pin)
            
        case .Delete:
            mapView.removeAnnotation(pin)
            
        default:
            return
        }
        
    }
    
    
    // MARK: - Drop Pin on the Map with Long Tap gesture
    
    func longTap(gestureRecognizer:UIGestureRecognizer) {
        
     //Drop the Pin only when the long tap ends
        
    if gestureRecognizer.state == .Ended {
        
        // coordinates of a point the user touched on the map
        
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let newCoord:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        // Drop a pin on the Map
        
        var locationDictionary = [String : AnyObject]()
        locationDictionary[Pin.Keys.latitude] = newCoord.latitude
        locationDictionary[Pin.Keys.longitude] = newCoord.longitude
        self.selectedPin = Pin(dictionary: locationDictionary, context: sharedContext)
        selectedPin.willChangeValueForKey("coordinate")
        selectedPin.safeCoordinate = newCoord
        selectedPin.didChangeValueForKey("coordinate")
        
        pins.append(self.selectedPin)
        dispatch_async(dispatch_get_main_queue(), {
            self.saveContext()

        })
        
        dispatch_async(dispatch_get_main_queue(), {
            self.mapView.addAnnotation(self.selectedPin)
            
        })
      }
        
    }
    
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
  }

