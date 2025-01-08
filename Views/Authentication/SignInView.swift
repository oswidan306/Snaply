import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Snaply")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Button("Sign In") {
                    Task {
                        do {
                            try await authManager.signIn(email: email, password: password)
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Create Account") {
                    showingSignUp = true
                }
            }
            .padding()
            .sheet(isPresented: $showingSignUp) {
                SignUpView(authManager: authManager)
            }
        }
    }
} 