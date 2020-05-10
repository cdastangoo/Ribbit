# README

Using Rails version 2.5.7

To get started with this app on a local server, clone the repo then install the needed gems:
```
$ bundle install --without production
```

Next, migrate the database:
```
$ rails db:migrate
```

Finally, run the tst suite to verify everything is working:
```
$ rails test
```

If the test suite passes, you are ready to run the app locally:
```
$ rails server
```