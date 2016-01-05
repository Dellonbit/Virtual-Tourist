//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by arianne on 2015-06-10.
//  Copyright (c) 2015 della. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TouristMapViewController: UIViewController, MKMapViewDelegate {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var lat: CLLocationDegrees!
    var long: CLLocationDegrees!
    var wait: UIActivityIndicatorView!
    var cdArray =  [Photos]()
    var curPin : Pin!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var subViewOutlet: UIView!
    var editPress: Bool = false
    var y :CGFloat = 0.0
    var x :CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let editBtn = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self,action: Selector("editBtnPressed"))
        navigationItem.rightBarButtonItem = editBtn
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecogniser.minimumPressDuration = 1.0
        longPressRecogniser.numberOfTouchesRequired = 1
        
        //activity indicator params
        let width: CGFloat = 200.0
        let height: CGFloat = 50.0
         x = self.view.frame.width/2.0 - width/2.0
         y = self.view.frame.height/2.0 - height/2.0
        
        mapView.addGestureRecognizer(longPressRecogniser)
        mapView.delegate = self
    }
    
    // func check and load pins if any
    func loadPins() {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        var locations  = [Pin]()
        do {
            locations =
                try managedContext.executeFetchRequest(fetchRequest) as! [Pin]
            mapView.removeAnnotations(mapView.annotations)
            for it in locations {
                //print (it.latitude!)
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = Double(it.latitude!)
                annotation.coordinate.longitude = Double(it.longitude!)
                mapView.addAnnotation(annotation)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        //empty arry plot// remember to clear map first before ploting any data
        locations = []
    }
    
    func deletePin (lat: Double, long: Double) {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        let fetchRequest2 = NSFetchRequest(entityName: "Photos")
        var locations  = [Pin]()
        var phots = [Photos]()
        do {
            locations =
                try managedContext.executeFetchRequest(fetchRequest) as! [Pin]
            phots = try managedContext.executeFetchRequest(fetchRequest2) as! [Photos]
            for it in locations {
                if it.latitude == lat && it.longitude == long{
                    for foto in phots {
                        if foto.photo!.latitude == it.latitude && foto.photo!.longitude == it.longitude {
                            //delete  file first
                            do {
                                try NSFileManager.defaultManager().removeItemAtPath(foto.path!)
                            }
                            catch let e as NSError {
                                print(e)
                            }
                            // now remove from core data
                            managedContext.deleteObject(foto)
                            appDelegate.saveContext()
                        }
                    }
                    //remove pin
                    managedContext.deleteObject(it)
                    appDelegate.saveContext()
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
      }
    }
    
    override func viewWillAppear(animated: Bool) {
        print("loading map here!!!")
        loadPins()
        //zero the array
        cdArray.removeAll()
        VTConvenience.sharedInstance().urlPhotos.removeAll()
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
    {
        //save pressed in coordinate for global use
        VTConvenience.sharedInstance().lat = view.annotation!.coordinate.latitude
        VTConvenience.sharedInstance().long = view.annotation!.coordinate.longitude
        
        if (editPress == true){
        mapView.removeAnnotation(view.annotation!)
        deletePin (VTConvenience.sharedInstance().lat, long: VTConvenience.sharedInstance().long)
        
        print(VTConvenience.sharedInstance().lat)
        }
        else {
            if Reachability.isConnectedToNetwork() == true {
                print("Internet connection OK")
                //create uiview
                let viewArea = UIView(frame: CGRect(x: x, y: y, width: 200, height: 50))
                viewArea.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
                viewArea.layer.cornerRadius = 10
                
                //create label
                wait = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                wait.color = UIColor.blackColor()
                wait.hidesWhenStopped = true
                var text = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
                text.text = "Processing..."
                
                //add acctivity indicator and lable to same view
                viewArea.addSubview(wait)
                viewArea.addSubview(text)
                
                //add to main view
                self.view.addSubview(viewArea)
                wait.startAnimating()
                
                //let appDelegate =
              //  UIApplication.sharedApplication().delegate as! AppDelegate
                
                let vc = storyboard!.instantiateViewControllerWithIdentifier("picsView") as! PicsViewController
                //makesure array is empty before posting
                //vc.cdArry.removeAll()
            
                let appDelegate =
                UIApplication.sharedApplication().delegate as! AppDelegate
                let mc = appDelegate.managedObjectContext
                let fetchRequest = NSFetchRequest(entityName: "Photos")
                var fotos  = [Photos]()
                do {
                    fotos =
                        try mc.executeFetchRequest(fetchRequest) as! [Photos]
                            appDelegate.saveContext()
                    VTConvenience.sharedInstance().urlPhotos.removeAll()
                    for foto in fotos {
                        if foto.photo!.latitude == VTConvenience.sharedInstance().lat && foto.photo!.longitude == VTConvenience.sharedInstance().long{
                            VTConvenience.sharedInstance().urlPhotos.append(foto.path!)
                        }
                    }
                    //print ("here are the locations \()")
        
                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }
                if VTConvenience.sharedInstance().urlPhotos.count>0 {
                    self.wait.stopAnimating()
                    dispatch_async(dispatch_get_main_queue(), {
                        viewArea.removeFromSuperview()
                        self.performSegueWithIdentifier("pushtoPics", sender: self)
                    })
                    viewArea.removeFromSuperview()
                    print ("the array size is \(VTConvenience.sharedInstance().urlPhotos.count)")
                }
                else {
                 dispatch_async(dispatch_get_main_queue(), {
                    VTConvenience.sharedInstance().searchPhotosByLatLon(VTConvenience.sharedInstance().lat, long: VTConvenience.sharedInstance().long, completion: { (success, error) -> Void in
                        if success {
                            print ("image successfully downloaded")
                            self.wait.stopAnimating()
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                viewArea.removeFromSuperview()
                                self.performSegueWithIdentifier("pushtoPics", sender: self)
                            })
                        }
                        else {
                            self.wait.stopAnimating()
                            viewArea.removeFromSuperview()
                            print( error)
                        }
                    })
                    
                })
              }
            } else {
                var msg = "Internet connection FAILED"
                showMsg(msg)
            }
        }
    }
    
    func handleLongPress(getstureRecognizer : UIGestureRecognizer){
        if getstureRecognizer.state != .Began { return }
        
        let touchPoint = getstureRecognizer.locationInView(self.mapView)
        let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        lat = touchMapCoordinate.latitude
        long = touchMapCoordinate.longitude
        
        VTConvenience.sharedInstance().lat = lat
        VTConvenience.sharedInstance().long = long
    
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        mapView.addAnnotation(annotation)
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        var savedPin = Pin(lat: lat, long: long, context: managedContext)
        print (savedPin.magic)
        do {
                try managedContext.save()
               } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
    }
    
    func mapView(mapView: MKMapView,
        viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation{
                return nil
            }
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            
            if(pinView == nil){
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.animatesDrop = true
                pinView!.draggable = true
                pinView!.pinColor = .Red
                
                let calloutButton = UIButton(type: .DetailDisclosure)
                pinView!.rightCalloutAccessoryView = calloutButton
            } else {
                pinView!.annotation = annotation
            }
            return pinView!
    }
    
    func editBtnPressed (){
        if (editPress == false){
            editPress = true
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                self.mapView.frame.origin.y = -self.subViewOutlet.frame.height
                }, completion: { _ in })
            navigationItem.rightBarButtonItem?.title = "done"
          }
        else if (editPress == true) {
            editPress = false
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                self.mapView.frame.origin.y = 0.0
                }, completion: { _ in})
            navigationItem.rightBarButtonItem?.title = "edit"
        }
    }
    
    func showMsg(msg:String) {
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
      }
}

