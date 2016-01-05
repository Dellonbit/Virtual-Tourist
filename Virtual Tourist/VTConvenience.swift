//
//  VTConvenience.swift
//  Virtual Tourist
//
//  Created by arianne on 2015-12-05.
//  Copyright © 2015 della. All rights reserved.
//

import UIKit
import MapKit

class VTConvenience: NSObject {
    
    var lat: CLLocationDegrees!
    var long: CLLocationDegrees!
    
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.photos.search"
    let API_KEY = "9f14b3221ffa5f43f6b5cfa688ec215e"
    let EXTRAS = "url_m"
    let SAFE_SEARCH = "1"
    let DATA_FORMAT = "json"
    let NO_JSON_CALLBACK = "1"
    let PER_PAGE = "26"
    let BOUNDING_BOX_HALF_WIDTH = 1.0
    let BOUNDING_BOX_HALF_HEIGHT = 1.0
    let LAT_MIN = -90.0
    let LAT_MAX = 90.0
    let LON_MIN = -180.0
    let LON_MAX = 180.0
    
    
    var urlPhotos = [String]()
    var titlePhotos = [String]()
    var cdArry = [Photos]()
    var maxPhotosToDisplay = 24
    
    // MARK: - Shared Instance: singleton class
    class func sharedInstance() -> VTConvenience {
        
        struct Singleton {
            static var sharedInstance = VTConvenience()
        }
        return Singleton.sharedInstance
    }

}
