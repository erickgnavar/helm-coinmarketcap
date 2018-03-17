;;; helm-coinmarketcap.el --- Search crypto currency prices and show them using helm

;; Copyright © 2018 Erick Navarro

;; Author: Erick Navarro <erick@navarro.io>
;; URL: https://github.com/erickgnavar/helm-coinmarketcap
;; Version: 1.0.0
;; Package-Requires: ((helm "0.0.0") (json-mode "1.6.0"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'url)
(require 'json)
(require 'helm)

(defconst helmcoin--coinmarketcap-url "https://api.coinmarketcap.com/v1/ticker/")
(defconst helmcoin--coinmarketcap-coin-site-url "https://coinmarketcap.com/currencies/")


(defun helmcoin--fetch-and-parse-json (url)
  "Fetch URL content and parse to alist."
  (with-current-buffer
      (url-retrieve-synchronously url)
    (goto-char url-http-end-of-headers)
    (json-read)))

(defun helmcoin--fetch-data ()
  "Fetch data from Coinmarketcap API."
  (helmcoin--fetch-and-parse-json helmcoin--coinmarketcap-url))

(defun helmcoin--format-coin (coin)
  "Format COIN information to show in helm results."
  (let ((name (cdr (assoc 'name coin)))
        (symbol (cdr (assoc 'symbol coin)))
        (rank (cdr (assoc 'rank coin)))
        (price-usd (cdr (assoc 'price_usd coin)))
        (market-cap-usd (cdr (assoc 'market_cap_usd coin))))
    (format "%s - %s Rank: %s\nPrice USD: %s\nMarket cap USD: %s"
            name
            symbol
            rank
            price-usd
            market-cap-usd)))

(defun helmcoin--candidates ()
  "Fetch data and converted to helm candidates."
  (mapcar '(lambda (coin)
             (cons (helmcoin--format-coin coin) coin)) (helmcoin--fetch-data)))

(defun helmcoin--open-in-browser (coin)
  "Open COIN page in coinmarketcap site."
  (browse-url (concat helmcoin--coinmarketcap-coin-site-url (cdr (assoc 'id coin)))))

(defun helmcoin--open-buffer-with-json-data (coin)
  "Open COIN page in coinmarketcap site."
  (let* ((url (concat helmcoin--coinmarketcap-url (cdr (assoc 'id coin))))
         (json-response (helmcoin--fetch-and-parse-json url))
         (new-buffer-name (format "%s.json" (cdr (assoc 'name coin)))))
    (switch-to-buffer (get-buffer-create new-buffer-name))
    (insert (json-reformat-from-string (json-encode json-response)))
    (json-mode)))

(defvar helmcoin--source nil)

(setq helmcoin--source
      '((name . "Coinmarketcap coins")
        (multiline)
        (candidates . helmcoin--candidates)
        (action . (("Open coin webpage" . helmcoin--open-in-browser)
                   ("Fetch json data and open buffer" . helmcoin--open-buffer-with-json-data)))))

(defun helm-coinmarketcap ()
  "Search cryptocurrencies in Coinmarketcap API."
  (interactive)
  (helm :sources '(helmcoin--source)))

(provide 'helm-coinmarketcap)

;;; helm-coinmarketcap.el ends here
