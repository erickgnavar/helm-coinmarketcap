# helm-coinmarketcap.el

## Usage

`M-x helm-coinmarketcap`

### Configuration

Change the variable `helm-coin-currency` to show the price in the desired currency.

```emacs-lisp
(setq helm-coinmarketcap-currency "PEN")
```

### Actions

- Open coin page in Coinmarketcap.
- Fetch json data from Coinmarketcap api and open a buffer with this data.
