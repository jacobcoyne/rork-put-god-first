import AuthenticationServices
import SwiftUI

@Observable
final class AuthenticationService: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    static let shared = AuthenticationService()

    var isSignedIn: Bool = false
    var userDisplayName: String = ""
    var userEmail: String = ""
    var userIdentifier: String = ""

    private override init() {
        super.init()
        loadSavedCredentials()
    }

    func startSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
        }
    }

    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
            self.processCredential(credential)
        }
    }

    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    }

    func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
            processCredential(credential)
        case .failure:
            break
        }
    }

    private func processCredential(_ credential: ASAuthorizationAppleIDCredential) {
        userIdentifier = credential.user
        UserDefaults.standard.set(credential.user, forKey: "appleUserIdentifier")

        if let fullName = credential.fullName {
            let name = [fullName.givenName, fullName.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            if !name.isEmpty {
                userDisplayName = name
                UserDefaults.standard.set(name, forKey: "appleUserDisplayName")
            }
        }

        if let email = credential.email {
            userEmail = email
            UserDefaults.standard.set(email, forKey: "appleUserEmail")
        }

        isSignedIn = true
        UserDefaults.standard.set(true, forKey: "isAppleSignedIn")
    }

    func signOut() {
        isSignedIn = false
        userDisplayName = ""
        userEmail = ""
        userIdentifier = ""
        UserDefaults.standard.set(false, forKey: "isAppleSignedIn")
        UserDefaults.standard.removeObject(forKey: "appleUserIdentifier")
        UserDefaults.standard.removeObject(forKey: "appleUserDisplayName")
        UserDefaults.standard.removeObject(forKey: "appleUserEmail")
    }

    func deleteAccount() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        isSignedIn = false
        userDisplayName = ""
        userEmail = ""
        userIdentifier = ""
    }

    func checkCredentialState() {
        guard !userIdentifier.isEmpty else { return }
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userIdentifier) { state, _ in
            Task { @MainActor in
                if state != .authorized {
                    self.signOut()
                }
            }
        }
    }

    private func loadSavedCredentials() {
        let defaults = UserDefaults.standard
        isSignedIn = defaults.bool(forKey: "isAppleSignedIn")
        userIdentifier = defaults.string(forKey: "appleUserIdentifier") ?? ""
        userDisplayName = defaults.string(forKey: "appleUserDisplayName") ?? ""
        userEmail = defaults.string(forKey: "appleUserEmail") ?? ""
    }
}
