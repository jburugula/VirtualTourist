//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Janaki Burugula on Feb/16/2016.
//  Copyright © 2016 janaki. All rights reserved.
//

import Foundation
extension FlickrClient {
    
    
    struct Constants {
        static let baseSecureUrl: String = "https://api.flickr.com/services/rest/"
        static let APIKey = "df74ddf832696c9a9615dd804edbbe30"
        static let method = "flickr.photos.search"
    //    static let boundingBoxHalfWidth = 1.0
    //    static let boundingBoxHalfHeight = 1.0
    //    static let latitudeMin = -90.0
    //    static let latitudeMax = 90.0
    //    static let longitudeMin = -180.0
    //    static let longitudeMax = 180.0
        static let safeSearch = "1"
        static let extras = "url_m"
        static let format = "json"
        static let nojsoncallback = "1"
        static let perPage = "21"
        static let page = 1
        static var numToShowPerPage = 4
        static var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        static var nameOfCollection = "default"
    }
    
    struct Keys {
        static let method = "method"
        static let APIKey = "api_key"
      //  static let boundingBox = "bbox"
        static let safeSearch = "safe_search"
        static let extras = "extras"
        static let format = "format"
        static let nojsoncallback = "nojsoncallback"
        static let perPage = "per_page"
        static let pageNumber = "page"
        static let lat = "lat"
        static let lon = "lon"
        
    }
    
    struct JSONResponseKeys {
        static let photos = "photos"
        static let photo = "photo"
        static let pages = "pages"
        static let total = "total"
    }
}