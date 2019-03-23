//
//  CustomerListViewController.swift
//  CustomerList
//
//  Created by Bharat Mahajan on 22/03/19.
//  Copyright © 2019 BharatMahajan. All rights reserved.
//

import UIKit
import CoreLocation

class CustomerListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - Variables

    @IBOutlet weak var tblCustomerList: UITableView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblNoList: UILabel!
    @IBOutlet weak var btnSort: UIButton!
    @IBOutlet weak var lblSort: UILabel!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var lblFilter: UILabel!
    var userPosition:CLLocationCoordinate2D = CLLocationCoordinate2D.init()
    var dictCustomers:NSMutableArray!
    var dictFilteredCustomers:NSMutableArray!
    var isFilter = false
    var sortAscending = true
    var sortType = -1
    private let refreshControl = UIRefreshControl()
    var commonFunctions:CommonFunctions!
    
    // MARK: - View Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        dictCustomers = NSMutableArray.init()
        dictFilteredCustomers = NSMutableArray.init()
        
        let cellCustomerList = UINib(nibName: Constants.identifierCustomerListTableViewCell, bundle: nil)
        self.tblCustomerList.register(cellCustomerList, forCellReuseIdentifier: Constants.identifierCustomerListTableViewCell)
        self.tblCustomerList.tableFooterView = UIView.init(frame: CGRect.zero)
        self.tblCustomerList.refreshControl = refreshControl
        refreshControl.tintColor = Constants.baseColor
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Customer List ...")
        refreshControl.addTarget(self, action: #selector(refreshCustomerList(_:)), for: .valueChanged)
        self.lblNoList.isHidden = true
        activityIndicator.hidesWhenStopped = true
        commonFunctions = CommonFunctions.sharedInstance
        fetchCustomerList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Fetch List

    
    @objc private func refreshCustomerList(_ sender: Any) {
        fetchCustomerList()
    }

    func fetchCustomerList()
    {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        let url = URL(string:Constants.baseUrl)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil
            {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.lblNoList.text = Constants.textListUnableFetch
                    self.lblNoList.isHidden = false
                    self.tblCustomerList.isHidden = true
                    self.viewBottom.isHidden = true
                }
            }
            do
            {
                if data != nil
                {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                        self.dictCustomers = self.commonFunctions.parseDataToArrayUsing(data: data!)
                        self.lblNoList.isHidden = true
                        self.tblCustomerList.isHidden = false
                        self.viewBottom.isHidden = false
                        self.tblCustomerList.reloadData()
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.refreshControl.endRefreshing()
                        self.lblNoList.text = Constants.textListEmpty
                        self.lblNoList.isHidden = false
                        self.tblCustomerList.isHidden = true
                        self.viewBottom.isHidden = true
                    }
                }
            }
        }
        task.resume()
    }
    
    // MARK: - TableView Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilter
        {
            return dictFilteredCustomers.count
        }
        else
        {
            return dictCustomers.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifierCustomerListTableViewCell, for: indexPath) as! CustomerListTableViewCell
        cell.selectionStyle = .none
        
        cell.viewContent.layer.shadowColor = UIColor.darkGray.cgColor
        cell.viewContent.layer.shadowOffset = CGSize.init(width: 0.8, height: 0.8)
        cell.viewContent.layer.shadowOpacity = 0.80
        cell.viewContent.layer.shadowRadius = 1

        let myDict:NSDictionary!
        if isFilter
        {
            myDict = dictFilteredCustomers[indexPath.row] as! NSDictionary
        }
        else
        {
            myDict = dictCustomers[indexPath.row] as! NSDictionary
        }
        cell.lblUserId.text = String(format: "%d",(myDict[Constants.detailCustomerUserId] as? NSInteger)!)
        cell.lblUserName.text = myDict[Constants.detailCustomerName] as? String
        cell.btnUserLocation.tag = indexPath.row
        cell.btnUserLocation.addTarget(self, action: #selector(showUserLocation(sender:)), for: .touchUpInside)
        let newLatitude = Double(myDict[Constants.detailCustomerLatitude] as! String)
        let newLongitude = Double(myDict[Constants.detailCustomerLongitude] as! String)
        let newLocation = CLLocationCoordinate2D.init(latitude: newLatitude!, longitude:newLongitude!)
        cell.lblDistance.text = String(format: "%.2lf km", commonFunctions.distanceInMtrsBetweenPointsUsingGreatCircleDistance(fromLocation: Constants.baseLocation, toLocation: newLocation)/1000)
        return cell
    }
    
    // MARK: - User Location

    @objc func showUserLocation(sender:UIButton)
    {
        var myDict:NSDictionary!
        if isFilter
        {
            myDict = self.dictFilteredCustomers[sender.tag] as! NSDictionary
        }
        else
        {
            myDict = self.dictCustomers[sender.tag] as! NSDictionary
        }
        
        let newLatitude = Double(myDict[Constants.detailCustomerLatitude] as! String)
        let newLongitude = Double(myDict[Constants.detailCustomerLongitude] as! String)
        userPosition.latitude = newLatitude!
        userPosition.longitude = newLongitude!
        showMapView()
    }
    
    func showMapView() {
        performSegue(withIdentifier: Constants.segueIdnavToCustomerMapLocation, sender: nil)
    }
    
    // MARK: - Sort List

    @IBAction func sortList(_ sender: UIButton) {
        let sortActionSheet = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        
        let actionNameAsc = UIAlertAction(title: "UserId ascending", style: .default) { (action:UIAlertAction) in
            if self.isFilter
            {
                self.dictFilteredCustomers = self.commonFunctions.sortArrayBy(type: 0, arrToSort: self.dictFilteredCustomers, isAscending: true)
            }
            else
            {
                self.dictCustomers = self.commonFunctions.sortArrayBy(type: 0, arrToSort: self.dictCustomers, isAscending: true)
            }
            self.lblSort.text = "UserId asc"
            self.sortAscending = true
            self.sortType = 0
            self.tblCustomerList.reloadData()
        }
        let actionNameDesc = UIAlertAction(title: "UserId descending", style: .default) { (action:UIAlertAction) in
            if self.isFilter
            {
                self.dictFilteredCustomers = self.commonFunctions.sortArrayBy(type: 0, arrToSort: self.dictFilteredCustomers, isAscending: false)
            }
            else
            {
                self.dictCustomers = self.commonFunctions.sortArrayBy(type: 0, arrToSort: self.dictCustomers, isAscending: false)
            }
            self.lblSort.text = "UserId desc"
            self.sortAscending = false
            self.sortType = 0
            self.tblCustomerList.reloadData()
        }
        let actionAgeAsc = UIAlertAction(title: "Name ascending", style: .default) { (action:UIAlertAction) in
            if self.isFilter
            {
                self.dictFilteredCustomers = self.commonFunctions.sortArrayBy(type: 1, arrToSort: self.dictFilteredCustomers, isAscending: true)
            }
            else
            {
                self.dictCustomers = self.commonFunctions.sortArrayBy(type: 1, arrToSort: self.dictCustomers, isAscending: true)
            }
            self.lblSort.text = "Name asc"
            self.sortAscending = true
            self.sortType = 1
            self.tblCustomerList.reloadData()
        }
        let actionAgeDesc = UIAlertAction(title: "Name descending", style: .default) { (action:UIAlertAction) in
            if self.isFilter
            {
                self.dictFilteredCustomers = self.commonFunctions.sortArrayBy(type: 1, arrToSort: self.dictFilteredCustomers, isAscending: false)
            }
            else
            {
                self.dictCustomers = self.commonFunctions.sortArrayBy(type: 1, arrToSort: self.dictCustomers, isAscending: false)
            }
            self.lblSort.text = "Name desc"
            self.sortAscending = false
            self.sortType = 1
            self.tblCustomerList.reloadData()
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            sortActionSheet.dismiss(animated: true, completion: nil)
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        sortActionSheet.addAction(actionNameAsc)
        sortActionSheet.addAction(actionNameDesc)
        sortActionSheet.addAction(actionAgeAsc)
        sortActionSheet.addAction(actionAgeDesc)
        sortActionSheet.addAction(actionCancel)
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            sortActionSheet.popoverPresentationController?.sourceView = sender.imageView
        }
        self.present(sortActionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Filter List

    @IBAction func filterList(_ sender: UIButton) {
        let filterActionSheet = UIAlertController(title: "Filter by", message: nil, preferredStyle: .actionSheet)
        let actionAll = UIAlertAction(title: "All", style: .default) { (action:UIAlertAction) in
            self.isFilter = false
            self.dictFilteredCustomers.removeAllObjects()
            if self.dictCustomers.count == 0
            {
                self.lblNoList.text = Constants.textListEmpty
                self.lblNoList.isHidden = false
                self.tblCustomerList.isHidden = true
            }
            else
            {
                self.tblCustomerList.isHidden = false
                self.lblNoList.isHidden = true
            }
            
            self.lblFilter.text = "All"
            if self.sortType != -1
            {
                self.dictCustomers = self.commonFunctions.sortArrayBy(type: self.sortType, arrToSort: self.dictCustomers, isAscending: self.sortAscending)
            }
            self.tblCustomerList.reloadData()
        }
        let actionLessThanTen = UIAlertAction(title: "<10 km", style: .default) { (action:UIAlertAction) in
            self.isFilter = true
            self.dictFilteredCustomers.removeAllObjects()
            self.dictFilteredCustomers = self.commonFunctions.filterUsersBy(distance: 10, baseLocation: Constants.baseLocation, allUsers: self.dictCustomers,isInclusive: true)
            if self.dictFilteredCustomers.count == 0
            {
                self.lblNoList.text = Constants.textListEmpty
                self.lblNoList.isHidden = false
                self.tblCustomerList.isHidden = true
            }
            else
            {
                self.lblNoList.isHidden = true
                self.tblCustomerList.isHidden = false
            }
            self.lblFilter.text = "<10 km"
            if self.sortType != -1
            {
                self.dictFilteredCustomers = self.commonFunctions.sortArrayBy(type: self.sortType, arrToSort: self.dictFilteredCustomers, isAscending: self.sortAscending)
            }
            self.tblCustomerList.reloadData()
        }
        let actionLessThanFifty = UIAlertAction(title: "<50 km", style: .default) { (action:UIAlertAction) in
            self.isFilter = true
            self.dictFilteredCustomers.removeAllObjects()
            self.dictFilteredCustomers = self.commonFunctions.filterUsersBy(distance: 50, baseLocation: Constants.baseLocation, allUsers: self.dictCustomers,isInclusive: true)
            if self.dictFilteredCustomers.count == 0
            {
                self.lblNoList.text = Constants.textListEmpty
                self.lblNoList.isHidden = false
                self.tblCustomerList.isHidden = true
            }
            else
            {
                self.lblNoList.isHidden = true
                self.tblCustomerList.isHidden = false
            }
            self.lblFilter.text = "<50 km"
            if self.sortType != -1
            {
                self.dictFilteredCustomers = self.commonFunctions.sortArrayBy(type: self.sortType, arrToSort: self.dictFilteredCustomers, isAscending: self.sortAscending)
            }
            self.tblCustomerList.reloadData()
        }
        let actionLessThanHundred = UIAlertAction(title: "<100 km", style: .default) { (action:UIAlertAction) in
            self.isFilter = true
            self.dictFilteredCustomers.removeAllObjects()
            self.dictFilteredCustomers = self.commonFunctions.filterUsersBy(distance: 100, baseLocation: Constants.baseLocation, allUsers: self.dictCustomers,isInclusive: true)
            if self.dictFilteredCustomers.count == 0
            {
                self.lblNoList.text = Constants.textListEmpty
                self.lblNoList.isHidden = false
                self.tblCustomerList.isHidden = true
            }
            else
            {
                self.lblNoList.isHidden = true
                self.tblCustomerList.isHidden = false
            }
            self.lblFilter.text = "<100 km"
            if self.sortType != -1
            {
                self.dictFilteredCustomers = self.commonFunctions.sortArrayBy(type: self.sortType, arrToSort: self.dictFilteredCustomers, isAscending: self.sortAscending)
            }
            self.tblCustomerList.reloadData()
        }
        let actionMoreThanHundred = UIAlertAction(title: ">100 km", style: .default) { (action:UIAlertAction) in
            self.isFilter = true
            self.dictFilteredCustomers.removeAllObjects()
            self.dictFilteredCustomers = self.commonFunctions.filterUsersBy(distance: 100, baseLocation: Constants.baseLocation, allUsers: self.dictCustomers,isInclusive: false)
            if self.dictFilteredCustomers.count == 0
            {
                self.lblNoList.text = Constants.textListEmpty
                self.lblNoList.isHidden = false
                self.tblCustomerList.isHidden = true
            }
            else
            {
                self.lblNoList.isHidden = true
                self.tblCustomerList.isHidden = false
            }
            self.lblFilter.text = ">100 km"
            if self.sortType != -1
            {
                self.dictFilteredCustomers = self.commonFunctions.sortArrayBy(type: self.sortType, arrToSort: self.dictFilteredCustomers, isAscending: self.sortAscending)
            }
            self.tblCustomerList.reloadData()
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            filterActionSheet.dismiss(animated: true, completion: nil)
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        filterActionSheet.addAction(actionAll)
        filterActionSheet.addAction(actionLessThanTen)
        filterActionSheet.addAction(actionLessThanFifty)
        filterActionSheet.addAction(actionLessThanHundred)
        filterActionSheet.addAction(actionMoreThanHundred)
        filterActionSheet.addAction(actionCancel)
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            filterActionSheet.popoverPresentationController?.sourceView = sender.imageView
        }
        self.present(filterActionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueIdnavToCustomerMapLocation
        {
            if let destinationVC = segue.destination as? CustomerMapsViewController {
                destinationVC.userPosition = userPosition
            }
        }
    }
    
    // MARK: - 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
