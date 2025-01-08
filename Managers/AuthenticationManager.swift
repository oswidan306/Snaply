import Foundation
import FirebaseAuth
import FirebaseCore

enum AuthError: Error {
    case signInError(String)
    case signOutError(String)
    case noUserFound
}

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    
    init() {
        user = Auth.auth().currentUser
        isAuthenticated = user != nil
        
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isAuthenticated = user != nil
        }
    }
    
    func signUp(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            user = result.user
            isAuthenticated = true
        } catch let error as NSError {
            print("Firebase error: \(error.localizedDescription)")
            print("Firebase error code: \(error.code)")
            print("Firebase error domain: \(error.domain)")
            throw AuthError.signInError(error.localizedDescription)
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            user = result.user
            isAuthenticated = true
        } catch let error as NSError {
            print("Firebase sign in error: \(error.localizedDescription)")
            print("Firebase error code: \(error.code)")
            print("Firebase error domain: \(error.domain)")
            throw AuthError.signInError(error.localizedDescription)
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            user = nil
            isAuthenticated = false
        } catch let error as NSError {
            print("Firebase sign out error: \(error.localizedDescription)")
            print("Firebase error code: \(error.code)")
            print("Firebase error domain: \(error.domain)")
            throw AuthError.signOutError(error.localizedDescription)
        }
    }
} 