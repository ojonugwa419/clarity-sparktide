;; SparkTide Social Features Contract

;; Constants
(define-constant err-not-found (err u100))

;; Data structures
(define-map likes 
  { token-id: uint, user: principal }
  { created-at: uint }
)

(define-map comments
  uint
  {
    token-id: uint,
    user: principal,
    content: (string-utf8 500),
    created-at: uint
  }
)

(define-data-var last-comment-id uint u0)

;; Like/unlike moodboard
(define-public (toggle-like (token-id uint))
  (let
    ((key { token-id: token-id, user: tx-sender }))
    (if (map-get? likes key)
      (begin
        (map-delete likes key)
        (ok false)
      )
      (begin  
        (map-set likes key { created-at: block-height })
        (ok true)
      )
    )
  )
)

;; Add comment
(define-public (add-comment (token-id uint) (content (string-utf8 500)))
  (let
    (
      (comment-id (+ (var-get last-comment-id) u1))
      (comment {
        token-id: token-id,
        user: tx-sender,
        content: content,
        created-at: block-height
      })
    )
    (map-set comments comment-id comment)
    (var-set last-comment-id comment-id)
    (ok comment-id)
  )
)
