//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Janaki Burugula on Feb/18/2016.
//  Copyright © 2016 janaki. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController : UIViewController , UICollectionViewDelegate , NSFetchedResultsControllerDelegate , UICollectionViewDataSource{
    
    @IBOutlet weak var bottomButton: UIBarButtonItem!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var smallMapView: MKMapView!
    
    
    var selectedPin : Pin!
    var page : Int = 1
    var longitude : Double?
    var latitude : Double?
    var photos = [UIImage]() //UIImage(data: imageData)
    var pin : Pin!
    
    //  indexes arrays to keeps all of the indexPaths for cells that are "selected"
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
         collectionView!.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        collectionView.delegate = self
        collectionView.dataSource = self
        
        populateNavigationBar()
        
        setMapRegion(true)
        
        self.smallMapView.addAnnotation(selectedPin)
        self.smallMapView.zoomEnabled = false
        self.smallMapView.scrollEnabled = false
        self.smallMapView.userInteractionEnabled = false
     //    page = 1
        if latitude == nil || longitude == nil    {
            return
        }
        
        
        fetchedResultsController.delegate = self
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
            self.showAlertView("No Images found for this pin. Please select a different pin")
        }
        
        // check if there are available photos associted with the pin
        if fetchedResultsController.fetchedObjects?.count == 0 {
            bottomButton.enabled = true
        }
        
        if selectedPin?.photos.count ==  nil || selectedPin?.photos.count==0{
            newPhotoCollection()
        }
        
    }
    
    func populateNavigationBar() {
        
        navigationItem.leftBarButtonItem  = UIBarButtonItem(title: "Ok", style: .Plain, target: self, action: "backToMapView")
        
    }
    
    func backToMapView(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setMapRegion(animated: Bool) {
        let span = MKCoordinateSpan(latitudeDelta: 0.2 , longitudeDelta: 0.2)
      //  let center = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        
        let savedRegion = MKCoordinateRegion(center: selectedPin.coordinate, span: span)
        
        self.smallMapView.setRegion(savedRegion, animated: animated)
    }
    
    
    override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    // Lay out the collection view so that cells take up 1/3 of the width,
    // with no space in between.
    let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    layout.minimumLineSpacing = 5
    layout.minimumInteritemSpacing = 5
    
    let width = floor((self.collectionView!.frame.size.width-20)/3)
    layout.itemSize = CGSize(width: width, height: width)
    collectionView!.collectionViewLayout = layout
    }
    
    
    func collectionView(tableView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section] 
        return sectionInfo.numberOfObjects
        
    }
    
    func collectionView(tableView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView?.dequeueReusableCellWithReuseIdentifier("PhotoAlbumCollectionViewCell", forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
         
        // reset pevious images in the cell
        cell.imageView.image = nil
        
        // show activity indicator busy
        cell.activityIndicator.startAnimating()
        
        // if there is an image, update the cell appropriately
        if photo.image != nil {
            
            cell.activityIndicator.hidden = true
            cell.activityIndicator.stopAnimating()
            cell.imageView.alpha = 0.0
            cell.imageView.image = photo.image
            
            UIView.animateWithDuration(0.2,
                animations: { cell.imageView.alpha = 1.0 })
        }
        
        else{
            cell.imageView.image = UIImage(named: "placeholder")
            cell.activityIndicator.hidden = false
            cell.activityIndicator.startAnimating()
            cell.imageView.alpha = 0.5
            
            }
        return cell
    }
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        // enable bottom button.
        if controller.fetchedObjects?.count > 0 {
            
            bottomButton.enabled = true
        }
        //Make the relevant updates to the collectionView once Core Data has finished its changes.
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
    
    @IBAction func bottomButtonClicked(sender: AnyObject) {
        if selectedIndexes.count == 0 {
            updateBottomButton()
            newPhotoCollection()
        } else {
            deleteSelectedPhotos()
            
            updateBottomButton()
        }
         dispatch_async(dispatch_get_main_queue()){
            CoreDataStackManager.sharedInstance().saveContext()
            
        }
    }
    
    func deleteSelectedPhotos() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            sharedContext.deleteObject(photo)
        }
        // remove the deleted image indexes
        selectedIndexes = []
    }
    
    func updateBottomButton() {
        if selectedIndexes.count > 0 {
            bottomButton.title = "Remove Selected Photos"
        } else {
            bottomButton.title = "New Collection"
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pins == %@", self.selectedPin)
        
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCollectionViewCell
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
            cell.imageView.alpha = 1.0
        } else {
            self.selectedIndexes.append(indexPath)
            cell.imageView.alpha = 0.5
        }
        
        //  update lable of the bottom button
        updateBottomButton()
    }
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // initialize the arrays for change
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            updatedIndexPaths.append(indexPath!)
            break
            
        default:
            break
        }
    }
    
    // Retreive new collection of pictures
    
    func newPhotoCollection(){
        bottomButton.enabled = false
        
        page += 1
        
        // delete existing photos
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        // save on the main thread (part of getting Core Data thread safe)
        dispatch_async(dispatch_get_main_queue()){
            CoreDataStackManager.sharedInstance().saveContext()
        }
        
        FlickrClient.sharedInstance().getPhotos(self.selectedPin, pageNumber: page){(result, error) in
            
            if error == nil {
                
                // Parse the array of photos dictionaries
                dispatch_async(dispatch_get_main_queue()){
                    _ = result?.map() {(dictionary: [String : AnyObject]) -> Photo in
                        
                        let photo = Photo(dictionary: dictionary, pin: self.selectedPin, context: self.sharedContext)
                        // set the relationship
                        photo.pins = self.selectedPin
                        FlickrClient.sharedInstance().getPhotoForImageUrl(photo){(success, error) in
                            
                            if error == nil {
                                dispatch_async(dispatch_get_main_queue(), {
                                    CoreDataStackManager.sharedInstance().saveContext()
                                    
                                })
                                
                            }
                            self.bottomButton.enabled = true
                            
                        }
                        
                        return photo
                    }
                }
            } else {
                // Error, e.g. the pin has no images or the internet connection is offline
                print("Error: \(error?.localizedDescription)")
                self.showAlertView("Pin Has no Images. Please select Different Pin")
            }
        }
        // save data
        dispatch_async(dispatch_get_main_queue()){
            CoreDataStackManager.sharedInstance().saveContext()
        }
        
    }
    
    // Display Alert when no images retreived
    
    func showAlertView(errorMessage: String?) {
        
        let alertController = UIAlertController(title: nil, message: errorMessage!, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel) {(action) in
            
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true){
            
        }
        
    }
    
}