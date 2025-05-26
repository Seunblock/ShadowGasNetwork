;; Gasless Transactions Contract
;; Allows users to execute transactions without paying gas fees directly
;; Sponsors can fund gas pools and relay transactions for users

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-FUNDS (err u101))
(define-constant ERR-INVALID-SIGNATURE (err u102))
(define-constant ERR-NONCE-USED (err u103))
(define-constant ERR-EXPIRED (err u104))
(define-constant ERR-INVALID-SPONSOR (err u105))

;; Data Variables
(define-data-var contract-enabled bool true)
(define-data-var min-sponsor-balance uint u1000000) ;; 1 STX minimum
(define-data-var max-gas-limit uint u50000)

;; Data Maps
(define-map sponsors principal uint) ;; sponsor -> balance
(define-map user-nonces principal uint) ;; user -> nonce
(define-map relayed-txs { user: principal, nonce: uint } bool) ;; prevent replay
(define-map gas-costs principal uint) ;; track gas usage per user

;; Sponsor Management Functions
(define-public (register-sponsor (initial-deposit uint))
    (let ((sponsor tx-sender))
        (asserts! (>= initial-deposit (var-get min-sponsor-balance)) ERR-INSUFFICIENT-FUNDS)
        (try! (stx-transfer? initial-deposit sponsor (as-contract tx-sender)))
        (map-set sponsors sponsor initial-deposit)
        (ok true)
    )
)

(define-public (sponsor-deposit (amount uint))
    (let ((sponsor tx-sender)
          (current-balance (default-to u0 (map-get? sponsors sponsor))))
        (asserts! (> amount u0) ERR-INSUFFICIENT-FUNDS)
        (try! (stx-transfer? amount sponsor (as-contract tx-sender)))
        (map-set sponsors sponsor (+ current-balance amount))
        (ok true)
    )
)

(define-public (sponsor-withdraw (amount uint))
    (let ((sponsor tx-sender)
          (current-balance (default-to u0 (map-get? sponsors sponsor))))
        (asserts! (>= current-balance amount) ERR-INSUFFICIENT-FUNDS)
        (try! (as-contract (stx-transfer? amount tx-sender sponsor)))
        (map-set sponsors sponsor (- current-balance amount))
        (ok true)
    )
)

;; Core Gasless Transaction Function
(define-public (execute-gasless-tx 
    (user principal)
    (function-name (string-ascii 64))
    (args (list 10 uint))
    (nonce uint)
    (expiry uint)
    (gas-limit uint)
    (signature (buff 65)))
    
    (let ((sponsor tx-sender)
          (sponsor-balance (default-to u0 (map-get? sponsors sponsor)))
          (user-nonce (default-to u0 (map-get? user-nonces user)))
          (tx-key { user: user, nonce: nonce })
          (estimated-gas (* gas-limit u1000))) ;; simplified gas calculation
        
        ;; Validations
        (asserts! (var-get contract-enabled) ERR-UNAUTHORIZED)
        (asserts! (> sponsor-balance u0) ERR-INVALID-SPONSOR)
        (asserts! (>= sponsor-balance estimated-gas) ERR-INSUFFICIENT-FUNDS)
        (asserts! (is-eq nonce user-nonce) ERR-NONCE-USED)
        (asserts! (is-none (map-get? relayed-txs tx-key)) ERR-NONCE-USED)
        (asserts! (<= gas-limit (var-get max-gas-limit)) ERR-UNAUTHORIZED)
        (asserts! (> expiry block-height) ERR-EXPIRED)
        
        ;; Validate signature (simplified - in production use proper signature verification)
        (asserts! (verify-signature user function-name args nonce expiry) ERR-INVALID-SIGNATURE)
        
        ;; Execute transaction
        (map-set relayed-txs tx-key true)
        (map-set user-nonces user (+ user-nonce u1))
        
        ;; Deduct gas from sponsor
        (map-set sponsors sponsor (- sponsor-balance estimated-gas))
        
        ;; Track gas usage
        (map-set gas-costs user 
            (+ (default-to u0 (map-get? gas-costs user)) estimated-gas))
        
        ;; Emit transaction event (simplified)
        (print { 
            event: "gasless-tx-executed",
            user: user,
            sponsor: sponsor,
            function: function-name,
            gas-used: estimated-gas,
            nonce: nonce
        })
        
        (ok true)
    )
)

;; Helper function for signature verification (simplified)
(define-private (verify-signature 
    (user principal)
    (function-name (string-ascii 64))
    (args (list 10 uint))
    (nonce uint)
    (expiry uint))
    ;; In a real implementation, this would verify the signature
    ;; For this demo, we'll return true
    true
)

;; Batch transaction execution
(define-public (execute-batch-gasless-tx
    (transactions (list 5 {
        user: principal,
        function-name: (string-ascii 64),
        args: (list 10 uint),
        nonce: uint,
        expiry: uint,
        gas-limit: uint,
        signature: (buff 65)
    })))
    
    (let ((sponsor tx-sender))
        (asserts! (> (default-to u0 (map-get? sponsors sponsor)) u0) ERR-INVALID-SPONSOR)
        (ok (map execute-single-batch-tx transactions))
    )
)

(define-private (execute-single-batch-tx (tx-data {
    user: principal,
    function-name: (string-ascii 64),
    args: (list 10 uint),
    nonce: uint,
    expiry: uint,
    gas-limit: uint,
    signature: (buff 65)
}))
    (execute-gasless-tx 
        (get user tx-data)
        (get function-name tx-data)
        (get args tx-data)
        (get nonce tx-data)
        (get expiry tx-data)
        (get gas-limit tx-data)
        (get signature tx-data)
    )
)

;; Read-only functions
(define-read-only (get-sponsor-balance (sponsor principal))
    (default-to u0 (map-get? sponsors sponsor))
)

(define-read-only (get-user-nonce (user principal))
    (default-to u0 (map-get? user-nonces user))
)

(define-read-only (get-gas-usage (user principal))
    (default-to u0 (map-get? gas-costs user))
)

(define-read-only (is-transaction-executed (user principal) (nonce uint))
    (default-to false (map-get? relayed-txs { user: user, nonce: nonce }))
)

;; Admin functions
(define-public (set-contract-enabled (enabled bool))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
        (var-set contract-enabled enabled)
        (ok true)
    )
)

(define-public (set-min-sponsor-balance (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
        (asserts! (and (> amount u0) (<= amount u100000000)) ERR-INSUFFICIENT-FUNDS)
        (var-set min-sponsor-balance amount)
        (ok true)
    )
)

(define-public (emergency-withdraw (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
        (asserts! (and (> amount u0) (<= amount (stx-get-balance (as-contract tx-sender)))) ERR-INSUFFICIENT-FUNDS)
        (try! (as-contract (stx-transfer? amount tx-sender CONTRACT-OWNER)))
        (ok true)
    )
)