import UIKit

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: GMSMapView!
    /// current location
    var location: CLLocation?
    var neighbors: [User: GMSMarker] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        
        Socket.onReceiveLocation = {userID, latitude, longitude in
            let neighbor = User(id: userID)
            neighbor.name = userID.substringToIndex(userID.startIndex.advancedBy(6)) // TODO
            dispatch_async(dispatch_get_main_queue()) {
                let position = CLLocationCoordinate2DMake(latitude, longitude)
                if let marker = self.neighbors[neighbor] {
                    marker.position = position
                } else {
                    let marker = GMSMarker(position: position)
                    marker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
                    marker.userData = NSKeyedArchiver.archivedDataWithRootObject(neighbor)
                    marker.map = self.mapView
                    
                    self.neighbors[neighbor] = marker
                }
            }
        }
        Socket.getCurrentLocation = {() in
            return self.location
        }
    }

    // CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.distanceFilter = 10 // meters
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    // CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            if let oldLocation = self.location {
                if newLocation.coordinate.longitude == oldLocation.coordinate.longitude && newLocation.coordinate.latitude == oldLocation.coordinate.latitude {
                    return
                }
            } else {
                mapView.camera = GMSCameraPosition.cameraWithTarget(newLocation.coordinate, zoom: 16)
                mapView.animateToLocation(newLocation.coordinate)
            }
            self.location = newLocation
            Socket.updateLocation()
        }
    }
    
    // GMSMapViewDelegate
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
    }
    
    // GMSMapViewDelegate
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        self.performSegueWithIdentifier("showMessageTable", sender: marker)
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? MessageTableViewController {
            if let marker = sender as? GMSMarker {
                if let userData = marker.userData as? NSData {
                    if let neighbor = NSKeyedUnarchiver.unarchiveObjectWithData(userData) as? User {
                        controller.neighbor = neighbor
                    }
                }
            }
        }
    }
}
