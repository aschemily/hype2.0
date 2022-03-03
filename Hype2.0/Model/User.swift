//
//  User.swift
//  Hype2.0
//
//  Created by Emily Asch on 3/2/22.
//

import UIKit
import CloudKit

struct UserStrings{
    static let recordTypeKey = "User"
    fileprivate static let usernameKey = "username"
    fileprivate static let bioKey = "bio"
    static let appleUserReferenceKey = "appleUserReference"
    fileprivate static let photoAssetKey = "photoAsset"
}

class User {
    //class properties
    var username: String
    var bio: String
    var profilePhoto: UIImage?{
        get{
            guard let photoData = self.photoData else {return nil}
            return UIImage(data: photoData)
        }set{
            self.photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
        
    }
    //Cloudkit properties
    var photoData: Data?
    var recordID: CKRecord.ID
    var appleUserReference: CKRecord.Reference
    
    var photoAsset: CKAsset? {
        get{
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do{
                try photoData?.write(to: fileURL)
            }catch{
                print("🔴error in \(#function), \(error.localizedDescription), \(error)🔴")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    init(username: String, bio: String = "", profilePhoto: UIImage? = nil,recordID:CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserReference: CKRecord.Reference){
        self.username = username
        self.bio = bio
        self.recordID = recordID
        self.appleUserReference = appleUserReference
        self.profilePhoto = profilePhoto
    }
}

//retrieving the records back
extension User{
    convenience init?(ckRecord: CKRecord){
        guard let username = ckRecord[UserStrings.usernameKey] as? String,
              let appleUserReference = ckRecord[UserStrings.appleUserReferenceKey] as? CKRecord.Reference,
              let bio = ckRecord[UserStrings.bioKey] as? String
        else {return nil}
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[UserStrings.photoAssetKey] as? CKAsset {
            do{
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            }catch{
                print("cant transform asset to data")
            }
        }
        
        self.init(username: username, bio: bio, profilePhoto: foundPhoto, recordID: ckRecord.recordID, appleUserReference: appleUserReference)
    }
}

extension User: Equatable{
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.recordID == rhs.recordID
    }
    
    
}

//sending ck records
extension CKRecord {
    convenience init(user:User){
        self.init(recordType: UserStrings.recordTypeKey, recordID: user.recordID)
        self.setValuesForKeys([
            UserStrings.usernameKey : user.username,
            UserStrings.bioKey : user.bio,
            UserStrings.appleUserReferenceKey : user.appleUserReference,
            UserStrings.photoAssetKey : user.photoAsset
        ])
    }
}
