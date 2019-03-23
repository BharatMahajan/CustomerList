//
//  CommonFunctions.swift
//  CustomerList
//
//  Created by Bharat Mahajan on 23/03/19.
//  Copyright © 2019 BharatMahajan. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

public class CommonFunctions
{
    // MARK: - Variable
    static let sharedInstance = CommonFunctions()

    // MARK: - Filter customers by distance
    @objc func filterUsersBy(distance:Double,baseLocation:CLLocationCoordinate2D,allUsers:NSMutableArray,isInclusive:Bool) -> NSMutableArray
    {
        let arrFiltered:NSMutableArray = NSMutableArray.init()
        for dict in allUsers
        {
            let myDict = dict as! NSDictionary
            let newLatitude = Double(myDict[Constants.detailCustomerLatitude] as! String)
            let newLongitude = Double(myDict[Constants.detailCustomerLongitude] as! String)
            let newLocation = CLLocationCoordinate2D.init(latitude: newLatitude!, longitude:newLongitude!)
            let userDistanceFromBase = self.distanceInMtrsBetweenPointsUsingGreatCircleDistance(fromLocation: baseLocation, toLocation: newLocation)
            if isInclusive
            {
                if userDistanceFromBase < distance * 1000
                {
                    arrFiltered.add(myDict)
                }
            }
            else
            {
                if userDistanceFromBase >= distance * 1000
                {
                    arrFiltered.add(myDict)
                }
            }
        }
        return arrFiltered
    }
    
    // MARK: - Parse data from txt file
@objc func parseDataToArrayUsing(data:Data) -> NSMutableArray
    {
        let arrUsers:NSMutableArray = NSMutableArray.init()
        let string = String(data: data, encoding: String.Encoding.utf8)
        let myStrings = string?.components(separatedBy: .newlines)
        for eachString in myStrings!
        {
            let dict = try! JSONSerialization.jsonObject(with:eachString.data(using: .utf8)!, options: []) as! NSDictionary
            arrUsers.add(dict)
        }
        return arrUsers
    }
    
    // MARK: - Sort custome list
 @objc func sortArrayBy(type:Int,arrToSort:NSMutableArray,isAscending:Bool) -> NSMutableArray
    {
        var strType = ""
        
        arrToSort.sort(comparator: { (dict1, dict2) -> ComparisonResult in
            let myDict1 = dict1 as! NSDictionary
            let myDict2 = dict2 as! NSDictionary
            if type == 0
            {
                strType = Constants.detailCustomerUserId
                if (myDict1[strType] as! NSInteger) < (myDict2[strType] as! NSInteger)
                {
                    if isAscending
                    {
                        return ComparisonResult.orderedAscending
                    }
                    else
                    {
                        return ComparisonResult.orderedDescending
                    }
                }
                else if (myDict1[strType] as! NSInteger) > (myDict2[strType] as! NSInteger)
                {
                    if isAscending
                    {
                        return ComparisonResult.orderedDescending
                    }
                    else
                    {
                        return ComparisonResult.orderedAscending
                    }
                }
                else
                {
                    return ComparisonResult.orderedSame
                }
            }
            else
            {
                strType = Constants.detailCustomerName
                if (myDict1[strType] as! String) < (myDict2[strType] as! String)
                {
                    if isAscending
                    {
                        return ComparisonResult.orderedAscending
                    }
                    else
                    {
                        return ComparisonResult.orderedDescending
                    }
                }
                else if (myDict1[strType] as! String) > (myDict2[strType] as! String)
                {
                    if isAscending
                    {
                        return ComparisonResult.orderedDescending
                    }
                    else
                    {
                        return ComparisonResult.orderedAscending
                    }
                }
                else
                {
                    return ComparisonResult.orderedSame
                }
            }
        })
        return arrToSort
    }
    
    // MARK: - Calculate Distance 
 //calculate distance between two locations using great circle distance by chord length - https://en.wikipedia.org/wiki/Great-circle_distance
    @objc func distanceInMtrsBetweenPointsUsingGreatCircleDistance(fromLocation:CLLocationCoordinate2D, toLocation:CLLocationCoordinate2D) -> Double
    {
        let minLatitude = fromLocation.latitude*Constants.degToRad
        let maxLatitude = toLocation.latitude*Constants.degToRad
        let minLongitude = fromLocation.longitude*Constants.degToRad
        let maxLongitude = toLocation.longitude*Constants.degToRad
        
        let deltaX = (cos(maxLatitude) * cos(maxLongitude)) - (cos(minLatitude) * cos(minLongitude))
        let deltaY = (cos(maxLatitude) * sin(maxLongitude)) - (cos(minLatitude) * sin(minLongitude))
        let deltaZ = sin(maxLatitude) - sin(minLatitude)
        
        let deltaC = sqrt((deltaX*deltaX) + (deltaY*deltaY) + (deltaZ*deltaZ))
        let deltaAngle = 2*asin(deltaC/2)
        
        return Constants.earrthRadiusInMtrs*deltaAngle //in meters
    }
}
