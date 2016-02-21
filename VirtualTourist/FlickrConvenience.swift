//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Janaki Burugula on Feb/16/2016.
//  Copyright © 2016 janaki. All rights reserved.
//

import Foundation
import MapKit

extension FlickrClient {
    func getPhotos(selectedPin : Pin!, pageNumber : Int = 1, completionHandler: (result: [[String: AnyObject]]?, error: NSError?) -> Void){
        
        /* 1. Set the parameters */
        let methodParameters = [FlickrClient.Keys.method: FlickrClient.Constants.method,
            FlickrClient.Keys.APIKey : FlickrClient.Constants.APIKey,
            FlickrClient.Keys.lat : selectedPin.coordinate.latitude,
            FlickrClient.Keys.lon : selectedPin.coordinate.longitude,
            FlickrClient.Keys.safeSearch : FlickrClient.Constants.safeSearch,
            FlickrClient.Keys.extras : FlickrClient.Constants.extras,
            FlickrClient.Keys.format : FlickrClient.Constants.format,
            FlickrClient.Keys.nojsoncallback : FlickrClient.Constants.nojsoncallback,
            FlickrClient.Keys.perPage : FlickrClient.Constants.perPage,
            FlickrClient.Keys.pageNumber : pageNumber]
        
        /* 2. Build the URL */
        
        let urlString = FlickrClient.Constants.baseSecureUrl +
            escapedParameters(methodParameters as! [String : AnyObject])
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        
        /* 4. Make the request */
       
        let task = session.dataTaskWithRequest(request) { (data, response, downloadError) in
          do{
                 /* 5. Parse the data */
                let parsingError: NSError? = nil
                 let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                  // completionHandler(result: parsedResult, error: nil)
                } catch _ as NSError{
                    parsedResult = nil
                    print("Could not parse the data as JSON")
                  //  completionHandler(result: nil, error: parsingError)
                    return
                }
                 /* 6. Use the data! */
                if let error = parsingError {
                    print("Parsing Error: \(error)")
                } else {
                    if let photosDictionary = parsedResult.valueForKey(FlickrClient.JSONResponseKeys.photos) as? [String:AnyObject] {
                        // check how many photos are there
                        var totalPhotosVal = 0
                        if let totalPhotos = photosDictionary[FlickrClient.JSONResponseKeys.total] as? String {
                            totalPhotosVal = (totalPhotos as NSString).integerValue
                        }
                        if totalPhotosVal > 0 {
                            if let photosArray = photosDictionary[FlickrClient.JSONResponseKeys.photo] as? [[String: AnyObject]] {
                                
                                completionHandler(result: photosArray, error: nil)
                                
                            } else {
                                print("Cant find key 'photo' in \(photosDictionary)")
                            }
                            
                        } else { completionHandler(result: nil, error: NSError(domain: "Results from Flickr", code: 0, userInfo: [NSLocalizedDescriptionKey: "This pin has no images."]))
                        }
                     } else {
                        completionHandler(result: nil, error: NSError(domain: "Results from Flickr", code: 0, userInfo: [NSLocalizedDescriptionKey: "Download (server) error occured. Please retry."]))
                    }
            }} catch {
            print("error in Parsing")}
        }
            /* 7. Start the request */
            task.resume()
    
    }
    
    
    func getPhotoForImageUrl(photo : Photo,completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        
        /* 2. Build the URL */
        let urlString = photo.imageUrl
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                
                completionHandler(success: false, error: error)
            } else {
                /* 5. Parse the data */
                if let result = data {
                    
                    /* 6. Use the data! */
                    //  Make a fileURL for it
                    
                    let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
                    let fName = url.URLByDeletingPathExtension?.lastPathComponent
                    let filepathcomp = url.pathComponents
                    let fileName =  filepathcomp!.last! as String
                    let pathArray = [dirPath,fileName]
                    let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!
                    // Save it
                    NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: result, attributes: nil)
                    
                    // Update the Photo managed object with the file path.
                    dispatch_async(dispatch_get_main_queue()){
                        photo.imageFilename = fName
                    }
                    completionHandler(success: true, error: nil)
                }
                
            }
        }
        /* 7. Start the request */
        task.resume()
    }
    
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}