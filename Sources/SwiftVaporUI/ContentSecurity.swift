import Foundation
import Vapor

// Support for a Content Security Policy (CSP) that allows inline scripts and
// styles by nonce: a random value, new for every response, that the policy
// header names and each allowed `<script>` and `<style>` carries.

/// The environment key for ``EnvironmentValues/cspNonce``.
private struct CSPNonceKey: EnvironmentKey {

    /// No nonce unless one is set.
    static let defaultValue: String? = nil

}

/// The CSP nonce in the environment.
extension EnvironmentValues {

    /// The Content Security Policy nonce that `Script`, `Style` and the
    /// support styles of built-in views write as their `nonce` attribute.
    /// Set it once on the page with `.environment(\.cspNonce, req.cspNonce)`.
    public var cspNonce: String? {
        get { self[CSPNonceKey.self] }
        set { self[CSPNonceKey.self] = newValue }
    }

}

/// Makes CSP nonces.
public enum CSPNonce {

    /// Makes a new nonce: 16 random bytes from the system's secure random
    /// number generator, Base64-encoded.
    /// - Returns: A nonce such as `"q2rX0Tn9Y3Vd8jvL1u0x1Q=="`.
    public static func generate() -> String {
        var generator = SystemRandomNumberGenerator()
        let bytes = (0..<16).map { _ in UInt8.random(in: .min ... .max, using: &generator) }
        return Data(bytes).base64EncodedString()
    }

}

/// The request storage key for `req.cspNonce`.
private struct CSPNonceStorageKey: StorageKey {

    /// The stored nonce.
    typealias Value = String

}

/// Makes `req.cspNonce`'s read-then-store a single step.
private let cspNonceLock = NSLock()

/// A CSP nonce for each request.
extension Request {

    /// The Content Security Policy nonce for this request. It is made the
    /// first time it is read and stays the same for the rest of the request,
    /// so a middleware that writes the policy header and the page that
    /// writes the `nonce` attributes agree.
    ///
    /// ```swift
    /// app.get { req in
    ///     let nonce = req.cspNonce
    ///     let policy = "script-src 'nonce-\(nonce)'; style-src 'self' 'nonce-\(nonce)'; "
    ///         + "style-src-attr 'unsafe-inline'"
    ///     return HTMLResponse(headers: ["Content-Security-Policy": policy]) {
    ///         HomePage().environment(\.cspNonce, nonce)
    ///     }
    /// }
    /// ```
    ///
    /// Styling modifiers such as `.padding(_:)` write `style` attributes,
    /// which a nonce cannot cover, so the policy allows them with
    /// `style-src-attr 'unsafe-inline'`. That lets markup set styles, but
    /// not run script.
    public var cspNonce: String {
        // Read and store under one lock, so two first reads on different
        // tasks cannot make two different nonces.
        cspNonceLock.lock()
        defer { cspNonceLock.unlock() }
        if let nonce = storage[CSPNonceStorageKey.self] {
            return nonce
        }
        let nonce = CSPNonce.generate()
        storage[CSPNonceStorageKey.self] = nonce
        return nonce
    }

}
