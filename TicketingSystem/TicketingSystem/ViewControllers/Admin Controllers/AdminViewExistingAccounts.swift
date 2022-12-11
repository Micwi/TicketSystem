//
//  AdminViewExistingAccounts.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 12/9/22.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class AdminViewExistingAccounts: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    private let database = Firestore.firestore()
    
    @IBOutlet weak var ViewExistingAccountsTableView: UITableView!
    
    @IBOutlet weak var totalNumberOfAccountsLabel: UILabel!
    
    var userExistingAccounts = [ExistingAccountInfo]()
    var employeeExistingAccounts = [ExistingAccountInfo]()
    var adminExistingAccounts = [ExistingAccountInfo]()
    var totalNumberOfAccounts = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewExistingAccountsTableView.delegate = self
        ViewExistingAccountsTableView.dataSource = self
    }
    override func viewDidAppear(_ animated: Bool) {
        grabAccountsInfo()
        ViewExistingAccountsTableView.reloadData()
    }
    
    func grabAccountsInfo(){
        userExistingAccounts = [ExistingAccountInfo]()
        employeeExistingAccounts = [ExistingAccountInfo]()
        adminExistingAccounts = [ExistingAccountInfo]()
        totalNumberOfAccounts = 0
        
        let docRef = self.database.collection("Accounts").addSnapshotListener{[self]
            (QuerySnapshot, err) in
            if let err = err{
                //error occurred when trying to grab the data from firestore
                print("Error occurred when grabbing documents from database.")
                print("Error is: \(err)")
            }
            else{
                for data in QuerySnapshot!.documents {
                    let accountType = data["Account Type"] as! String
                    if(accountType == "User"){
                        let firstName = data["First Name"] as! String
                        let lastName = data["Last Name"] as! String
                        let fullName = "\(firstName) \(lastName)"
                        let accountID = data["Account ID"] as! String
                        let email = data ["Email Address"] as! String
                        self.userExistingAccounts.append(ExistingAccountInfo(fullName: fullName, emailAddress: email, accountID: accountID, accountType: "User", departmentID: ""))
                    }else if (accountType == "Admin"){
                        let firstName = data["First Name"] as! String
                        let lastName = data["Last Name"] as! String
                        let fullName = "\(firstName) \(lastName)"
                        let accountID = data["Account ID"] as! String
                        let email = data ["Email Address"] as! String
                        self.adminExistingAccounts.append(ExistingAccountInfo(fullName: fullName, emailAddress: email, accountID: accountID, accountType: "Admin", departmentID: ""))
                    }
                    else if (accountType == "Employee"){
                        let firstName = data["First Name"] as! String
                        let lastName = data["Last Name"] as! String
                        let fullName = "\(firstName) \(lastName)"
                        let accountID = data["Account ID"] as! String
                        let email = data ["Email Address"] as! String
                        let departmentID = data["Department ID"] as! String
                        self.employeeExistingAccounts.append(ExistingAccountInfo(fullName: fullName, emailAddress: email, accountID: accountID, accountType: "Employee", departmentID: departmentID))
                    }
                }
                ViewExistingAccountsTableView.reloadData()
                
                database.collection("Accounts").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        self.totalNumberOfAccounts = querySnapshot!.documents.count
                        self.totalNumberOfAccountsLabel.text = "Total Number of Accounts: \(self.totalNumberOfAccounts)"
                    }
                }
            }
        }
    }
    
    //MARK: TableView Methods
    
    // Sets the section titles
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitle = String()
        if section == 0 { sectionTitle = "User Accounts" }
        else if section == 1 { sectionTitle = "Employee Accounts" }
        else if section == 2 { sectionTitle = "Admin Accounts" }
        return sectionTitle
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return userExistingAccounts.count}
        else if section == 1 {return employeeExistingAccounts.count}
        else if section == 2 {return adminExistingAccounts.count}
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSections = 3
        return(numberOfSections)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return 150}
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomExistingAccountTableViewCell
        if(indexPath.section == 0){
            cell.fullNameLabel.text = ("  \(self.userExistingAccounts[indexPath.row].fullName)")
            cell.accountIDLabel.text = ("    \(self.userExistingAccounts[indexPath.row].accountID)")
            cell.emailAddressLabel.text = ("   \(self.userExistingAccounts[indexPath.row].emailAddress)")
            cell.accountTypeLabel.text = ("    \(self.userExistingAccounts[indexPath.row].accountType)")
            cell.departmentIDLabel.isHidden = true
            cell.departmentIDTitleLabel.isHidden = true
        }else if(indexPath.section == 1){
            cell.fullNameLabel.text = ("   \(self.employeeExistingAccounts[indexPath.row].fullName)")
            cell.accountIDLabel.text = ("    \(self.employeeExistingAccounts[indexPath.row].accountID)")
            cell.emailAddressLabel.text = ("   \(self.employeeExistingAccounts[indexPath.row].emailAddress)")
            cell.accountTypeLabel.text = ("   \(self.employeeExistingAccounts[indexPath.row].accountType)")
            cell.departmentIDLabel.isHidden = false
            cell.departmentIDTitleLabel.isHidden = false
            cell.departmentIDLabel.text = (" \(self.employeeExistingAccounts[indexPath.row].departmentID)")
        }else if(indexPath.section == 2){
            cell.fullNameLabel.text = ("  \(self.adminExistingAccounts[indexPath.row].fullName)")
            cell.accountIDLabel.text = ("    \(self.adminExistingAccounts[indexPath.row].accountID)")
            cell.emailAddressLabel.text = ("  \(self.adminExistingAccounts[indexPath.row].emailAddress)")
            cell.accountTypeLabel.text = ("   \(self.adminExistingAccounts[indexPath.row].accountType)")
            cell.departmentIDLabel.isHidden = true
            cell.departmentIDTitleLabel.isHidden = true
        }
        
        return cell
    }
}
struct ExistingAccountInfo {
    var fullName: String
    var emailAddress: String
    var accountID: String
    var accountType: String
    var departmentID: String
}
class CustomExistingAccountTableViewCell: UITableViewCell{
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var accountIDLabel: UILabel!
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var departmentIDLabel: UILabel!
    @IBOutlet weak var departmentIDTitleLabel: UILabel!
}
