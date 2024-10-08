//
//  AppleSignInHelper.swift
//  rawggammers
//
//  Created by Ademola Kolawole on 24/07/2024.
//

import Foundation
import CryptoKit
import AuthenticationServices
import FirebaseAuth
import SwiftUI

/// A struct representing the result of a sign-in with Apple.
struct SignInWithAppleResult {
    let token: String
    let nonce: String
}

@MainActor
final class AppleSignInHelper: NSObject {
    
    private var currentNonce: String?
    private var completionHandler: ((Result<SignInWithAppleResult, Error>) -> Void)? = nil
    
    /// Initiates the sign-in flow with Apple and returns user authentication data.
    ///
    /// - Returns: An `AuthDataModel` containing user information.
    /// - Throws: An error if the sign-in process fails.
    func startSignWithAppleFlow() async throws -> AuthDataModel {
        return try await withCheckedThrowingContinuation { continuation in
            startSignInWithAppleFlow { result in
                switch result {
                case .success(let signInWithAppleResult):
                    let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: signInWithAppleResult.token, rawNonce: signInWithAppleResult.nonce)
                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let authResult = authResult {
                            let email = authResult.user.email ?? ""
                            let fullName = authResult.user.displayName ?? ""
                            let photoURL = authResult.user.photoURL
                            let uid = authResult.user.uid
                            let authDataModel = AuthDataModel(uid: uid, email: email, fullName: fullName, photoURL: photoURL)
                            continuation.resume(returning: authDataModel)
                        }
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Starts the sign-in flow with Apple.
    ///
    /// - Parameter completion: A closure that is called with the result of the sign-in attempt.
    func startSignInWithAppleFlow(completion: @escaping (Result<SignInWithAppleResult, Error>) -> Void) {
        guard let topVC = Utilities.shared.topViewController() else {
            completion(.failure(SignInWithAppleError.noViewController))
            return
        }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        completionHandler = completion
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = topVC
        authorizationController.performRequests()
    }
    
    /// Generates a random nonce string.
    ///
    /// - Parameter length: The length of the nonce string. Default is 32.
    /// - Returns: A random nonce string.
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    /// Hashes a string using SHA-256.
    ///
    /// - Parameter input: The string to be hashed.
    /// - Returns: The SHA-256 hash of the input string, represented as a hexadecimal string.
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension AppleSignInHelper: ASAuthorizationControllerDelegate {
    
    /// Handles successful completion of Apple Sign-In.
    ///
    /// - Parameters:
    ///   - controller: The `ASAuthorizationController` that completed authorization.
    ///   - authorization: The `ASAuthorization` containing the credential information.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8),
            let nonce = currentNonce
        else {
            completionHandler?(.failure(SignInWithAppleError.invalidCredential))
            return
        }
        
        let tokens = SignInWithAppleResult(token: idTokenString, nonce: nonce)
        completionHandler?(.success(tokens))
    }
    
    /// Handles errors that occur during Apple Sign-In.
    ///
    /// - Parameters:
    ///   - controller: The `ASAuthorizationController` that encountered an error.
    ///   - error: The error that occurred.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
        completionHandler?(.failure(error))
    }
}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

private enum SignInWithAppleError: LocalizedError {
    case noViewController
    case invalidCredential
    case badResponse
    case unableToFindNonce
    
    var errorDescription: String? {
        switch self {
        case .noViewController:
            return "Could not find top view controller."
        case .invalidCredential:
            return "Invalid sign in credential."
        case .badResponse:
            return "Apple Sign In had a bad response."
        case .unableToFindNonce:
            return "Apple Sign In token expired."
        }
    }
}

struct AuthDataModel {
    let uid: String
    let email: String
    let fullName: String
    let photoURL: URL?
}
