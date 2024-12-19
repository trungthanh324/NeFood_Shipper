

import SwiftUI
import CoreLocation
import FirebaseFirestoreInternal
import FirebaseAuth
import FirebaseDatabase


class HomeViewModel : NSObject, ObservableObject, CLLocationManagerDelegate{
    @Published var items : [OrderItem] = []
    @Published var takens : [Taken] = []
    @Published var locationManager = CLLocationManager()
    @Published var userLocation : CLLocation!
    @Published var userAddress = ""
    
    @Published var noLocation = false
    
    @Published var userLatitude = ""
    @Published var userLongitude = ""
    
    @Published var orderStatus : String = ""
//    private var locationUpdateTimer: Timer?

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            print("authorized")
            self.noLocation = false
            manager.requestLocation()
        case .denied:
            print("denied")
            self.noLocation = true
        default:
            print("unknown")
            self.noLocation = false
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = locations.last
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        userLatitude = String(latitude)
        userLongitude = String(longitude)
        self.extractLocation()
    }
    // lay toa do cua user(CLDeoCoder) -> dich ra thanh ten duong cu the
    func extractLocation(){
        CLGeocoder().reverseGeocodeLocation(self.userLocation) { res, err in
            guard let safeData = res else{return}
            var address = ""
            address += safeData.first?.name ?? ""
            address += ", "
            address += safeData.first?.locality ?? ""
            self.userAddress = address
        }
    }
    
    func getData(){
        let db = Firestore.firestore()
        db.collection("Users").getDocuments { snap, err in
            guard let itemData = snap else { return }
            self.items = itemData.documents.compactMap { doc -> OrderItem? in
                let id = doc.documentID
                let email = doc.get("email") as? String ?? ""
                let location = doc.get("client_location") as? String ?? ""
                let total = doc.get("total") as? String ?? ""
                let status = doc.get("status") as? String ?? ""
                let orderedFood = doc.get("odered_Food") as? [[String: Any]] ?? []
                let lati = doc.get("client_latitude") as? String ?? ""
                let longi = doc.get("client_longitude") as? String ?? ""
                var foods: [Food] = []
                for foodData in orderedFood {
                    if let item_name = foodData["item_name"] as? String,
                       let item_cost = foodData["item_cost"] as? Int,
                       let quantity = foodData["quantity"] as? Int {
                        let foodItem = Food(item_cost: item_cost, item_name: item_name, quantity: quantity)
                        foods.append(foodItem)
                    }
                }
                self.orderStatus = status
                return OrderItem(id: id, email: email, client_location: location, odered_Food: foods, total: total, client_latitude: lati,client_longitude: longi, status: status)
            }
        }
    }
    
    func addtoTaken(item: OrderItem) {
        let itemIndex = getIndex(item: item, isCartIndex: false)
        self.items[itemIndex].isAdded.toggle()
        if self.items[itemIndex].isAdded {
            self.takens.append(Taken(item: item))
        }else{
            let cartIndex = getIndex(item: item, isCartIndex: true)
            self.takens.remove(at: cartIndex)
        }
    }
    
    func getIndex(item: OrderItem, isCartIndex: Bool) -> Int {
        if isCartIndex {
            return self.takens.firstIndex { taken in
                return item.id == taken.item.id
            } ?? 0
        }else {
            // tim id cua sp trong arr items
            return self.items.firstIndex { orderItem in
                return item.id == orderItem.id
            } ?? -1
        }
    }

    func UpdateTakeOrder(orderID : String){
        let db = Firestore.firestore()
        db.collection("Users").document(orderID).updateData([
            "status": "taken",
            "shipper_latitude" : self.userLatitude,
            "shipper_longitude": self.userLongitude,
            "shipper_location" : self.userAddress
        ]){ error in
            if let error = error {
                print("loi k cap nhat dc vi tri len fs: \(error)")
            } else {
                print("cap nhat thanh cong len fs")
            }
        }
    }
    
//    func takeOrder(orderID : String){
//        UpdateTakeOrder(orderID: orderID)
//        startUpdatingLocation(orderID: orderID)
//    }
    
//    func startUpdatingLocation(orderID: String) {
//        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            
//            if self.orderStatus != "cancel" || self.orderStatus != "done"{
//                self.UpdateTakeOrder(orderID: orderID)
//                print("update vi tri len tuc moi 5s")
//            } else {
//                print("done k cap nhat vi tri nua")
//                self.stopUpdatingLocation()
//            }
//        }
//    }
        
//    func stopUpdatingLocation() {
//        locationUpdateTimer?.invalidate()
//        locationUpdateTimer = nil
//        print("stop update vi tri")
//    }
//    
    
    func doneOrder(orderID : String){
        let db = Firestore.firestore()
        db.collection("Users").document(orderID).updateData([
            "status" : "done"
        ]){ err in
            if err != nil{
                print("loi")
                return
            }else{
//                self.stopUpdatingLocation()
                print("da update thanh cong")
            }
        }
    }
    
    func afterDoneOrder(orderID : String){
        let db = Firestore.firestore()
        db.collection("Users").document(orderID).delete(){ err in
            if err != nil{
                print("loi")
                return
            }else{
                print("da delete thanh cong")
            }
        }
    }

}
