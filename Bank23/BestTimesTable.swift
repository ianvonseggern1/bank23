//
//  BestTimesTable.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.19
//

import Foundation
import UIKit
import AWSDynamoDB

@objcMembers
class BestTimesTable: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _boardID: String?
    var _timeStamp: NSNumber?
    var _facebookID: String?
    var _playID: String?
    var _bestTime: NSNumber?
    var _userUUID: String?
    var _username: String?
    
    class func dynamoDBTableName() -> String {

        return "bank-mobilehub-787901168-BestTimesTable"
    }
    
    class func hashKeyAttribute() -> String {

        return "_boardID"
    }
    
    class func rangeKeyAttribute() -> String {

        return "_timeStamp"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_boardID" : "boardID",
               "_timeStamp" : "timeStamp",
               "_facebookID" : "facebookID",
               "_playID" : "playID",
               "_bestTime" : "bestTime",
               "_userUUID" : "userUUID",
               "_username" : "username",
        ]
    }
}
