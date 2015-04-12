# Work Tracker

### Heroku prep

- Ensure Glyphicon fonts compile correctly in production:
```
config.assets.precompile += %w( .woff .eot .svg .ttf )
config.assets.compile = true (from false)
```

- `heroku create`
- `git push heroku master`
- `heroku run rake db:migrate`
- `rake figaro:heroku`
- `heroku open` and test!
