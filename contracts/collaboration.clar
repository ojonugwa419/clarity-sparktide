;; SparkTide Collaboration Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-invalid-permission (err u101))

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
    ((owner (unwrap! (contract-call? .moodboard get-owner token-id) err-unauthorized)))
    (asserts! (is-eq tx-sender owner) (err err-unauthorized))
    (asserts! (and (>= permission PERMISSION-VIEW) (<= permission PERMISSION-ADMIN)) (err err-invalid-permission))
    (ok (map-set collaborators { token-id: token-id, user: user } { permission: permission }))
  )
)

;; Remove collaborator
(define-public (remove-collaborator (token-id uint) (user principal))
  (let
    ((owner (unwrap! (contract-call? .moodboard get-owner token-id) err-unauthorized)))
    (asserts! (is-eq tx-sender owner) (err err-unauthorized))
    (ok (map-delete collaborators { token-id: token-id, user: user }))
  )
)

;; Get collaborator permission
(define-read-only (get-permission (token-id uint) (user principal))
  (default-to 
    u0
    (get permission (map-get? collaborators { token-id: token-id, user: user }))
  )
)

;; Check if user is collaborator
(define-read-only (is-collaborator (token-id uint) (user principal))
  (default-to 
    false
    (map-get? collaborators { token-id: token-id, user: user })
  )
)
