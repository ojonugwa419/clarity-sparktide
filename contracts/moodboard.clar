;; SparkTide Moodboard NFT Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Define NFT
(define-non-fungible-token moodboard uint)

;; Data structures
(define-map moodboards
  uint 
  {
    owner: principal,
    title: (string-utf8 100),
    description: (string-utf8 500),
    items: (list 100 {
      id: uint,
      url: (string-utf8 200),
      position-x: uint,
      position-y: uint
    }),
    public: bool,
    created-at: uint
  }
)

(define-data-var last-token-id uint u0)

;; Create new moodboard
(define-public (create-moodboard (title (string-utf8 100)) (description (string-utf8 500)) (public bool))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
      (moodboard {
        owner: tx-sender,
        title: title,
        description: description,
        items: (list),
        public: public,
        created-at: block-height
      })
    )
    (try! (nft-mint? moodboard token-id tx-sender))
    (map-set moodboards token-id moodboard)
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

;; Add item to moodboard
(define-public (add-item (token-id uint) (url (string-utf8 200)) (pos-x uint) (pos-y uint))
  (let
    (
      (moodboard (unwrap! (map-get? moodboards token-id) (err err-not-found)))
      (new-item {
        id: (len (get items moodboard)),
        url: url,
        position-x: pos-x,
        position-y: pos-y
      })
    )
    (asserts! (is-authorized token-id) (err err-unauthorized))
    (map-set moodboards token-id (merge moodboard {
      items: (append (get items moodboard) new-item)
    }))
    (ok true)
  )
)

;; Remove item from moodboard
(define-public (remove-item (token-id uint) (item-id uint))
  (let
    ((moodboard (unwrap! (map-get? moodboards token-id) (err err-not-found))))
    (asserts! (is-authorized token-id) (err err-unauthorized))
    (ok true)
  )
)

;; Helper functions
(define-private (is-authorized (token-id uint))
  (let
    ((moodboard (unwrap! (map-get? moodboards token-id) false)))
    (or
      (is-eq tx-sender (get owner moodboard))
      (contract-call? .collaboration is-collaborator token-id tx-sender)
    )
  )
)
