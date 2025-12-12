;; Spray Contract Tests
;; Tests for the claim-based airdrop functionality

;; ============================================
;; Test: Admin can set claim amount
;; ============================================
(define-public (test-set-claim-amount)
  (let (
    (result (contract-call? .spray set-claim-amount u1000000))
  )
    (asserts! (is-ok result) (err "set-claim-amount should succeed"))
    (asserts! (is-eq (contract-call? .spray get-claim-amount) u1000000) (err "claim amount should be 1000000"))
    (ok true)))

;; ============================================
;; Test: Admin can set claim window
;; ============================================
(define-public (test-set-claim-window)
  (let (
    ;; Set window from block 0 to block 999999
    (result (contract-call? .spray set-claim-window u0 u999999))
  )
    (asserts! (is-ok result) (err "set-claim-window should succeed"))
    (let ((window (contract-call? .spray get-claim-window)))
      (asserts! (is-eq (get start window) u0) (err "start block should be 0"))
      (asserts! (is-eq (get end window) u999999) (err "end block should be 999999")))
    (ok true)))

;; ============================================
;; Test: Invalid window (start >= end) should fail
;; ============================================
(define-public (test-invalid-window-fails)
  (let (
    (result (contract-call? .spray set-claim-window u5000 u1000))
  )
    (asserts! (is-eq result (err u405)) (err "should fail with err-invalid-window"))
    (ok true)))

;; ============================================
;; Test: Set token contract
;; ============================================
(define-public (test-set-token-contract)
  (let (
    (result (contract-call? .spray set-token-contract .spray-token none))
  )
    (asserts! (is-ok result) (err "set-token-contract should succeed"))
    (asserts! (is-some (contract-call? .spray get-token-contract)) (err "token should be set"))
    (ok true)))

;; ============================================
;; Test: Read-only functions return correct values
;; ============================================
(define-public (test-read-only-functions)
  (begin
    ;; Setup
    (unwrap! (contract-call? .spray set-claim-amount u500000) (err "set amount failed"))
    (unwrap! (contract-call? .spray set-claim-window u100 u999999) (err "set window failed"))

    ;; Test get-claim-amount
    (asserts! (is-eq (contract-call? .spray get-claim-amount) u500000)
              (err "get-claim-amount should return 500000"))

    ;; Test get-claim-window
    (let ((window (contract-call? .spray get-claim-window)))
      (asserts! (is-eq (get start window) u100) (err "window start should be 100"))
      (asserts! (is-eq (get end window) u999999) (err "window end should be 999999")))

    ;; Test has-claimed for unclaimed user
    (asserts! (not (contract-call? .spray has-claimed 'ST1J4G6RR643BCG8G8SR6M2D9Z9KXT2NJDRK3FBTK))
              (err "random address should not have claimed"))

    ;; Test get-owner returns deployer
    (asserts! (is-eq (contract-call? .spray get-owner) tx-sender)
              (err "deployer should be owner"))

    (ok true)))
