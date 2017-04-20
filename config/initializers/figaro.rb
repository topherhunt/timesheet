# Won't allow app to start if these keys aren't defined
# See https://github.com/laserlemon/figaro#required-keys

Figaro.require_keys(
  "DEVISE_SECRET_KEY",
  "DEVISE_PEPPER",
  "HOSTNAME",
  "SUPPORT_EMAIL",
  "SMTP_HOST",
  "SMTP_USERNAME",
  "SMTP_PASSWORD",
  "ROLLBAR_ACCESS_TOKEN")
