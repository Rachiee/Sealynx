;; Tokenized Data Marketplace
;; Enables the buying, selling, and licensing of data sets with
;; privacy controls and usage tracking

;; Define SIP-010 token trait (using a more generic approach)
(define-trait sip-010-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals () (response uint uint))
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response uint uint))
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-INVALID-PARAMS (err u102))
(define-constant ERR-ALREADY-EXISTS (err u103))
(define-constant ERR-INSUFFICIENT-FUNDS (err u104))
(define-constant ERR-EXPIRED (err u105))
(define-constant ERR-DISPUTED (err u106))
(define-constant ERR-INACTIVE (err u107))

;; Data asset registry
(define-map data-assets
  { asset-id: uint }
  {
    title: (string-utf8 128),
    description: (string-utf8 1024),
    owner: principal,
    created-at: uint,
    data-type: (string-ascii 32),         ;; "dataset", "api", "stream", "model", "algorithm"
    category: (string-ascii 64),          ;; Industry/domain category
    preview-url: (optional (string-utf8 256)),
    metadata-url: (string-utf8 256),
    sample-data-url: (optional (string-utf8 256)),
    data-schema-url: (optional (string-utf8 256)),
    data-size-bytes: uint,
    content-hash: (buff 64),
    encryption-type: (string-ascii 32),   ;; "none", "symmetric", "asymmetric", "hybrid"
    update-frequency: (string-ascii 32),  ;; "static", "daily", "weekly", "monthly", "realtime"
    last-updated: uint,
    quality-score: (optional uint),       ;; 0-100 quality score
    verified: bool,
    active: bool,
    total-sales: uint,
    total-revenue: uint,
    royalty-percentage: uint              ;; Basis points (10000 = 100%)
  }
)

;; Data use licenses
(define-map license-types
  { license-id: uint }
  {
    name: (string-utf8 64),
    description: (string-utf8 512),
    creator: principal,
    created-at: uint,
    commercial-use: bool,
    derivative-works: bool,
    attribution-required: bool,
    share-alike: bool,
    revocable: bool,
    territory-restricted: bool,
    standard-code: (optional (string-ascii 16)),  ;; e.g., "CC-BY-4.0"
    license-url: (string-utf8 256),
    usage-limitations: (string-utf8 512),
    liability-terms: (string-utf8 512),
    privacy-terms: (string-utf8 512),
    active: bool
  }
)

;; Asset marketplace listings
(define-map marketplace-listings
  { listing-id: uint }
  {
    asset-id: uint,
    seller: principal,
    created-at: uint,
    price: uint,
    token-type: (string-ascii 8),          ;; "STX" or "SIP010"
    token-contract: (optional principal),
    license-id: uint,
    access-type: (string-ascii 16),        ;; "direct", "stream", "api", "compute"
    subscription-period: (optional uint),   ;; In blocks, if subscription-based
    max-buyers: (optional uint),            ;; Maximum number of buyers allowed, if limited
    georestrictions: (list 10 (string-ascii 2)), ;; Country codes of restricted regions
    active: bool,
    featured: bool,
    min-buyer-reputation: (optional uint),   ;; Minimum reputation required to purchase
    escrow-percentage: uint                  ;; Percentage of payment held in escrow
  }
)

;; Data purchases
(define-map purchases
  { purchase-id: uint }
  {
    listing-id: uint,
    buyer: principal,
    purchased-at: uint,
    amount-paid: uint,
    license-id: uint,
    access-key-hash: (buff 32),            ;; Hash of the access key
    encrypted-access-key: (buff 256),      ;; Encrypted access key for buyer
    expires-at: (optional uint),
    status: (string-ascii 16),             ;; "active", "expired", "revoked", "disputed"
    last-accessed: (optional uint),
    usage-count: uint,
    subscription-auto-renew: (optional bool),
    revocation-reason: (optional (string-utf8 256))
  }
)

;; Data access logs
(define-map access-logs
  { purchase-id: uint, log-id: uint }
  {
    buyer: principal,
    timestamp: uint,
    access-method: (string-ascii 16),      ;; "download", "api", "stream", "compute"
    query-parameters: (optional (string-utf8 256)),
    data-subset: (optional (string-utf8 256)),
    ip-hash: (optional (buff 32)),
    transaction-hash: (buff 32),
    success: bool,
    error-message: (optional (string-utf8 256))
  }
)

;; Reputation scores
(define-map reputation-scores
  { user: principal }
  {
    seller-score: uint,                     ;; 0-100 seller reputation
    buyer-score: uint,                      ;; 0-100 buyer reputation
    data-quality-score: uint,               ;; 0-100 data quality score
    disputes-initiated: uint,
    disputes-lost: uint,
    total-sales: uint,
    total-purchases: uint,
    average-data-quality: uint,
    total-reviews: uint,
    verified-identity: bool
  }
)

;; Reviews
(define-map reviews
  { reviewer: principal, asset-id: uint }
  {
    rating: uint,                           ;; 1-5 stars
    review-text: (string-utf8 512),
    submitted-at: uint,
    purchase-id: uint,
    data-quality-rating: uint,              ;; 1-5 stars
    accuracy-rating: uint,                  ;; 1-5 stars
    completeness-rating: uint,              ;; 1-5 stars
    usefulness-rating: uint,                ;; 1-5 stars
    verified-purchase: bool,
    upvotes: uint,
    downvotes: uint
  }
)

;; Data disputes
(define-map data-disputes
  { dispute-id: uint }
  {
    purchase-id: uint,
    initiator: principal,
    respondent: principal,
    initiated-at: uint,
    reason: (string-utf8 512),
    evidence-hash: (buff 32),
    status: (string-ascii 16),              ;; "open", "resolved", "cancelled"
    resolution: (optional (string-utf8 512)),
    resolved-at: (optional uint),
    resolver: (optional principal),
    buyer-refund-percentage: (optional uint),
    appeal-deadline: (optional uint),
    appealed: bool
  }
)

;; Escrow funds
(define-map escrow-funds
  { purchase-id: uint }
  {
    amount: uint,
    seller: principal,
    buyer: principal,
    release-conditions: (string-utf8 256),
    release-at: (optional uint),
    released: bool,
    disputed: bool
  }
)

;; Data validators
(define-map data-validators
  { validator: principal }
  {
    name: (string-utf8 64),
    description: (string-utf8 512),
    specialties: (list 10 (string-ascii 32)),
    fee-percentage: uint,                   ;; Basis points
    validations-completed: uint,
    average-rating: uint,                   ;; 0-100 rating
    registered-at: uint,
    active: bool
  }
)

;; Validation reports
(define-map validation-reports
  { asset-id: uint, validator: principal }
  {
    report-hash: (buff 32),
    submitted-at: uint,
    quality-score: uint,                    ;; 0-100 score
    accuracy-score: uint,                   ;; 0-100 score
    completeness-score: uint,               ;; 0-100 score
    consistency-score: uint,                ;; 0-100 score
    methodology: (string-utf8 256),
    issues-found: (list 10 (string-utf8 128)),
    recommendations: (string-utf8 512),
    certification-level: (string-ascii 16), ;; "basic", "standard", "premium"
    certification-valid-until: (optional uint)
  }
)

;; Data categories
(define-map data-categories
  { category-id: uint }
  {
    name: (string-ascii 64),
    description: (string-utf8 256),
    parent-category: (optional uint),
    created-at: uint,
    asset-count: uint,
    popularity-score: uint,                 ;; Calculated score based on activity
    trending: bool                          ;; Whether category is trending
  }
)

;; Next available IDs
(define-data-var next-asset-id uint u1)
(define-data-var next-license-id uint u1)
(define-data-var next-listing-id uint u1)
(define-data-var next-purchase-id uint u1)
(define-data-var next-dispute-id uint u1)
(define-data-var next-category-id uint u1)
(define-map next-log-id { purchase-id: uint } { id: uint })

;; Protocol configuration
(define-data-var platform-fee-percentage uint u250)   ;; 2.5% platform fee
(define-data-var fee-recipient principal CONTRACT-OWNER)
(define-data-var dispute-resolution-fee uint u5000000)  ;; 5 STX
(define-data-var default-escrow-period uint u1440)      ;; Default escrow period in blocks
(define-data-var min-reputation-for-listing uint u30)   ;; Minimum reputation to create listings

;; Input validation functions
(define-private (validate-string-length (str (string-utf8 1024)) (max-len uint))
  (if (<= (len str) max-len)
    (ok true)
    ERR-INVALID-PARAMS
  )
)

(define-private (validate-ascii-length (str (string-ascii 64)) (max-len uint))
  (if (<= (len str) max-len)
    (ok true)
    ERR-INVALID-PARAMS
  )
)

(define-private (validate-buffer-length (buf (buff 256)) (max-len uint))
  (if (<= (len buf) max-len)
    (ok true)
    ERR-INVALID-PARAMS
  )
)

(define-private (validate-percentage (percentage uint))
  (if (<= percentage u10000)
    (ok true)
    ERR-INVALID-PARAMS
  )
)

(define-private (validate-rating (rating uint))
  (if (and (>= rating u1) (<= rating u5))
    (ok true)
    ERR-INVALID-PARAMS
  )
)

(define-private (validate-score (score uint))
  (if (<= score u100)
    (ok true)
    ERR-INVALID-PARAMS
  )
)

;; Additional validation functions for input sanitization
(define-private (validate-uint-range (value uint) (min-val uint) (max-val uint))
  (if (and (>= value min-val) (<= value max-val))
    (ok true)
    ERR-INVALID-PARAMS
  )
)

(define-private (validate-non-zero (value uint))
  (if (> value u0)
    (ok true)
    ERR-INVALID-PARAMS
  )
)

;; Update reputation based on review
(define-private (update-reputation-from-review (seller principal) (quality-rating uint))
  (let
    ((current-rep (default-to 
                    {
                      seller-score: u50,
                      buyer-score: u50,
                      data-quality-score: u50,
                      disputes-initiated: u0,
                      disputes-lost: u0,
                      total-sales: u0,
                      total-purchases: u0,
                      average-data-quality: u0,
                      total-reviews: u0,
                      verified-identity: false
                    }
                    (map-get? reputation-scores { user: seller }))))
    
    ;; Calculate new average quality score
    (let
      ((total-reviews (+ (get total-reviews current-rep) u1))
       (new-avg-quality (if (> (get total-reviews current-rep) u0)
                          (/ (+ (* (get average-data-quality current-rep) (get total-reviews current-rep)) 
                                (* quality-rating u20)) ;; Convert 1-5 to 0-100 scale
                             total-reviews)
                          (* quality-rating u20))))
      
      ;; Update reputation
      (map-set reputation-scores
        { user: seller }
        (merge current-rep
          {
            average-data-quality: new-avg-quality,
            total-reviews: total-reviews,
            data-quality-score: new-avg-quality
          }
        )
      )
      
      (ok true)
    )
  )
)

;; Update reputations based on dispute outcome
(define-private (update-reputation-from-dispute
                 (buyer principal)
                 (seller principal)
                 (buyer-refund-percentage uint))
  (let
    ((buyer-rep (default-to 
                  {
                    seller-score: u50,
                    buyer-score: u50,
                    data-quality-score: u50,
                    disputes-initiated: u0,
                    disputes-lost: u0,
                    total-sales: u0,
                    total-purchases: u0,
                    average-data-quality: u0,
                    total-reviews: u0,
                    verified-identity: false
                  }
                  (map-get? reputation-scores { user: buyer })))
     (seller-rep (default-to 
                   {
                     seller-score: u50,
                     buyer-score: u50,
                     data-quality-score: u50,
                     disputes-initiated: u0,
                     disputes-lost: u0,
                     total-sales: u0,
                     total-purchases: u0,
                     average-data-quality: u0,
                     total-reviews: u0,
                     verified-identity: false
                   }
                   (map-get? reputation-scores { user: seller }))))
    
    ;; Update buyer reputation
    (map-set reputation-scores
      { user: buyer }
      (merge buyer-rep
        {
          disputes-initiated: (+ (get disputes-initiated buyer-rep) u1),
          disputes-lost: (if (< buyer-refund-percentage u5000) 
                           (+ (get disputes-lost buyer-rep) u1)
                           (get disputes-lost buyer-rep))
        }
      )
    )
    
    ;; Update seller reputation
    (map-set reputation-scores
      { user: seller }
      (merge seller-rep
        {
          disputes-lost: (if (> buyer-refund-percentage u5000)
                           (+ (get disputes-lost seller-rep) u1)
                           (get disputes-lost seller-rep))
        }
      )
    )
    
    (ok true)
  )
)

;; Create an escrow for a purchase
(define-private (create-escrow
                (purchase-id uint)
                (seller principal)
                (buyer principal)
                (amount uint))
  (begin
    ;; Validate inputs
    (asserts! (> purchase-id u0) ERR-INVALID-PARAMS)
    (asserts! (> amount u0) ERR-INVALID-PARAMS)
    
    (map-set escrow-funds
      { purchase-id: purchase-id }
      {
        amount: amount,
        seller: seller,
        buyer: buyer,
        release-conditions: u"Automatic release after escrow period if no disputes",
        release-at: (some (+ block-height (var-get default-escrow-period))),
        released: false,
        disputed: false
      }
    )
    
    (ok true)
  )
)

;; Resolve escrow based on dispute resolution
(define-private (resolve-escrow (purchase-id uint) (buyer-refund-percentage uint))
  (let
    ((escrow (unwrap! (map-get? escrow-funds { purchase-id: purchase-id }) ERR-NOT-FOUND)))
    
    ;; Validate inputs
    (asserts! (> purchase-id u0) ERR-INVALID-PARAMS)
    (asserts! (<= buyer-refund-percentage u10000) ERR-INVALID-PARAMS)
    
    ;; Calculate amounts
    (let
      ((buyer-amount (/ (* (get amount escrow) buyer-refund-percentage) u10000))
       (seller-amount (- (get amount escrow) buyer-amount)))
      
      ;; Transfer to buyer if amount > 0
      (if (> buyer-amount u0)
          (unwrap! (as-contract (stx-transfer? buyer-amount tx-sender (get buyer escrow))) ERR-INVALID-PARAMS)
          true
      )
      
      ;; Transfer to seller if amount > 0
      (if (> seller-amount u0)
          (unwrap! (as-contract (stx-transfer? seller-amount tx-sender (get seller escrow))) ERR-INVALID-PARAMS)
          true
      )
      
      ;; Mark escrow as released
      (map-set escrow-funds
        { purchase-id: purchase-id }
        (merge escrow { released: true })
      )
      
      (ok true)
    )
  )
)

;; Register a new data asset
(define-public (register-data-asset
                (title (string-utf8 128))
                (description (string-utf8 1024))
                (data-type (string-ascii 32))
                (category (string-ascii 64))
                (metadata-url (string-utf8 256))
                (preview-url (optional (string-utf8 256)))
                (sample-data-url (optional (string-utf8 256)))
                (data-schema-url (optional (string-utf8 256)))
                (data-size-bytes uint)
                (content-hash (buff 64))
                (encryption-type (string-ascii 32))
                (update-frequency (string-ascii 32))
                (royalty-percentage uint))
  (let
    ((asset-id (var-get next-asset-id))
     ;; Sanitize inputs by validating them first
     (validated-title (begin (try! (validate-string-length title u128)) title))
     (validated-description (begin (try! (validate-string-length description u1024)) description))
     (validated-data-type (begin (try! (validate-ascii-length data-type u32)) data-type))
     (validated-category (begin (try! (validate-ascii-length category u64)) category))
     (validated-metadata-url (begin (try! (validate-string-length metadata-url u256)) metadata-url))
     (validated-content-hash (begin (try! (validate-buffer-length content-hash u64)) content-hash))
     (validated-encryption-type (begin (try! (validate-ascii-length encryption-type u32)) encryption-type))
     (validated-update-frequency (begin (try! (validate-ascii-length update-frequency u32)) update-frequency))
     (validated-royalty-percentage (begin (try! (validate-uint-range royalty-percentage u0 u3000)) royalty-percentage))
     (validated-data-size-bytes (begin (try! (validate-non-zero data-size-bytes)) data-size-bytes)))
    
    ;; Additional validation
    (asserts! (is-valid-data-type validated-data-type) ERR-INVALID-PARAMS)
    (asserts! (is-valid-encryption-type validated-encryption-type) ERR-INVALID-PARAMS)
    (asserts! (is-valid-update-frequency validated-update-frequency) ERR-INVALID-PARAMS)
    
    ;; Validate optional URLs
    (match preview-url
      url (try! (validate-string-length url u256))
      true
    )
    (match sample-data-url
      url (try! (validate-string-length url u256))
      true
    )
    (match data-schema-url
      url (try! (validate-string-length url u256))
      true
    )
    
    ;; Create the data asset using validated inputs
    (map-set data-assets
      { asset-id: asset-id }
      {
        title: validated-title,
        description: validated-description,
        owner: tx-sender,
        created-at: block-height,
        data-type: validated-data-type,
        category: validated-category,
        preview-url: preview-url,
        metadata-url: validated-metadata-url,
        sample-data-url: sample-data-url,
        data-schema-url: data-schema-url,
        data-size-bytes: validated-data-size-bytes,
        content-hash: validated-content-hash,
        encryption-type: validated-encryption-type,
        update-frequency: validated-update-frequency,
        last-updated: block-height,
        quality-score: none,
        verified: false,
        active: true,
        total-sales: u0,
        total-revenue: u0,
        royalty-percentage: validated-royalty-percentage
      }
    )
    
    ;; Increment asset ID counter
    (var-set next-asset-id (+ asset-id u1))
    
    (ok asset-id)
  )
)

;; Check if data type is valid
(define-private (is-valid-data-type (data-type (string-ascii 32)))
  (or (is-eq data-type "dataset")
      (or (is-eq data-type "api")
          (or (is-eq data-type "stream")
              (or (is-eq data-type "model")
                  (is-eq data-type "algorithm")))))
)

;; Check if encryption type is valid
(define-private (is-valid-encryption-type (encryption-type (string-ascii 32)))
  (or (is-eq encryption-type "none")
      (or (is-eq encryption-type "symmetric")
          (or (is-eq encryption-type "asymmetric")
              (is-eq encryption-type "hybrid"))))
)

;; Check if update frequency is valid
(define-private (is-valid-update-frequency (update-frequency (string-ascii 32)))
  (or (is-eq update-frequency "static")
      (or (is-eq update-frequency "daily")
          (or (is-eq update-frequency "weekly")
              (or (is-eq update-frequency "monthly")
                  (is-eq update-frequency "realtime")))))
)

;; Create a license type
(define-public (create-license-type
                (name (string-utf8 64))
                (description (string-utf8 512))
                (commercial-use bool)
                (derivative-works bool)
                (attribution-required bool)
                (share-alike bool)
                (revocable bool)
                (territory-restricted bool)
                (standard-code (optional (string-ascii 16)))
                (license-url (string-utf8 256))
                (usage-limitations (string-utf8 512))
                (liability-terms (string-utf8 512))
                (privacy-terms (string-utf8 512)))
  (let
    ((license-id (var-get next-license-id))
     ;; Sanitize inputs
     (validated-name (begin (try! (validate-string-length name u64)) name))
     (validated-description (begin (try! (validate-string-length description u512)) description))
     (validated-license-url (begin (try! (validate-string-length license-url u256)) license-url))
     (validated-usage-limitations (begin (try! (validate-string-length usage-limitations u512)) usage-limitations))
     (validated-liability-terms (begin (try! (validate-string-length liability-terms u512)) liability-terms))
     (validated-privacy-terms (begin (try! (validate-string-length privacy-terms u512)) privacy-terms)))
    
    ;; Validate optional standard code
    (match standard-code
      code (try! (validate-ascii-length code u16))
      true
    )
    
    ;; Create the license using validated inputs
    (map-set license-types
      { license-id: license-id }
      {
        name: validated-name,
        description: validated-description,
        creator: tx-sender,
        created-at: block-height,
        commercial-use: commercial-use,
        derivative-works: derivative-works,
        attribution-required: attribution-required,
        share-alike: share-alike,
        revocable: revocable,
        territory-restricted: territory-restricted,
        standard-code: standard-code,
        license-url: validated-license-url,
        usage-limitations: validated-usage-limitations,
        liability-terms: validated-liability-terms,
        privacy-terms: validated-privacy-terms,
        active: true
      }
    )
    
    ;; Increment license ID counter
    (var-set next-license-id (+ license-id u1))
    
    (ok license-id)
  )
)

;; Create a marketplace listing
(define-public (create-listing
                (asset-id uint)
                (price uint)
                (token-type (string-ascii 8))
                (token-contract (optional principal))
                (license-id uint)
                (access-type (string-ascii 16))
                (subscription-period (optional uint))
                (max-buyers (optional uint))
                (georestrictions (list 10 (string-ascii 2)))
                (min-buyer-reputation (optional uint))
                (escrow-percentage uint))
  (let
    ((asset (unwrap! (map-get? data-assets { asset-id: asset-id }) ERR-NOT-FOUND))
     (license (unwrap! (map-get? license-types { license-id: license-id }) ERR-NOT-FOUND))
     (listing-id (var-get next-listing-id))
     (seller-reputation (get-seller-reputation tx-sender))
     ;; Sanitize inputs
     (validated-asset-id (begin (try! (validate-non-zero asset-id)) asset-id))
     (validated-price (begin (try! (validate-non-zero price)) price))
     (validated-license-id (begin (try! (validate-non-zero license-id)) license-id))
     (validated-escrow-percentage (begin (try! (validate-percentage escrow-percentage)) escrow-percentage)))
    
    ;; Validate
    (asserts! (is-eq tx-sender (get owner asset)) ERR-UNAUTHORIZED)
    (asserts! (get active asset) ERR-INACTIVE)
    (asserts! (get active license) ERR-INACTIVE)
    (asserts! (is-valid-token-type token-type) ERR-INVALID-PARAMS)
    (asserts! (or (is-eq token-type "STX") (is-some token-contract)) ERR-INVALID-PARAMS)
    (asserts! (is-valid-access-type access-type) ERR-INVALID-PARAMS)
    (asserts! (>= seller-reputation (var-get min-reputation-for-listing)) ERR-UNAUTHORIZED)
    
    ;; Validate georestrictions list
    (asserts! (<= (len georestrictions) u10) ERR-INVALID-PARAMS)
    
    ;; Create the listing using validated inputs
    (map-set marketplace-listings
      { listing-id: listing-id }
      {
        asset-id: validated-asset-id,
        seller: tx-sender,
        created-at: block-height,
        price: validated-price,
        token-type: token-type,
        token-contract: token-contract,
        license-id: validated-license-id,
        access-type: access-type,
        subscription-period: subscription-period,
        max-buyers: max-buyers,
        georestrictions: georestrictions,
        active: true,
        featured: false,
        min-buyer-reputation: min-buyer-reputation,
        escrow-percentage: validated-escrow-percentage
      }
    )
    
    ;; Increment listing ID counter
    (var-set next-listing-id (+ listing-id u1))
    
    (ok listing-id)
  )
)

;; Get seller reputation score
(define-private (get-seller-reputation (seller principal))
  (default-to u0 (get seller-score (map-get? reputation-scores { user: seller })))
)

;; Check if token type is valid
(define-private (is-valid-token-type (token-type (string-ascii 8)))
  (or (is-eq token-type "STX")
      (is-eq token-type "SIP010"))
)

;; Check if access type is valid
(define-private (is-valid-access-type (access-type (string-ascii 16)))
  (or (is-eq access-type "direct")
      (or (is-eq access-type "stream")
          (or (is-eq access-type "api")
              (is-eq access-type "compute"))))
)

;; Purchase a data asset with STX
(define-public (purchase-data-stx (listing-id uint) (access-key-hash (buff 32)))
  (let
    ((listing (unwrap! (map-get? marketplace-listings { listing-id: listing-id }) ERR-NOT-FOUND))
     (asset (unwrap! (map-get? data-assets { asset-id: (get asset-id listing) }) ERR-NOT-FOUND))
     (license (unwrap! (map-get? license-types { license-id: (get license-id listing) }) ERR-NOT-FOUND))
     (purchase-id (var-get next-purchase-id))
     (price (get price listing))
     (buyer-reputation (get-buyer-reputation tx-sender))
     ;; Sanitize inputs
     (validated-listing-id (begin (try! (validate-non-zero listing-id)) listing-id))
     (validated-access-key-hash (begin (try! (validate-buffer-length access-key-hash u32)) access-key-hash)))
    
    ;; Validate
    (asserts! (get active listing) ERR-INACTIVE)
    (asserts! (get active asset) ERR-INACTIVE)
    (asserts! (is-eq (get token-type listing) "STX") ERR-INVALID-PARAMS)
    (asserts! (not (is-eq tx-sender (get seller listing))) ERR-UNAUTHORIZED)
    
    ;; Check buyer eligibility
    (match (get min-buyer-reputation listing)
      min-rep (asserts! (>= buyer-reputation min-rep) ERR-UNAUTHORIZED)
      true
    )
    
    ;; Calculate fees and amounts
    (let
      ((platform-fee (/ (* price (var-get platform-fee-percentage)) u10000))
       (escrow-amount (/ (* price (get escrow-percentage listing)) u10000))
       (immediate-release-amount (- (- price platform-fee) escrow-amount)))
      
      ;; Validate amounts
      (asserts! (>= price (+ platform-fee escrow-amount)) ERR-INSUFFICIENT-FUNDS)
      
      ;; Transfer STX from buyer
      (try! (stx-transfer? price tx-sender (as-contract tx-sender)))
      
      ;; Transfer platform fee
      (try! (as-contract (stx-transfer? platform-fee tx-sender (var-get fee-recipient))))
      
      ;; Calculate expiration if subscription-based
      (let
        ((expires-at (match (get subscription-period listing)
                       period (some (+ block-height period))
                       none)))
        
        ;; Create purchase record using validated inputs
        (map-set purchases
          { purchase-id: purchase-id }
          {
            listing-id: validated-listing-id,
            buyer: tx-sender,
            purchased-at: block-height,
            amount-paid: price,
            license-id: (get license-id listing),
            access-key-hash: validated-access-key-hash,
            encrypted-access-key: 0x,
            expires-at: expires-at,
            status: "active",
            last-accessed: none,
            usage-count: u0,
            subscription-auto-renew: none,
            revocation-reason: none
          }
        )
        
        ;; Set up escrow if needed and transfer immediate funds to seller
        (begin
          ;; Handle escrow creation
          (if (> escrow-amount u0)
              (unwrap! (create-escrow purchase-id (get seller listing) tx-sender escrow-amount) ERR-INVALID-PARAMS)
              true
          )
          
          ;; Transfer immediate funds to seller
          (if (> immediate-release-amount u0)
              (unwrap! (as-contract (stx-transfer? immediate-release-amount tx-sender (get seller listing))) ERR-INVALID-PARAMS)
              true
          )
          
          ;; Initialize access log counter
          (map-set next-log-id { purchase-id: purchase-id } { id: u0 })
          
          ;; Update asset stats
          (map-set data-assets
            { asset-id: (get asset-id listing) }
            (merge asset 
              {
                total-sales: (+ (get total-sales asset) u1),
                total-revenue: (+ (get total-revenue asset) price)
              }
            )
          )
          
          ;; Increment purchase ID counter
          (var-set next-purchase-id (+ purchase-id u1))
          
          (ok purchase-id)
        )
      )
    )
  )
)

;; Get buyer reputation score
(define-private (get-buyer-reputation (buyer principal))
  (default-to u0 (get buyer-score (map-get? reputation-scores { user: buyer })))
)

;; Provide access key for purchased data
(define-public (provide-access-key
                (purchase-id uint)
                (encrypted-access-key (buff 256)))
  (let
    ((purchase (unwrap! (map-get? purchases { purchase-id: purchase-id }) ERR-NOT-FOUND))
     (listing (unwrap! (map-get? marketplace-listings { listing-id: (get listing-id purchase) }) ERR-NOT-FOUND))
     ;; Sanitize inputs
     (validated-purchase-id (begin (try! (validate-non-zero purchase-id)) purchase-id))
     (validated-encrypted-access-key (begin (try! (validate-buffer-length encrypted-access-key u256)) encrypted-access-key)))
    
    ;; Validate
    (asserts! (is-eq tx-sender (get seller listing)) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get status purchase) "active") ERR-INVALID-PARAMS)
    
    ;; Update purchase with access key using validated inputs
    (map-set purchases
      { purchase-id: validated-purchase-id }
      (merge purchase { encrypted-access-key: validated-encrypted-access-key })
    )
    
    (ok true)
  )
)

;; Log data access
(define-public (log-data-access
                (purchase-id uint)
                (access-method (string-ascii 16))
                (query-parameters (optional (string-utf8 256)))
                (data-subset (optional (string-utf8 256)))
                (ip-hash (optional (buff 32)))
                (transaction-hash (buff 32))
                (success bool)
                (error-message (optional (string-utf8 256))))
  (let
    ((purchase (unwrap! (map-get? purchases { purchase-id: purchase-id }) ERR-NOT-FOUND))
     (listing (unwrap! (map-get? marketplace-listings { listing-id: (get listing-id purchase) }) ERR-NOT-FOUND))
     (asset (unwrap! (map-get? data-assets { asset-id: (get asset-id listing) }) ERR-NOT-FOUND))
     (log-counter (unwrap! (map-get? next-log-id { purchase-id: purchase-id }) ERR-NOT-FOUND))
     (log-id (get id log-counter))
     ;; Sanitize inputs
     (validated-purchase-id (begin (try! (validate-non-zero purchase-id)) purchase-id))
     (validated-transaction-hash (begin (try! (validate-buffer-length transaction-hash u32)) transaction-hash)))
    
    ;; Validate
    (asserts! (or (is-eq tx-sender (get buyer purchase))
                 (is-eq tx-sender (get seller listing))) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get status purchase) "active") ERR-INVALID-PARAMS)
    (asserts! (is-valid-access-method access-method) ERR-INVALID-PARAMS)
    
    ;; Validate optional parameters
    (match query-parameters
      params (try! (validate-string-length params u256))
      true
    )
    (match data-subset
      subset (try! (validate-string-length subset u256))
      true
    )
    (match ip-hash
      hash (try! (validate-buffer-length hash u32))
      true
    )
    (match error-message
      msg (try! (validate-string-length msg u256))
      true
    )
    
    ;; Check if expired for subscription
    (match (get expires-at purchase)
      expiry (asserts! (< block-height expiry) ERR-EXPIRED)
      true
    )
    
    ;; Create access log using validated inputs
    (map-set access-logs
      { purchase-id: validated-purchase-id, log-id: log-id }
      {
        buyer: (get buyer purchase),
        timestamp: block-height,
        access-method: access-method,
        query-parameters: query-parameters,
        data-subset: data-subset,
        ip-hash: ip-hash,
        transaction-hash: validated-transaction-hash,
        success: success,
        error-message: error-message
      }
    )
    
    ;; Update purchase usage stats
    (map-set purchases
      { purchase-id: validated-purchase-id }
      (merge purchase 
        {
          last-accessed: (some block-height),
          usage-count: (+ (get usage-count purchase) u1)
        }
      )
    )
    
    ;; Increment log counter
    (map-set next-log-id
      { purchase-id: validated-purchase-id }
      { id: (+ log-id u1) }
    )
    
    (ok log-id)
  )
)

;; Check if access method is valid
(define-private (is-valid-access-method (access-method (string-ascii 16)))
  (or (is-eq access-method "download")
      (or (is-eq access-method "api")
          (or (is-eq access-method "stream")
              (is-eq access-method "compute"))))
)

;; Submit a review for a data asset
(define-public (submit-review
                (asset-id uint)
                (rating uint)
                (review-text (string-utf8 512))
                (purchase-id uint)
                (data-quality-rating uint)
                (accuracy-rating uint)
                (completeness-rating uint)
                (usefulness-rating uint))
  (let
    ((asset (unwrap! (map-get? data-assets { asset-id: asset-id }) ERR-NOT-FOUND))
     (purchase (unwrap! (map-get? purchases { purchase-id: purchase-id }) ERR-NOT-FOUND))
     ;; Sanitize inputs
     (validated-asset-id (begin (try! (validate-non-zero asset-id)) asset-id))
     (validated-rating (begin (try! (validate-rating rating)) rating))
     (validated-review-text (begin (try! (validate-string-length review-text u512)) review-text))
     (validated-purchase-id (begin (try! (validate-non-zero purchase-id)) purchase-id))
     (validated-data-quality-rating (begin (try! (validate-rating data-quality-rating)) data-quality-rating))
     (validated-accuracy-rating (begin (try! (validate-rating accuracy-rating)) accuracy-rating))
     (validated-completeness-rating (begin (try! (validate-rating completeness-rating)) completeness-rating))
     (validated-usefulness-rating (begin (try! (validate-rating usefulness-rating)) usefulness-rating)))
    
    ;; Validate
    (asserts! (is-eq tx-sender (get buyer purchase)) ERR-UNAUTHORIZED)
    
    ;; Check if review already exists
    (asserts! (is-none (map-get? reviews { reviewer: tx-sender, asset-id: validated-asset-id })) ERR-ALREADY-EXISTS)
    
    ;; Create the review using validated inputs
    (map-set reviews
      { reviewer: tx-sender, asset-id: validated-asset-id }
      {
        rating: validated-rating,
        review-text: validated-review-text,
        submitted-at: block-height,
        purchase-id: validated-purchase-id,
        data-quality-rating: validated-data-quality-rating,
        accuracy-rating: validated-accuracy-rating,
        completeness-rating: validated-completeness-rating,
        usefulness-rating: validated-usefulness-rating,
        verified-purchase: true,
        upvotes: u0,
        downvotes: u0
      }
    )
    
    ;; Update reputation scores using validated input
    (unwrap! (update-reputation-from-review (get owner asset) validated-data-quality-rating) ERR-INVALID-PARAMS)
    
    (ok true)
  )
)

;; Register as a data validator
(define-public (register-validator
                (name (string-utf8 64))
                (description (string-utf8 512))
                (specialties (list 10 (string-ascii 32)))
                (fee-percentage uint))
  (let
    (;; Sanitize inputs
     (validated-name (begin (try! (validate-string-length name u64)) name))
     (validated-description (begin (try! (validate-string-length description u512)) description))
     (validated-fee-percentage (begin (try! (validate-uint-range fee-percentage u0 u3000)) fee-percentage)))
    
    ;; Validate parameters
    (asserts! (> (len specialties) u0) ERR-INVALID-PARAMS)
    (asserts! (<= (len specialties) u10) ERR-INVALID-PARAMS)
    
    ;; Check if already registered
    (asserts! (is-none (map-get? data-validators { validator: tx-sender })) ERR-ALREADY-EXISTS)
    
    ;; Register the validator using validated inputs
    (map-set data-validators
      { validator: tx-sender }
      {
        name: validated-name,
        description: validated-description,
        specialties: specialties,
        fee-percentage: validated-fee-percentage,
        validations-completed: u0,
        average-rating: u0,
        registered-at: block-height,
        active: true
      }
    )
    
    (ok true)
  )
)

;; Submit validation report
(define-public (submit-validation-report
                (asset-id uint)
                (report-hash (buff 32))
                (quality-score uint)
                (accuracy-score uint)
                (completeness-score uint)
                (consistency-score uint)
                (methodology (string-utf8 256))
                (issues-found (list 10 (string-utf8 128)))
                (recommendations (string-utf8 512))
                (certification-level (string-ascii 16))
                (certification-valid-until (optional uint)))
  (let
    ((asset (unwrap! (map-get? data-assets { asset-id: asset-id }) ERR-NOT-FOUND))
     (validator-data (unwrap! (map-get? data-validators { validator: tx-sender }) ERR-UNAUTHORIZED))
     ;; Sanitize inputs
     (validated-asset-id (begin (try! (validate-non-zero asset-id)) asset-id))
     (validated-report-hash (begin (try! (validate-buffer-length report-hash u32)) report-hash))
     (validated-quality-score (begin (try! (validate-score quality-score)) quality-score))
     (validated-accuracy-score (begin (try! (validate-score accuracy-score)) accuracy-score))
     (validated-completeness-score (begin (try! (validate-score completeness-score)) completeness-score))
     (validated-consistency-score (begin (try! (validate-score consistency-score)) consistency-score))
     (validated-methodology (begin (try! (validate-string-length methodology u256)) methodology))
     (validated-recommendations (begin (try! (validate-string-length recommendations u512)) recommendations)))
    
    ;; Validate
    (asserts! (get active validator-data) ERR-INACTIVE)
    (asserts! (is-valid-certification-level certification-level) ERR-INVALID-PARAMS)
    (asserts! (<= (len issues-found) u10) ERR-INVALID-PARAMS)
    
    ;; Create validation report using validated inputs
    (map-set validation-reports
      { asset-id: validated-asset-id, validator: tx-sender }
      {
        report-hash: validated-report-hash,
        submitted-at: block-height,
        quality-score: validated-quality-score,
        accuracy-score: validated-accuracy-score,
        completeness-score: validated-completeness-score,
        consistency-score: validated-consistency-score,
        methodology: validated-methodology,
        issues-found: issues-found,
        recommendations: validated-recommendations,
        certification-level: certification-level,
        certification-valid-until: certification-valid-until
      }
    )
    
    ;; Update asset with quality score and verified status
    (map-set data-assets
      { asset-id: validated-asset-id }
      (merge asset 
        {
          quality-score: (some validated-quality-score),
          verified: true
        }
      )
    )
    
    ;; Update validator stats
    (map-set data-validators
      { validator: tx-sender }
      (merge validator-data 
        { validations-completed: (+ (get validations-completed validator-data) u1) }
      )
    )
    
    (ok true)
  )
)

;; Check if certification level is valid
(define-private (is-valid-certification-level (level (string-ascii 16)))
  (or (is-eq level "basic")
      (or (is-eq level "standard")
          (is-eq level "premium")))
)

;; File a dispute for a data purchase
(define-public (file-dispute
                (purchase-id uint)
                (reason (string-utf8 512))
                (evidence-hash (buff 32)))
  (let
    ((purchase (unwrap! (map-get? purchases { purchase-id: purchase-id }) ERR-NOT-FOUND))
     (listing (unwrap! (map-get? marketplace-listings { listing-id: (get listing-id purchase) }) ERR-NOT-FOUND))
     (dispute-id (var-get next-dispute-id))
     (escrow (map-get? escrow-funds { purchase-id: purchase-id }))
     ;; Sanitize inputs
     (validated-purchase-id (begin (try! (validate-non-zero purchase-id)) purchase-id))
     (validated-reason (begin (try! (validate-string-length reason u512)) reason))
     (validated-evidence-hash (begin (try! (validate-buffer-length evidence-hash u32)) evidence-hash)))
    
    ;; Validate
    (asserts! (is-eq tx-sender (get buyer purchase)) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get status purchase) "active") ERR-INVALID-PARAMS)
    
    ;; Pay dispute filing fee
    (try! (stx-transfer? (var-get dispute-resolution-fee) tx-sender (var-get fee-recipient)))
    
    ;; Create the dispute using validated inputs
    (map-set data-disputes
      { dispute-id: dispute-id }
      {
        purchase-id: validated-purchase-id,
        initiator: tx-sender,
        respondent: (get seller listing),
        initiated-at: block-height,
        reason: validated-reason,
        evidence-hash: validated-evidence-hash,
        status: "open",
        resolution: none,
        resolved-at: none,
        resolver: none,
        buyer-refund-percentage: none,
        appeal-deadline: none,
        appealed: false
      }
    )
    
    ;; Mark escrow as disputed if exists
    (match escrow
      escrow-data (map-set escrow-funds
                    { purchase-id: validated-purchase-id }
                    (merge escrow-data { disputed: true })
                  )
      true
    )
    
    ;; Update purchase status
    (map-set purchases
      { purchase-id: validated-purchase-id }
      (merge purchase { status: "disputed" })
    )
    
    ;; Increment dispute ID counter
    (var-set next-dispute-id (+ dispute-id u1))
    
    (ok dispute-id)
  )
)

;; Resolve a dispute (simplified arbitration)
(define-public (resolve-dispute
                (dispute-id uint)
                (resolution (string-utf8 512))
                (buyer-refund-percentage uint))
  (let
    ((dispute (unwrap! (map-get? data-disputes { dispute-id: dispute-id }) ERR-NOT-FOUND))
     (purchase-id (get purchase-id dispute))
     (purchase (unwrap! (map-get? purchases { purchase-id: purchase-id }) ERR-NOT-FOUND))
     (escrow (map-get? escrow-funds { purchase-id: purchase-id }))
     ;; Sanitize inputs
     (validated-dispute-id (begin (try! (validate-non-zero dispute-id)) dispute-id))
     (validated-resolution (begin (try! (validate-string-length resolution u512)) resolution))
     (validated-buyer-refund-percentage (begin (try! (validate-percentage buyer-refund-percentage)) buyer-refund-percentage)))
    
    ;; Validate
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED) ;; Only contract owner can resolve disputes
    (asserts! (is-eq (get status dispute) "open") ERR-INVALID-PARAMS)
    
    ;; Update dispute using validated inputs
    (map-set data-disputes
      { dispute-id: validated-dispute-id }
      (merge dispute 
        {
          status: "resolved",
          resolution: (some validated-resolution),
          resolved-at: (some block-height),
          resolver: (some tx-sender),
          buyer-refund-percentage: (some validated-buyer-refund-percentage),
          appeal-deadline: (some (+ block-height u1440))  ;; 10 days to appeal
        }
      )
    )
    
    ;; If escrow exists, resolve based on decision
    (match escrow
      escrow-data (unwrap! (resolve-escrow purchase-id validated-buyer-refund-percentage) ERR-INVALID-PARAMS)
      true
    )
    
    ;; Update purchase status
    (map-set purchases
      { purchase-id: purchase-id }
      (merge purchase 
        { status: (if (is-eq validated-buyer-refund-percentage u10000) "revoked" "active") }
      )
    )
    
    ;; Update reputation scores based on outcome using validated input
    (unwrap! (update-reputation-from-dispute 
             (get initiator dispute)
             (get respondent dispute)
             validated-buyer-refund-percentage) ERR-INVALID-PARAMS)
    
    (ok true)
  )
)

;; Release escrow funds (after deadline if no disputes)
(define-public (release-escrow (purchase-id uint))
  (let
    ((escrow (unwrap! (map-get? escrow-funds { purchase-id: purchase-id }) ERR-NOT-FOUND))
     ;; Sanitize input
     (validated-purchase-id (begin (try! (validate-non-zero purchase-id)) purchase-id)))
    
    ;; Validate
    (asserts! (not (get released escrow)) ERR-INVALID-PARAMS)
    (asserts! (not (get disputed escrow)) ERR-DISPUTED)
    (asserts! (is-some (get release-at escrow)) ERR-INVALID-PARAMS)
    (asserts! (>= block-height (unwrap-panic (get release-at escrow))) ERR-INVALID-PARAMS)
    
    ;; Transfer full amount to seller
    (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get seller escrow))))
    
    ;; Mark escrow as released using validated input
    (map-set escrow-funds
      { purchase-id: validated-purchase-id }
      (merge escrow { released: true })
    )
    
    (ok true)
  )
)

;; Update a data asset
(define-public (update-data-asset
                (asset-id uint)
                (title (string-utf8 128))
                (description (string-utf8 1024))
                (metadata-url (string-utf8 256))
                (content-hash (buff 64))
                (data-size-bytes uint))
  (let
    ((asset (unwrap! (map-get? data-assets { asset-id: asset-id }) ERR-NOT-FOUND))
     ;; Sanitize inputs
     (validated-asset-id (begin (try! (validate-non-zero asset-id)) asset-id))
     (validated-title (begin (try! (validate-string-length title u128)) title))
     (validated-description (begin (try! (validate-string-length description u1024)) description))
     (validated-metadata-url (begin (try! (validate-string-length metadata-url u256)) metadata-url))
     (validated-content-hash (begin (try! (validate-buffer-length content-hash u64)) content-hash))
     (validated-data-size-bytes (begin (try! (validate-non-zero data-size-bytes)) data-size-bytes)))
    
    ;; Validate
    (asserts! (is-eq tx-sender (get owner asset)) ERR-UNAUTHORIZED)
    (asserts! (get active asset) ERR-INACTIVE)
    
    ;; Update the asset using validated inputs
    (map-set data-assets
      { asset-id: validated-asset-id }
      (merge asset 
        {
          title: validated-title,
          description: validated-description,
          metadata-url: validated-metadata-url,
          content-hash: validated-content-hash,
          data-size-bytes: validated-data-size-bytes,
          last-updated: block-height,
          verified: false,  ;; Reset verification on update
          quality-score: none
        }
      )
    )
    
    (ok true)
  )
)

;; Read-only functions

;; Get data asset details
(define-read-only (get-data-asset (asset-id uint))
  (ok (unwrap! (map-get? data-assets { asset-id: asset-id }) ERR-NOT-FOUND))
)

;; Get license details
(define-read-only (get-license (license-id uint))
  (ok (unwrap! (map-get? license-types { license-id: license-id }) ERR-NOT-FOUND))
)

;; Get marketplace listing
(define-read-only (get-listing (listing-id uint))
  (ok (unwrap! (map-get? marketplace-listings { listing-id: listing-id }) ERR-NOT-FOUND))
)

;; Get purchase details
(define-read-only (get-purchase (purchase-id uint))
  (ok (unwrap! (map-get? purchases { purchase-id: purchase-id }) ERR-NOT-FOUND))
)

;; Get validation report
(define-read-only (get-validation-report (asset-id uint) (validator principal))
  (ok (unwrap! (map-get? validation-reports { asset-id: asset-id, validator: validator }) ERR-NOT-FOUND))
)

;; Get user reputation
(define-read-only (get-reputation (user principal))
  (ok (default-to 
        {
          seller-score: u50,
          buyer-score: u50,
          data-quality-score: u50,
          disputes-initiated: u0,
          disputes-lost: u0,
          total-sales: u0,
          total-purchases: u0,
          average-data-quality: u0,
          total-reviews: u0,
          verified-identity: false
        }
        (map-get? reputation-scores { user: user })
      )
  )
)

;; Get validator details
(define-read-only (get-validator (validator principal))
  (ok (unwrap! (map-get? data-validators { validator: validator }) ERR-NOT-FOUND))
)

;; Get dispute details
(define-read-only (get-dispute (dispute-id uint))
  (ok (unwrap! (map-get? data-disputes { dispute-id: dispute-id }) ERR-NOT-FOUND))
)

;; Get escrow details
(define-read-only (get-escrow (purchase-id uint))
  (ok (unwrap! (map-get? escrow-funds { purchase-id: purchase-id }) ERR-NOT-FOUND))
)

;; Get review details
(define-read-only (get-review (reviewer principal) (asset-id uint))
  (ok (unwrap! (map-get? reviews { reviewer: reviewer, asset-id: asset-id }) ERR-NOT-FOUND))
)

;; Get access log
(define-read-only (get-access-log (purchase-id uint) (log-id uint))
  (ok (unwrap! (map-get? access-logs { purchase-id: purchase-id, log-id: log-id }) ERR-NOT-FOUND))
)

;; Check if a user has access to a specific data asset
(define-read-only (has-data-access (user principal) (asset-id uint))
  ;; This would check for active purchases by the user for the asset
  ;; Simplified implementation
  (ok false)
)

;; Get platform configuration
(define-read-only (get-platform-config)
  (ok {
    platform-fee-percentage: (var-get platform-fee-percentage),
    fee-recipient: (var-get fee-recipient),
    dispute-resolution-fee: (var-get dispute-resolution-fee),
    default-escrow-period: (var-get default-escrow-period),
    min-reputation-for-listing: (var-get min-reputation-for-listing)
  })
)

;; Admin functions (only contract owner)

;; Update platform fee
(define-public (set-platform-fee (new-fee uint))
  (let
    ((validated-new-fee (begin (try! (validate-uint-range new-fee u0 u1000)) new-fee)))
    
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (var-set platform-fee-percentage validated-new-fee)
    (ok true)
  )
)

;; Update fee recipient
(define-public (set-fee-recipient (new-recipient principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (var-set fee-recipient new-recipient)
    (ok true)
  )
)

;; Update dispute resolution fee
(define-public (set-dispute-fee (new-fee uint))
  (let
    ((validated-new-fee (begin (try! (validate-non-zero new-fee)) new-fee)))
    
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (var-set dispute-resolution-fee validated-new-fee)
    (ok true)
  )
)

;; Deactivate a data asset (emergency function)
(define-public (deactivate-asset (asset-id uint))
  (let
    ((asset (unwrap! (map-get? data-assets { asset-id: asset-id }) ERR-NOT-FOUND))
     (validated-asset-id (begin (try! (validate-non-zero asset-id)) asset-id)))
    
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    
    (map-set data-assets
      { asset-id: validated-asset-id }
      (merge asset { active: false })
    )
    
    (ok true)
  )
)

;; Deactivate a validator (emergency function)
(define-public (deactivate-validator (validator principal))
  (let
    ((validator-data (unwrap! (map-get? data-validators { validator: validator }) ERR-NOT-FOUND)))
    
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    
    (map-set data-validators
      { validator: validator }
      (merge validator-data { active: false })
    )
    
    (ok true)
  )
)
