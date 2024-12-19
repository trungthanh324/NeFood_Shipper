//
//  OrderItem.swift
//  NeFoodforDeliverier
//
//  Created by Trung Thành  on 27/10/24.
//

import Foundation
import HandyJSON
struct Food : Identifiable{
    var id = UUID().uuidString
    var item_cost : Int
    var item_name : String
    var quantity : Int
}
struct OrderItem: Identifiable{
    var id = UUID().uuidString
    var email : String
    var client_location : String
    var odered_Food : [Food]
    var total : String
    var isAdded : Bool = false
    var client_latitude : String
    var client_longitude : String
    var status : String
}

