//
//  HypeController.swift
//  Hype2.0
//
//  Created by Emily Asch on 3/1/22.
//

import Foundation

import CloudKit

class HypeController {
    //shared instance
    static let shared = HypeController()
    
    //SOT
    var hypes: [Hype] = []
    //Constant to access our publicCloud Database
    let publicDB = CKContainer.default().publicCloudDatabase
  
    
    //MARK: CRUD
    
    //create
    func saveHype(with text: String, completion: @escaping(Bool)-> Void){
        //init hype object
        let newHype = Hype(body: text)
        //package the newHype in a CKRecord
        let hypeRecord = CKRecord(hype: newHype)
        //saving hypeRecord to the cloud
        publicDB.save(hypeRecord) { record, error in
            print(self.publicDB)
            if let error = error {
                print("🔴error in \(#function), \(error.localizedDescription), \(error)🔴")
                completion(false)
                return
            }
            //unwrapping the record that was saved
            guard let record = record,
                  let savedHype = Hype(ckRecord: record)
            else {completion(false) ; return}
            //add it to out SOT array
            print("✅saved hype successfully, \(record)✅")
            self.hypes.insert(savedHype, at: 0)
            completion(true)
        }
    }
    
    //fetch
    func fetchHypes(completion: @escaping (Bool)->Void){
        //step 3 - init requisite predicate for the query
        let predicate = NSPredicate(value: true)
        //step 2: init the requisite query for the .perform method
        let query = CKQuery(recordType: HypeStringsStruct.recordTypeKey, predicate: predicate)
       //step 1: perform query on database
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
          //handle the error
            if let error = error{
                print("🔴error in \(#function), \(error.localizedDescription)🔴")
                completion(false)
                return
            }
            //unwrap the records
            guard let records = records else {completion(false) ; return}
            print("✅fetched all hypes \(records)✅")
            //compact map through the found records to return the non-nil hype objects
            let fetchedHypes = records.compactMap{ Hype(ckRecord: $0)}
            //set source of truth
            self.hypes = fetchedHypes
            completion(true)
        }
        
    }
    
    func update(_ hype: Hype, completion: @escaping(Bool) -> Void){
      //step 3: define records to be updated
        let recordToUpdate = CKRecord(hype: hype)
        //step 2 - create requisite operation
        let operation = CKModifyRecordsOperation(recordsToSave: [recordToUpdate])
        //step 4 - set properties for the operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = {(records, _, error) in
           //handle error
            if let error = error{
                print("🔴error in \(#function), \(error.localizedDescription)🔴")
                completion(false)
                return
            }
            //ensure that the records were returned and updated
            guard let record = records?.first else {
                completion(false)
                return
            }
            print("✅updated \(record.recordID.recordName) successfully in cloudkit✅")
            completion(true)
        }
        //step 1 add operation to db
        publicDB.add(operation)
        
    }
    
    func delete(_ hype: Hype, completion: @escaping (Bool)-> Void){
        //step 2 - declared operation
        let operation = CKModifyRecordsOperation(recordIDsToDelete: [hype.recordID])
        //step 3- set the properties on the operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = {(_, recordIDs, error) in
            if let error = error{
                print("🔴error in \(#function), \(error.localizedDescription)🔴")
                completion(false)
                return
            }
            guard let recordIds = recordIDs else {
                completion(false)
                return
                
            }
            print("\(recordIds) were removed successfully")
        }
        //step 1- add operation to the database
        publicDB.add(operation)
        
    }
    
    func subscribeForRemoteNotifications(completion: @escaping(Error?) -> Void){
       //step 3- declare requisite predicate
        let predicate = NSPredicate(value: true)
        
        //step 2- declare subscription
        let subscription = CKQuerySubscription(recordType: HypeStringsStruct.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        
        //step 4 - setting subscription properties
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "Alert title YAY"
        notificationInfo.alertBody = "this is body for hype alert"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        
        
        //step 1 -call save(subscription) function in db
        publicDB.save(subscription) { _, error in
            if let error = error{
                print("🔴error in \(#function), \(error.localizedDescription), \(error)🔴")
                completion(error)
            }
            completion(nil)
        }
    }
    
}//end of class
