
import SwiftUI

struct OrderTaken: View {
    @ObservedObject var HomeModel: HomeViewModel
    @State var isOpenTrackingScreen = false
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(HomeModel.userAddress == nil ? "Please open location on Settings" : "Your location: " + HomeModel.userAddress)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .font(.headline)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .background(Color.blue)
            .cornerRadius(10)
            .padding([.leading, .trailing, .top], 16)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(HomeModel.takens) { taken in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Deliver to: " + taken.item.client_location)
                                .font(.title3)
                                .lineLimit(3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text("Email: " + taken.item.email)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text("Total: \(taken.item.total)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            ForEach(taken.item.odered_Food) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Order: " + item.item_name)
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                    Text("Cost: \(item.item_cost)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                    Text("Quantity: \(item.quantity)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading, 16)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)

                        Button(action: {
                            self.isOpenTrackingScreen = true
//                            HomeModel.takeOrder(orderID: taken.item.id)
                            HomeModel.UpdateTakeOrder(orderID: taken.item.id)
                        }) {
                            Text("Confirm")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.9))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding([.leading, .trailing, .bottom], 16)
                        
                        NavigationLink(destination: TrackingScreen(HomeModel: HomeModel),isActive: $isOpenTrackingScreen){
                            EmptyView()
                        }
                    }//foreach
                }
                .padding(.top, 16)
            }
            Spacer(minLength: 0)
        }
        .background(Color(UIColor.systemGray6))
        .onAppear {
            HomeModel.locationManager.delegate = HomeModel
        }
    }
}

