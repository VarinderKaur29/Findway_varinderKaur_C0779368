//
//  ViewController.swift
//  FindWay_VarinderKaur_C0779368
//
//  Created by user175478 on 6/13/20.
//  Copyright © 2020 user175478. All rights reserved.
//


//--------------------------------------------
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController ,UIGestureRecognizerDelegate,CLLocationManagerDelegate{
    @IBOutlet var mapView: MKMapView?
    
    let locationManager = CLLocationManager()
    var destination: CLLocationCoordinate2D!

    let places = Coordinates.getPlaces()
    
    @IBAction func currentLocation(_ sender: Any) {
        
        locationManager.startUpdatingLocation()
        //drawline()
        
    }
    override func viewDidLoad() {
        
          
       let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        gestureRecognizer.delegate = self
        mapView!.addGestureRecognizer(gestureRecognizer)
        requestLocationAccess()
        addAnnotations()
        addPolyline()
        
        
        mapView!.delegate = self
        
//        this line is equivalent to the user location check box in map view
//        map.showsUserLocation = true
        
        locationManager.delegate = self
        

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // request the user for the location access
        locationManager.requestWhenInUseAuthorization()
        
        // start updating the location of the user
        locationManager.startUpdatingLocation()
 
    }
    
    func requestLocationAccess() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
            
        case .authorizedAlways, .authorizedWhenInUse:
            return
            
        case .denied, .restricted:
            print("location access denied")
            
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func drawline(){
        mapView!.removeOverlays(mapView!.overlays)
        
        let sourcePlaceMark = MKPlacemark(coordinate: locationManager.location!.coordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        
    
        let directionRequest = MKDirections.Request()
        

        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        // transportation type
        directionRequest.transportType = .walking
        
        // calculate directions
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            // create route
            let route = directionResponse.routes[0]
            // draw the polyline
            self.mapView!.addOverlay(route.polyline, level: .aboveRoads)
            
            // defining the bounding map rect
            let rect = route.polyline.boundingMapRect
//            self.map.setRegion(MKCoordinateRegion(rect), animated: true)
            self.mapView!.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
        }
    }
    
 func addAnnotations() {
        mapView?.delegate = self
        mapView?.addAnnotations(places)

    let overlays = places.map { MKCircle(center: $0.coordinate, radius: 100)}
    
        mapView?.addOverlays(overlays)
    
    }
 
    func addPolyline() {
        var locations = places.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: &locations, count: locations.count)
        
        mapView?.addOverlay(polyline)
    }
        
    //
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView!.convert(location, toCoordinateFrom: mapView)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView!.addAnnotation(annotation)
        print(coordinate)
     
    }
        //MARK: - didupdatelocation method
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Access the last object from locations to get perfect current location
        if let location = locations.last {
            let span = MKCoordinateSpan(latitudeDelta: 0.00775, longitudeDelta: 0.00775)
            let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
            print(myLocation)
            let region = MKCoordinateRegion(center: myLocation, span: span)
            mapView!.setRegion(region, animated: true)
        }
        self.mapView!.showsUserLocation = true
        manager.stopUpdatingLocation()
    }
   
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
            
        else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(named: "place icon")
            //annotationView.image = #imageLiteral(resourceName: "place icon")
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView.canShowCallout = true
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 3
            return renderer
        
        }
        
        return MKOverlayRenderer()
    }
    
    //Dialog box
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? Coordinates, let title = annotation.title else { return }
        
        let alertController = UIAlertController(title: "Welcome to \(title)", message: "You've selected \(title)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

