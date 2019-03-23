//
//  CustomerMapsViewController.swift
//  CustomerList
//
//  Created by Bharat Mahajan on 22/03/19.
//  Copyright © 2019 BharatMahajan. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class CustomerMapsViewController: UIViewController,MKMapViewDelegate {
    
    // MARK: - Variables
    @IBOutlet weak var mapView: MKMapView!
    var userPosition:CLLocationCoordinate2D = CLLocationCoordinate2D.init()
    
    // MARK: - View Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        mapView.mapType = .standard
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.setCenter(Constants.baseLocation, animated: true)
        //base location
        let baseAnnotation: MKPointAnnotation = MKPointAnnotation()
        baseAnnotation.coordinate = CLLocationCoordinate2DMake(Constants.baseLocation.latitude, Constants.baseLocation.longitude)
        baseAnnotation.title = Constants.textBaseLocation
        mapView.addAnnotation(baseAnnotation)
        //user location
        let userAnnotation: MKPointAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = CLLocationCoordinate2DMake(userPosition.latitude, userPosition.longitude)
        userAnnotation.title = Constants.textUserLocation
        mapView.addAnnotation(userAnnotation)
        setZoomPosition()
    }
    
    // MARK: - Mapview Delegate Methods

    func setZoomPosition()
    {
        var latitudeDelta = Constants.baseLocation.latitude.magnitude - userPosition.latitude.magnitude
        latitudeDelta = latitudeDelta.magnitude*2.5
        var longitudeDelta = Constants.baseLocation.longitude.magnitude - userPosition.longitude.magnitude
        longitudeDelta = longitudeDelta.magnitude*2.5
        mapView.setRegion(MKCoordinateRegion.init(center: Constants.baseLocation, span: MKCoordinateSpan.init(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)), animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.identifierAnnotation)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.identifierAnnotation)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        if annotation.title == Constants.textBaseLocation
        {
            let pinImage = #imageLiteral(resourceName: "baseLocation")
            annotationView!.image = pinImage
        }
        else
        {
            let pinImage = #imageLiteral(resourceName: "userLocation")
            annotationView!.image = pinImage
        }
        return annotationView
    }
    
    // MARK: - 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
