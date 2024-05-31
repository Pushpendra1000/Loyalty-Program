# README

This README would normally document whatever steps are necessary to get the
application up and running.

## Requirements
  - Ruby 3.1.2
  - Rails 7.0.4
  - Libraries: bundler

## Dependencies
  - `bundle install`
  - `bundle exec sidekiq`
  - `redis-server`

## Configuration and setup
  - Set database username and password in 'credentials.yml.enc':
    `EDITOR='code --wait' bin/rails credentials:edit`
  - Create and setup the database:
    `bundle exec rake db:create`
    `bundle exec rake db:setup`

## Run
  - Start server
    `bundle exec rails s`
  - Background Jobs
    `bundle exec clockwork clock.rb`

## Test Cases
  - To run the test cases run `bundle exec rspec`
