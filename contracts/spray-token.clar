;; Spray Token - Simple FT for testing the Spray contract
;; SIP-010 compliant fungible token

;; ============================================
;; Token Definition
;; ============================================
(define-fungible-token spray-token)

;; ============================================
;; Constants
;; ============================================
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))

;; ============================================
;; SIP-010 Functions
;; ============================================

;; Transfer tokens
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (match memo
      memo-data (begin (print memo-data) true)
      true)
    (ft-transfer? spray-token amount sender recipient)))

;; Get token name
(define-read-only (get-name)
  (ok "Spray Token"))

;; Get token symbol
(define-read-only (get-symbol)
  (ok "SPRAY"))

;; Get token decimals
(define-read-only (get-decimals)
  (ok u6))

;; Get balance of a principal
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance spray-token who)))

;; Get total supply
(define-read-only (get-total-supply)
  (ok (ft-get-supply spray-token)))

;; Get token URI (metadata)
(define-read-only (get-token-uri)
  (ok none))

;; ============================================
;; Admin Functions (for testing)
;; ============================================

;; Mint tokens to a recipient (owner only)
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ft-mint? spray-token amount recipient)))

;; Burn tokens from a holder
(define-public (burn (amount uint) (holder principal))
  (begin
    (asserts! (is-eq tx-sender holder) err-not-token-owner)
    (ft-burn? spray-token amount holder)))
