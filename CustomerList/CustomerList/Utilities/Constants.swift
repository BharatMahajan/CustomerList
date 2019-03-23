//
//  Constants.swift
//  CustomerList
//
//  Created by Bharat Mahajan on 22/03/19.
//  Copyright © 2019 BharatMahajan. All rights reserved.
//
import UIKit
import Foundation
import CoreLocation

struct Constants
{
    // MARK: - Tableviewcell Ids
    static let identifierCustomerListTableViewCell = "CustomerListTableViewCell"

    // MARK: - ViewController Ids
    static let identifierHomeViewController = "HomeViewController"
    static let identifierCustomerListViewController = "CustomerListViewController"
    static let identifierCustomerMapsViewController = "CustomerMapsViewController"

    // MARK: - Segue Ids
    static let segueIdnavToCustomerMapLocation = "navToCustomerMapLocation"
    
    // MARK: - Download URL
    static let baseUrl = "https://s3.amazonaws.com/intercom-take-home-test/customers.txt"
    
    // MARK: - Distance Calculator
    static let earrthRadiusInMtrs = 6371088.0
    static let degToRad = Double.pi/180
    static let baseLocation = CLLocationCoordinate2D.init(latitude: 53.339428, longitude: -6.257664) //Dublin office
        
    // MARK: - Customer Details
    static let detailCustomerUserId = "user_id"
    static let detailCustomerName = "name"
    static let detailCustomerLatitude = "latitude"
    static let detailCustomerLongitude = "longitude"
    
    // MARK: - Alerts
    static let textListEmpty = "List is empty"
    static let textListUnableFetch = "Unable to fetch customer list"
    
    // MARK: - Color
    static let baseColor = UIColor(red:62/255, green:135/255, blue:215/255, alpha:1.0)
    
    // MARK: - Map
    static let textBaseLocation = "Base Location"
    static let textUserLocation = "User Location"
    static let identifierAnnotation = "identifierAnnotation"
}
