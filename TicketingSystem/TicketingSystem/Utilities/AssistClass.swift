//
//  AssistClass.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 1/5/22.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

var tempAccountInformation = AccountInformation()

struct AccountInformation {
    
    var emailAddress = String()
    var password = String()
    var firstName = String()
    var lastName = String()
    var dateOfBirth = String()
    var accountType = String()
    
    
    init() { }
    
    init(emailAddress: String, password: String, firstName: String, lastName: String, dateOfBirth: String, accountType: String) {
        self.emailAddress = emailAddress
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.accountType = accountType
    }
}
class Assist: UIViewController{
    //method to get the correct department ID given the department name
    //Method is here so it can be used throughout application with ease
    static func fetchDepartmentID(departmentName: String) -> String{
        switch(departmentName){
        case "Operations Management":
            return "2121"
            break
        case "Marketing":
            return "3232"
            break
        case "IT":
            return "5454"
            break
        case "Human Resources":
            return "7676"
            break
        case "Finance":
            return "9898"
            break
        default:
            print("Department name wasn't recognized. Please try again!")
        }
        return "Something went wrong"
    }
}
