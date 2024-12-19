import SwiftUI
import FirebaseAuth

struct Login: View {
    @State private var color = Color.black.opacity(0.7)
    @State private var email = ""
    @State private var pass = ""
    @State private var visible = false
    @State private var isShowingScreenRegister = false
    @State private var alert = false
    @State private var error = ""
    @State private var openHome = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }

                VStack {
                    Image("ImageLogin")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding(.top, 50)

                    Text("Log in to your account")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 35)

                    // Email TextField
                    TextField("Email", text: $email)
                        .padding()
                        .foregroundColor(.black)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .stroke(email.isEmpty ? color : Color.gray.opacity(0.5), lineWidth: 2))
                        .padding(.bottom, 5)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)

                    // Password Input
                    HStack(spacing: 15){
                        VStack{
                            if self.visible{
                                TextField("Password", text: self.$pass)
                                    .background(RoundedRectangle(cornerRadius: 4).stroke(self.pass != "" ? Color("Color") : self.color, lineWidth: 2))
                                    .foregroundColor(.black)
                            }else{
                                SecureField("Password", text: self.$pass)
                                    .foregroundColor(.black)
                            }
                        }
                                                         
                        Button {
                            self.visible.toggle()
                        } label: {
                            Image(systemName: self.visible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(self.color)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).stroke(self.pass != "" ? Color(Color.gray.opacity(0.5)) : self.color, lineWidth: 2))

                    // Forget Password Button
                    HStack {
                        Spacer()
                        Button(action: reset) {
                            Text("Forget password?")
                                .fontWeight(.bold)
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                    .padding(.top, 20)

                    // Login Button
                    Button(action: verify) {
                        Text("Log in")
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)

                    // Navigation Links
                    NavigationLink(destination: Home(), isActive: $openHome) {
                        EmptyView()
                    }
                }
                .padding(.horizontal, 25)
            }
        }
    }

    // Function to hide keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func verify() {
        if email.isEmpty || pass.isEmpty {
            error = "Please fill all the contents properly"
            alert.toggle()
            return
        }

        Auth.auth().signIn(withEmail: email, password: pass) { result, err in
            if let err = err {
                error = err.localizedDescription
                alert.toggle()
            } else {
                openHome = true
            }
        }
    }

    private func reset() {
        guard !email.isEmpty else {
            error = "Input your email"
            alert.toggle()
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { err in
            if let err = err {
                error = err.localizedDescription
            } else {
                error = "Reset email sent."
            }
            alert.toggle()
        }
    }
}

// Preview
#Preview {
    Login()
}
