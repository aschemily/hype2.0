//
//  UserController.swift
//  Hype2.0
//
//  Created by Emily Asch on 3/2/22.
//

import CloudKit
import UIKit

class UserController{
    //shared instance
    static let shared = UserController()
    //source of truth
    var currentUser: User?
    //database constant
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //MARK: CRUD
    
    //create
    func createUser(with username: String,bio: String, profilePhoto: UIImage?, completion: @escaping (Bool)-> Void){
      //fetching the CKUserIdentity recordID, creating a reference to use with our user object
        fetchAppleUserReference { reference in
            //ensure that we can unwrap the reference
            guard let reference = reference else {completion(false) ; return}
            //init a new user with the reference
            let newUser = User(username: username, bio: bio, profilePhoto: profilePhoto, appleUserReference: reference)
            //create the ckrecord to be saved from the newUser
            let record = CKRecord(user: newUser)
            //call the .save method to save the newly created ckrecord
            self.publicDB.save(record) { record, error in
                //handle the error
                if let error = error{
                    print("🔴error in \(#function), \(error.localizedDescription), \(error)")
                    completion(false)
                    return
                }
                //unwrap record that was saved, ensure we can init a user form that record
                guard let record = record,
                        let savedUser = User(ckRecord: record)
                else {completion(false) ; return}
                //set current user and complete true
                self.currentUser = savedUser
                print("🟢created user \(record.recordID.recordName) successfully🟢")
                completion(true)
            }
        }
    }
    
    func fetchUser(completion: @escaping (Bool)->Void){
       //step 4 fetch and unwrap the appleUserRef to use in our predicate
        fetchAppleUserReference { reference in
            guard let reference = reference else {completion(false) ; return}
            //define the predicate
            //predicate takes an array of arugments and passes them into the format "%K == %@"
            //the first item in the array is being passed in to %K which is key and second item is being passed into %@ which is value
            let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.appleUserReferenceKey,reference ])
            
            //step 2 init the query
            let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: predicate)
            
            //step 1 perform the query
            self.publicDB.perform(query, inZoneWith: nil) {records, error in
                if let error = error{
                    print("🔴error in \(#function), \(error.localizedDescription), \(error)❌")
                    completion(false)
                    return
                }
                guard let record = records?.first,
                      let foundUser = User(ckRecord: record)
                else {completion(false) ; return}
                
                self.currentUser = foundUser
                print("fetched user \(record.recordID.recordName)")
                completion(true)
            }
        }
    }
    
    //help function
    private func fetchAppleUserReference(completion: @escaping(CKRecord.Reference?)-> Void){
        CKContainer.default().fetchUserRecordID { recordID, error in
            if let error = error{
                print("🔴error in \(#function), \(error.localizedDescription), \(error)🎈")
                completion(nil)
                return
            }
            
            guard let recordID = recordID else {completion(nil) ; return}
            let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            completion(reference)
        }
    }
    
    func update(_ user: User){
        
    }
    
    func delete(_ user: User){
        
    }
    
    
}//end of class
