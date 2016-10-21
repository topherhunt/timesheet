# Work Tracker / Timesheet app

A "scratch-my-own-itch" simple timesheet and invoice management app.

The alpha is deployed on Heroku and free to sign up: [https://topher-timesheet.herokuapp.com/](https://topher-timesheet.herokuapp.com/)

Learn more about how it works here: [https://topher-timesheet.herokuapp.com//about](https://topher-timesheet.herokuapp.com//about)

Built using Rails, Jquery, Bootstrap, Mysql, sparse color, and duct tape. Currently deployed on Heroku with ClearDB.

## TODO

- Replace ExceptionNotification with Rollbar
- Switch to Postgres
- Store start & end times for each entry (not just date) so user can view a "timeline" of how they spent their day
- Detect user's local timezone; display all data in terms of that
- Allow user to delete a Project (currently causes problems with past invoices)
- Allow user to add notes on a Project or an Invoice
