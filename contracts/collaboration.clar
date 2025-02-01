;; SparkTide Collaboration Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))

;; Permission levels
(define-constant PERMISSION-VIEW u1)
(define-constant PERMISSION-EDIT u2)
(define-constant PERMISSION-ADMIN u3)

;; Data structures
(define-map collaborators
  { token-id: uint, user: principal }
  { permission: uint }
)

;; Add collaborator
(define-public (add-collaborator (token-id uint) (user principal) (permission uint))
  (let
    ((owner (contract-call? .moodboard get-owner token-id)))
    (asserts! (is-eq tx-sender owner) (err err-unauthorized))
    (ok (map-set collaborators { token-id: token-id, user: user } { permission: permission }))
  )
)

;; Check if user is collaborator
(define-read-only (is-collaborator (token-id uint) (user principal))
  (default-to 
    false
    (map-get? collaborators { token-id: token-id, user: user })
  )
)
