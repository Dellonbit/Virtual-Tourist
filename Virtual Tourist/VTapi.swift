//
//  VTapi.swift
//  Virtual Tourist
//
//  Created by arianne on 2015-11-23.
//  Copyright © 2015 della. All rights reserved.
//

import UIKit
import CoreData

extension VTConvenience {
    
    func searchPhotosByLatLon(lat:Double, long: Double, completion:(success:Bool, error: NSString) -> Void)  {
        /* Added from student request -- hides keyboard after searching */
        //self.dismissAnyVisibleKeyboards()
        
        if (true) {
            
            //self.photoTitleLabel.text = "Searching..."
            let methodArguments = [
                "method": METHOD_NAME,
                "api_key": API_KEY,
                "bbox": createBoundingBoxString(lat, long: long),
                "safe_search": SAFE_SEARCH,
                "extras": EXTRAS,
                "per_page": PER_PAGE,
                "format": DATA_FORMAT,
                "nojsoncallback": NO_JSON_CALLBACK
                
            ]
            getImageFromFlickrBySearch(methodArguments, completion: { (success, error, totpage) -> Void in
                if success == true{
                    print ("the total page is,  \(totpage)")
                     self.getImageFromFlickrBySearchWithPage(methodArguments, pageNumber: totpage, completion: { (success, error) -> Void in
                        if success == true {
                            print (success)
                            
                            completion (success: true, error: error)
                         }
                        
                        else {
                             completion (success: false, error: error)
                        }
                        
                      })
                    
                }
                else {
                    
                }
            })
        }
    }
    
    //methods here
    func getImageFromFlickrBySearchWithPage(methodArguments: [String : AnyObject], pageNumber: Int, completion:(success:Bool, error: NSString) -> Void) {
        
        /* Add the page to the method's arguments */
        var withPageDictionary = methodArguments
        withPageDictionary["page"] = pageNumber
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(withPageDictionary)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completion(success: false, error: "There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    completion(success: false, error: "Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                    completion(success: false, error: "Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                    completion(success: false, error: "Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completion(success: false, error: "No data was returned by the request!")
                return
            }
            
            /* Parse the data! */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                completion(success: false, error: "Could not parse the data as JSON:")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary else {
                print("Cannot find key 'photos' in \(parsedResult)")
                completion(success: false, error: "Cannot find key 'photos' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "total" key in photosDictionary? */
            guard  let totalPhotosVal = (photosDictionary["total"] as? NSString)?.integerValue else {
                print("Cannot find key 'total' in \(photosDictionary)")
                completion(success: false, error: "Cannot find key 'total' in \(photosDictionary)")
                return
            }
            
            if totalPhotosVal > 0 {
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                    print("Cannot find key 'photo' in \(photosDictionary)")
                    completion(success: false, error: "Cannot find key 'photo' in \(photosDictionary)")
                    return
                }
                
                print("photo array number is \(photosArray.count)")
                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                let photoTitle = photoDictionary["title"] as? String /* non-fatal */
                
                /* GUARD: Does our photo have a key for 'url_m'? */
                guard let imageUrlString = photoDictionary["url_m"] as? String else {
                    print("Cannot find key 'url_m' in \(photoDictionary)")
                    completion(success: false, error: "Cannot find key 'url_m' in \(photoDictionary)")
                    return
                }
                var i = 0
                for photo in photosArray {
                //var photoDictionary = photosArray[] as [String: AnyObject]
                    var photoTitle = photoDictionary["title"] as? String
                    var imageUrlString = photo["url_m"] as? String
                    if self.urlPhotos.count < self.maxPhotosToDisplay {
                        //save photo and title
                        
                        self.urlPhotos.insert(imageUrlString!, atIndex: i)
                        self.titlePhotos.insert(photoTitle!, atIndex: i)
                        i++
                  }
                //print (self.urlPhotos)
                }
                completion(success: true, error: "no error")
                
            } else {
                
                completion(success: false, error: "No Photos Found.")
            }
        }
        task.resume()
    }
    
    func getImageFromFlickrBySearch(methodArguments: [String : AnyObject], completion:(success:Bool, error: NSString, totPage: Int) -> Void) {
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                //print("There was an error with your request: \(error)")
                completion(success: false, error: "There was an error with your request: \(error)", totPage: 0)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    //print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    completion(success: false, error: "Your request returned an invalid response! Status code: \(response.statusCode)!", totPage: 0)
                } else if let response = response {
                    //print("Your request returned an invalid response! Response: \(response)!")
                    completion(success: false, error: "Your request returned an invalid response! Response: \(response)!", totPage: 0)
                } else {
                    //print("Your request returned an invalid response!")
                    completion(success: false, error: "Your request returned an invalid response!", totPage: 0)
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                //print("No data was returned by the request!")
                completion(success: false, error: "No data was returned by the request!", totPage: 0)
                return
            }
            
            /* Parse the data! */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                completion(success: false, error: "Could not parse the data as JSON", totPage: 0)
                return
            }
            
            /* GUARD: Did Flickr return an error? */
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                completion(success: false, error: "Flickr API returned an error. See error code and message in", totPage: 0)
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary else {
                print("Cannot find keys 'photos' in \(parsedResult)")
                completion(success: false, error: "Cannot find keys 'photos'", totPage: 0)
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary["pages"] as? Int else {
                //print("Cannot find key 'pages' in \(photosDictionary)")
                completion(success: false, error: "Cannot find key 'pages' ", totPage: 0)
                return
            }
            
            /* Pick a random page! */
            //let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(totalPages))) + 1
            completion(success: true, error: "no error", totPage: randomPage)
        }
        task.resume()
    }
    
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
    
    func createBoundingBoxString(lat:Double, long: Double) -> String {
        let latitude = lat
        let longitude = long
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    //It returns the actual path in the iOS readable format
    func setImagePath(Filename:String) ->String{
        let manager = NSFileManager.defaultManager()
        let pathUrl = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return pathUrl.URLByAppendingPathComponent(Filename).path!
    }
    
    //It downloads the images from the already saved image paths to be in turn saved to in the CoreData
    func downloadImageAndSetCell(imagePath:String, titlephoto: String, curPin: Pin, cell: PicsCellCollectionViewCell,completionHandler: (success: Bool, errorString: String?) -> Void){
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
        let mainQueue = NSOperationQueue.mainQueue()
        
        //if already saved retrieve and displa y
        if let photo = NSKeyedUnarchiver.unarchiveObjectWithFile(setImagePath((imgURL?.lastPathComponent)!)) as? UIImage {
            cell.actInd.stopAnimating()
            cell.flickPIcs.image = photo
        }
        else {
       
         NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                // Convert the downloaded data in to a UIImage object
                var fotpath = self.setImagePath(imgURL!.lastPathComponent!)
                let image = UIImage(data: data!)
                //NSKeyedArchiver.archiveRootObject(image!,toFile: fotpath)
                print ("the saved data is\(imgURL?.lastPathComponent)")
                
                //save photo in core data
                let appDelegate =
                UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                let savedfoto = Photos(photoTitle: titlephoto, urlpath: fotpath, context: managedContext)
                savedfoto.photo = curPin
                
                //save file
                    NSKeyedArchiver.archiveRootObject(image!,toFile: self.setImagePath(imgURL!.lastPathComponent!))
                
                print ("the current photos pins latitude  is \(savedfoto.photo?.latitude!)")
                do {
                    try managedContext.save()
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }

                cell.flickPIcs.image = image
                completionHandler(success: true, errorString: nil)
            }
            else {
                completionHandler(success: false, errorString: "Could not download image \(imagePath)")
            }
           })
      }
    }
    
    func deleteItems(){
        //save photo in core data
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let mc = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Photos")
        var fotos  = [Photos]()
        do {
            fotos =
                try mc.executeFetchRequest(fetchRequest) as! [Photos]
            for foto in fotos {
                if foto.photo!.latitude == self.lat && foto.photo!.longitude == self.long {
                    //delete  files first
                    do {
                        try NSFileManager.defaultManager().removeItemAtPath(foto.path!)
                    }
                    catch let e as NSError {
                        print(e)
                    }
                    // proceed to delete from core data
                    mc.deleteObject(foto)
                }
            }
        
            appDelegate.saveContext()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        print ("the array from core data size is \(fotos.count)")
    }
    
} // end of class VTapi
