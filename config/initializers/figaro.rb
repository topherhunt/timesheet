# Won't allow app to start if these keys aren't defined
# See https://github.com/laserlemon/figaro#required-keys

Figaro.require_keys(
  "HOSTNAME",
  "SUPPORT_EMAIL",
  "GMAIL_USERNAME",
  "GMAIL_PASSWORD",
  "DEVISE_SECRET_KEY",
  "DEVISE_PEPPER",
  "ROLLBAR_ACCESS_TOKEN")
