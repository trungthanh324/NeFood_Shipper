//
//  TrackingScreen.swift
//  FoodOderring_FinalProject
//
//  Created by Trung Thành  on 7/11/24.
//

import SwiftUI
import MapKit
import FirebaseAuth
struct TrackingScreen: View {
    @ObservedObject var HomeModel: HomeViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var userAddress : CLLocationCoordinate2D?
    @State private var client_Address : CLLocationCoordinate2D?
    @State private var cameraPosition : MapCameraPosition = .automatic
    @State private var routePolyline: MKPolyline?
    @State private var distanceInKilometers: Double?
    @State private var estimatedTravelTime: TimeInterval?

    var body: some View {
        VStack{
            VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.green)
                            Text("From: \(HomeModel.userAddress)")
                        }
                        HStack {
                            Image(systemName: "house.fill")
                                .foregroundColor(.red)
                            ForEach(HomeModel.takens){taken in
                                Text("To: \(taken.item.client_location)")
                            }
                        }
                        HStack(spacing: 5){
                            if let distance = distanceInKilometers {
                                Text(String(format: "Distance: %.2f km", distance))
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding(.top, 2)
                            }
                            if let travelTime = estimatedTravelTime {
                                Text(", \(formatTravelTime(travelTime))")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding(.top, 2)
                            }
                        }

                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
//                    .onAppear {
//                            if HomeModel.orderStatus == "cancel" {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                    presentationMode.wrappedValue.dismiss()
//                                }
//                            }
//                    }
//                    .onChange(of: HomeModel.orderStatus) { newStatus in
//                            if newStatus == "cancel" {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                    presentationMode.wrappedValue.dismiss()
//                                }
//                            }
//                    }
                }
            MapViewWithPolyline(userLocation: $userAddress, shipperLocation: $client_Address, polyline: $routePolyline)
                .onAppear {
                    let userLocation = CLLocationCoordinate2D(
                        latitude: Double(HomeModel.userLatitude)!,
                        longitude: Double(HomeModel.userLongitude)!)
                    self.userAddress = userLocation

                    if let firstTaken = HomeModel.takens.first,
                       let clientLatitude = Double(firstTaken.item.client_latitude),
                       let clientLongitude = Double(firstTaken.item.client_longitude) {
                       let clientLocation = CLLocationCoordinate2D(latitude: clientLatitude,
                                                                   longitude: clientLongitude)
                       self.client_Address = clientLocation
// tinh km
                       let shipperCLLocation = CLLocation(latitude: userLocation.latitude,
                                                           longitude: userLocation.longitude)
                       let userCLLocation = CLLocation(latitude: clientLocation.latitude,
                                                        longitude: clientLocation.longitude)
                       let distanceInMeters = shipperCLLocation.distance(from: userCLLocation)
                       self.distanceInKilometers = distanceInMeters / 1000
                    } else {
                        print("k co phan tu nao")
                    }

                    // tinh duong di
                    if let start = userAddress, let end = client_Address {
                        calculateRoute(startPoint: start, endPoint: end) { polyline, travelTime  in
                            if let polyline = polyline {
                                self.routePolyline = polyline
                                print("Ve thanh cong")
                            } else {
                                print("K ve dc")
                            }
                            
                            if let travelTime = travelTime {
                                self.estimatedTravelTime = travelTime
                                print("tinh thoi gian thanh cong")
                            }else{
                                print("k tinh dc thoi gian uoc tinh")
                            }
                        }
                    }
                }
            HStack(spacing: 15) {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Cancel")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                if let firstTaken = HomeModel.takens.first{
                                    let orderID = firstTaken.item.id
                                    HomeModel.doneOrder(orderID: orderID)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                                        HomeModel.afterDoneOrder(orderID: orderID)
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }) {
                                Text("Done")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
            }
            .padding(.horizontal)
        }
        
    }//body
}

extension TrackingScreen{
 //func tinh toan duong di , uoc tinh thoi gian
    func calculateRoute(startPoint: CLLocationCoordinate2D,endPoint: CLLocationCoordinate2D,completion: @escaping (MKPolyline?, TimeInterval?) -> Void) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startPoint))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endPoint))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let error = error {
                print("loi k tinh dc duong di: \(error)")
                completion(nil,nil)
                return
            }
            if let route = response?.routes.first {
                completion(route.polyline, route.expectedTravelTime)
            } else {
                completion(nil,nil)
            }
        }
    }
    
    func formatTravelTime(_ time: TimeInterval) -> String {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return "\(minutes) min \(seconds) sec"
    }
    
}

struct MapViewWithPolyline: UIViewRepresentable {
    @Binding var userLocation: CLLocationCoordinate2D?
    @Binding var shipperLocation: CLLocationCoordinate2D?
    @Binding var polyline: MKPolyline?
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewWithPolyline

        init(parent: MapViewWithPolyline) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 4.0
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        let locationButton = UIButton(type: .system)
              locationButton.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
              locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
              locationButton.addTarget(mapView, action: #selector(mapView.locateUser), for: .touchUpInside)
        mapView.addSubview(locationButton)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)
        if let userLocation = userLocation {
               let region = MKCoordinateRegion(center: userLocation,
                                               span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
               uiView.setRegion(region, animated: true)
           }
        
        if let shipperLocation = shipperLocation {
            let shipperAnnotation = MKPointAnnotation()
            shipperAnnotation.coordinate = shipperLocation
            shipperAnnotation.title = "Customer"
            uiView.addAnnotation(shipperAnnotation)
        }

        if let polyline = polyline {
            uiView.addOverlay(polyline)
        }
    }
}


extension MKMapView {
    @objc func locateUser() {
        if let userLocation = self.userLocation.location {
                 let center = userLocation.coordinate
                 let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                 let region = MKCoordinateRegion(center: center, span: span)
                 self.setRegion(region, animated: true)
        }
    }
}
