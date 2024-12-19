

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            Login()
            //Home()
                .navigationTitle("NeFood")
                .navigationBarBackButtonHidden()
                .navigationBarHidden(true)

        }
    }
}

#Preview {
    ContentView()
}
