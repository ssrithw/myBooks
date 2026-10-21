
# myBooks - track the books you've read!

myBooks is a book tracker that lets you share your favourite books and discover new ones.
It was developed in partial fulfilment of CSP3341 Programming Languages and Paradigms.

## Setup

### Preliminary steps

This application was developed using Ubuntu 24.04 on WSL2 on Windows 11. As Rails is not well-supported on Windows, you may wish to do the same. To set up WSL, Ruby, Rails and PostgreSQL, please follow the steps in this guide: https://gorails.com/setup/windows/11 

You must have the following installed on your computer:

```
Ruby 3.4
Rails 8.1.4
PostgreSQL 16 or later
```

If you do not have PostgreSQL installed, please follow the steps below:

#### On Windows:

1) Download the installer from https://www.enterprisedb.com/downloads/postgres-postgresql-downloads

2) Follow the instructions to install PostgreSQL. Note down your username and password. A detailed guide may be found here https://www.w3schools.com/postgresql/postgresql_install.php 

#### On WSL and Linux:

1) Install PostgreSQL

```
sudo apt install postgresql libpq-dev
sudo service postgresql start
```

You will need to start PostgreSQL every time you load your WSL environment.

2) Create a user and password

```
sudo -u postgres createuser -s $USER
# optionally in WSL, create a password
sudo -u postgres psql
postgres=# \password $USER
```

### Setting up the application

#### On WSL and Linux

1) Navigate to the application folder

```cd your/path/myBooks```

2) Install the required gems

```
chmod +x bin/*  # this is not required, but run if you get a "Permission denied" error

# run these as normal
gem install bundler
bundle install
```

3) Create the database

```
bin/rails db:prepare
bin/rails db:seed
```

4) Start the application

```rails server```

By default, the application opens in http://localhost:3000 on your browser.

#### On Windows

1) Open a new PowerShell session

2) Navigate to the application folder 

```cd your/path/myBooks```

3) Install the required gems

```
gem install bundler
bundle install
```

4) Connect to the PostgreSQL database

```$env:DATABASE_URL = "postgres://postgres:YOUR_PASSWORD@localhost:5432"```

Replace YOUR_PASSWORD with your Postgres password. This only lasts for the current PowerShell session.

5) Create the database

```
ruby bin/rails db:prepare
ruby bin/rails db:seed
```

6) Start the application

```ruby bin/rails server```

By default, the application opens in http://localhost:3000 on your browser.
