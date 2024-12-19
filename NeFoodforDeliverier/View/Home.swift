
import SwiftUI

struct Home: View {
    @StateObject var HomeModel = HomeViewModel()
    @State var isShowOrderTaken = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6).ignoresSafeArea()
                VStack(spacing: 4) {
                        Text(HomeModel.userAddress == nil ? "Please open location on Settings" : "Your location: " + HomeModel.userAddress)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    List(HomeModel.items) { item in
                        Section {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Deliver to: " + item.client_location)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 5)
                                ForEach(item.odered_Food) { fod in
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Order: " + fod.item_name)
                                            .font(.headline)
                                        Text("Cost: \(fod.item_cost)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("Quantity: \(fod.quantity)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.leading, 16)
                                }
                                Text("Total: " + item.total)
                                    .font(.headline)
                                    .padding(.vertical, 5)
                                Button(action: {
                                    HomeModel.takens.removeAll()
                                    HomeModel.addtoTaken(item: item)
                                    isShowOrderTaken.toggle()
                                }, label: {
                                    Text("Take Order")
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red.opacity(0.9))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                })
                                .padding(.top, 10)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                        .listRowInsets(EdgeInsets())
                        .padding(.top,15)
                        //.background(Color.systemGray6)
                    }
                    .listStyle(PlainListStyle())
                    .onAppear {
                        HomeModel.getData()
                    }
                }
                .padding(.top)
                NavigationLink(destination: OrderTaken(HomeModel: HomeModel), isActive: $isShowOrderTaken) {
                    EmptyView()
                }
                Spacer()
            }
            .onAppear {
                HomeModel.locationManager.delegate = HomeModel
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    Home()
}

