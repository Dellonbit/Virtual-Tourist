//
//  PicsViewController.swift
//  Virtual Tourist
//
//  Created by arianne on 2015-09-09.
//  Copyright (c) 2015 della. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PicsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {
    var  reuseIdentifier = "picsCell"
    @IBOutlet weak var picMap: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectButton: UIBarButtonItem!
    var y :CGFloat = 0.0
    var x :CGFloat = 0.0
    var delObjcArry = [Photos]()
    var topinn: Pin!
    
    @IBOutlet weak var hidingView: UIView!
    @IBOutlet weak var inforLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //activity indicator params
        let width: CGFloat = self.view.frame.width
        let height: CGFloat = self.view.frame.height
        picMap.delegate = self
        collectionView.allowsMultipleSelection = true
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        VTConvenience.sharedInstance().urlPhotos.removeAll()
    }
    
    override func viewWillAppear(animated: Bool) {
        displayPin()
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let mc = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        var locations  = [Pin]()
        do {
            locations =
                try mc.executeFetchRequest(fetchRequest) as! [Pin]
            for it in locations {
                if it.latitude == VTConvenience.sharedInstance().lat && it.longitude == VTConvenience.sharedInstance().long{
                    topinn = it
                    //print("yes we can topin's lat \(topinn.latitude)")
                }
            }
            appDelegate.saveContext()
            //print ("here are the locations \(locations)")
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        for ele in VTConvenience.sharedInstance().urlPhotos {
            var imgURL = NSURL(string: ele)
                //print ("pcview controller in this pin are \(ele.path!)")
            let photo = NSKeyedUnarchiver.unarchiveObjectWithFile(VTConvenience.sharedInstance().setImagePath((imgURL?.lastPathComponent)!)) as? UIImage
            print("the phot is \(photo)")
        }
    }

    func displayPin () {
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = VTConvenience.sharedInstance().lat
        annotation.coordinate.longitude = VTConvenience.sharedInstance().long
        //picMap.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(2, 2)
        //let coordinates = CLLocationCoordinate2D(latitude: Double(annotation.coor.latitude), longitude: Double(location.longitude))
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        //let annotation = MKPointAnnotation() //We need to create a local variable to not mess up the global
        //let tapPoint:CLLocationCoordinate2D = coordinates
        //annotation.coordinate = tapPoint
        
        picMap.addAnnotation(annotation)
        picMap.setRegion(region, animated: true)
    }
    
    @IBAction func newConnectionButt(sender: AnyObject) {
        if newCollectButton.title == "Remove Selected Pictures" {
            newCollectButton.title = "New Collection"
            let indexpaths = collectionView?.indexPathsForSelectedItems()
            //var deletePhotos = [Photos]()
                //since array has already been modified just reload
                //collection view to show changes
                var deletePhotos = [String]()
                if let indexpaths = indexpaths {
                    for item  in indexpaths {
                        let cell = collectionView!.cellForItemAtIndexPath(item as! NSIndexPath)
                        collectionView?.deselectItemAtIndexPath((item as? NSIndexPath)!, animated: true)
                        //append to deletephotos array
                         deletePhotos.append(VTConvenience.sharedInstance().urlPhotos[item.row])
                    }
                    VTConvenience.sharedInstance().urlPhotos.removeObjectsInArray(deletePhotos)
                    collectionView?.deleteItemsAtIndexPaths(indexpaths)
                    
                    
                    for foto in deletePhotos {
                        var fotourl = NSURL(string: foto)
                        if let photo = NSKeyedUnarchiver.unarchiveObjectWithFile(VTConvenience.sharedInstance().setImagePath((fotourl?.lastPathComponent)!)) as? UIImage {
                            //deletfile here
                            //deletfile here
                            do {
                                try NSFileManager.defaultManager().removeItemAtPath(VTConvenience.sharedInstance().setImagePath((fotourl?.lastPathComponent)!))
                            }
                            catch let e as NSError {
                                print(e)
                            }
                        }
                    }
                    
                    // delete from core data
                    let appDelegate =
                    UIApplication.sharedApplication().delegate as! AppDelegate
                    let managedContext = appDelegate.managedObjectContext
                    let fetchRequest2 = NSFetchRequest(entityName: "Photos")
                    var phots = [Photos]()
                    do {
                        phots = try managedContext.executeFetchRequest(fetchRequest2) as! [Photos]
                        
                        for foto in phots {
                            //delete file first
                            var pathfoto =  NSURL(string: foto.path!)?.lastPathComponent
                            for item in deletePhotos {
                                var itemlc = NSURL(string: item)?.lastPathComponent
                                print ("item in deletePhotos \(itemlc!)")
                            if pathfoto! == itemlc {
                            //delete all phots in core data
                                print ("item deleted here is \(pathfoto!)")
                                managedContext.deleteObject(foto)}
                            }
                        }
                        appDelegate.saveContext()
                    } catch let error as NSError {
                        print("Could not fetch \(error), \(error.userInfo)")
                }
            }
          collectionView.reloadData()
        }
            
        else if newCollectButton.title == "New Collection" {
            if Reachability.isConnectedToNetwork() == true {
                print("Internet connection OK")
                
                //create uiview
                hidingView.hidden = false
                newCollectButton.enabled = false
                //let cell = collectionView!.cellForItemAtIndexPath(item as! NSIndexPath)
                
                // delete from core data and documents directory
                dispatch_async(dispatch_get_main_queue(), {
                    print("#############################################")
                    VTConvenience.sharedInstance().deleteItems()
                })
                
                //delete array
                VTConvenience.sharedInstance().urlPhotos.removeAll()

                collectionView.reloadData()
                
                dispatch_async(dispatch_get_main_queue(), {
                      VTConvenience.sharedInstance().searchPhotosByLatLon(self.topinn.latitude as! Double, long: self.topinn.longitude as! Double, completion: { (success, error) -> Void
                        in
                        if success {
                            if VTConvenience.sharedInstance().urlPhotos.count == 0 {
                                self.hidingView.hidden = true
                                self.inforLab.hidden = false
                                self.inforLab.text = " No images found"
                                self.newCollectButton.enabled = true

                            }else {
                            print("yessssssss")
                            self.collectionView.reloadData()
                            self.hidingView.hidden = true
                                self.newCollectButton.enabled = true}
                            
                        }
                        else {
                             //print error message
                            print(error )
                            self.newCollectButton.enabled = true
                        }
                    })
                })
            } else {
                let msg = "Internet connection FAILED"
                showMsg(msg)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PicsCellCollectionViewCell
        
            cell.actInd.startAnimating()
            cell.flickPIcs.image = UIImage(named: "placeholder")
        
           VTConvenience.sharedInstance().downloadImageAndSetCell(VTConvenience.sharedInstance().urlPhotos [indexPath.row], titlephoto: "photo", curPin: topinn, cell: cell,completionHandler: { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    cell.actInd.stopAnimating()
                    
                })
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    cell.actInd.stopAnimating()
                })
            }
          })
        
    
       return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     return VTConvenience.sharedInstance().urlPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
            return CGFloat(1.0)
    }
    
    //Distance between cells in a row
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(1.0)
    }
    
    //cell border
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 2.0, left: 5.0, bottom: 2.0, right: 5.0)
    }

    // deselecting cells
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        //highlightCell(indexPath, flag: false)
//        var cell = collectionView.cellForItemAtIndexPath(indexPath)
//        //change title back if all cells are deselected
//        cell!.layer.borderWidth = 0.0
        let indexpaths = collectionView.indexPathsForSelectedItems()
        if indexpaths!.count == 0 {
           newCollectButton.title = "New Collection"
        }
    }
    
    // selecting cells for deletion
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath){
        //change title for uibarbutton item
        newCollectButton.title = "Remove Selected Pictures"
    }
    
//display messages
    func showMsg(msg:String) {
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
