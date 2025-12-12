;; Spray/Airdrop Contract - Claim-based token distribution
;; Uses block-height for time windows (each block ~10 minutes on mainnet)

;; ============================================
;; Error Constants
;; ============================================
(define-constant err-owner-only (err u401))
(define-constant err-already-claimed (err u402))
(define-constant err-not-started (err u403))
(define-constant err-ended (err u404))
(define-constant err-invalid-window (err u405))
(define-constant err-transfer-failed (err u406))
(define-constant err-token-not-set (err u407))
(define-constant err-invalid-amount (err u409))

;; ============================================
;; Admin and Configuration
;; ============================================
(define-data-var owner principal tx-sender)
(define-data-var token-contract (optional principal) none)
(define-data-var claim-amount uint u0)
(define-data-var start-block uint u0)
(define-data-var end-block uint u0)
(define-data-var expected-token-hash (optional (buff 32)) none)

;; ============================================
;; Tracking Claims
;; ============================================
(define-map claimed principal bool)

;; ============================================
;; Private Functions
;; ============================================

;; Check if caller is owner
(define-private (is-owner)
  (is-eq tx-sender (var-get owner)))

;; ============================================
;; Public Functions - Admin
;; ============================================

;; Set the token contract for distribution
;; Stores optional hash for future verification
(define-public (set-token-contract (token principal) (maybe-hash (optional (buff 32))))
  (begin
    (asserts! (is-owner) err-owner-only)
    ;; Store hash if provided (for future verification)
    (match maybe-hash
      hash-value (var-set expected-token-hash (some hash-value))
      true)
    (var-set token-contract (some token))
    (ok true)))

;; Set the claim window (start and end as block heights)
(define-public (set-claim-window (start uint) (end uint))
  (begin
    (asserts! (is-owner) err-owner-only)
    (asserts! (< start end) err-invalid-window)
    (var-set start-block start)
    (var-set end-block end)
    (ok true)))

;; Set the amount each user can claim
(define-public (set-claim-amount (amount uint))
  (begin
    (asserts! (is-owner) err-owner-only)
    (asserts! (> amount u0) err-invalid-amount)
    (var-set claim-amount amount)
    (ok true)))

;; Transfer ownership to a new principal
(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-owner) err-owner-only)
    (var-set owner new-owner)
    (ok true)))

;; ============================================
;; Public Functions - Claims
;; ============================================

;; Claim tokens - users call this to receive their airdrop
(define-public (claim)
  (let (
    (claimer tx-sender)
    (amount (var-get claim-amount))
    (token-opt (var-get token-contract))
  )
    ;; Check token is configured
    (asserts! (is-some token-opt) err-token-not-set)

    ;; Check claim window using stacks-block-height
    (asserts! (>= stacks-block-height (var-get start-block)) err-not-started)
    (asserts! (<= stacks-block-height (var-get end-block)) err-ended)

    ;; Check user hasn't already claimed
    (asserts! (not (default-to false (map-get? claimed claimer))) err-already-claimed)

    ;; Transfer tokens from contract to claimer
    (unwrap! (as-contract (contract-call? .spray-token transfer amount tx-sender claimer none))
             err-transfer-failed)

    ;; Mark as claimed
    (map-set claimed claimer true)
    (ok true)))

;; Withdraw tokens back to a recipient (owner only)
(define-public (withdraw (amount uint) (recipient principal))
  (begin
    (asserts! (is-owner) err-owner-only)
    (asserts! (> amount u0) err-invalid-amount)

    ;; Transfer tokens from contract to recipient
    (unwrap! (as-contract (contract-call? .spray-token transfer amount tx-sender recipient none))
             err-transfer-failed)

    (ok true)))

;; ============================================
;; Read-Only Functions
;; ============================================

;; Get the configured token contract
(define-read-only (get-token-contract)
  (var-get token-contract))

;; Get the claim window as a tuple
(define-read-only (get-claim-window)
  { start: (var-get start-block), end: (var-get end-block) })

;; Get the claim amount
(define-read-only (get-claim-amount)
  (var-get claim-amount))

;; Check if a principal has already claimed
(define-read-only (has-claimed (who principal))
  (default-to false (map-get? claimed who)))

;; Check if claiming is currently active based on stacks-block-height
(define-read-only (is-claim-active)
  (let (
    (start (var-get start-block))
    (end (var-get end-block))
  )
    (and
      (is-some (var-get token-contract))
      (> (var-get claim-amount) u0)
      (>= stacks-block-height start)
      (<= stacks-block-height end))))

;; Get the current owner
(define-read-only (get-owner)
  (var-get owner))

;; Get the expected token hash (for verification)
(define-read-only (get-expected-token-hash)
  (var-get expected-token-hash))

;; Get current block height (useful for debugging)
(define-read-only (get-current-block)
  stacks-block-height)
