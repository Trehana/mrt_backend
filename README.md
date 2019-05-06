# Singapore MRT Backend API

The API is based on Rails 5 API to find and display one or more routes from a specified origin to a specified destination, ordered by Shortest Path and Time consideration

## Setting up Rails 5

First, make sure you are running Ruby 2.2.2+ or newer as it’s required by Rails 5.

* Ruby version
This application was built on Ruby 2.6.2

## How to run
* Download the zip file from google drive
* or Clone source from github: `https://github.com/Trehana/mrt_backend.git`*
```
cd mrt_backend
bundle install

* Database creation
rake db:setup 

*Create a new user to get token, type command `rails c`*
```ruby
u = User.create({name: "Trehana Fernando", email: "test@gmail.com"})
ap u
```
*next typing*
```
rails s
```
*then run in `Terminal`*
```ruby
# with [token] that taken on rails console
curl -H "Authorization: Token token=[token]" http://localhost:3000/v1/users
```
*example*
```
curl -H "Authorization: Token token=3Hu9orST5sKDHUPJBwjbogtt" http://localhost:3000/v1/users
```
* System dependencies
Rails 5.1.7

* API Documentation
I have used Rails-based REST API using Swagger UI
Launch a web browser and go to `http://localhost:3000/docs`


* How to run the test suite 
I have used rspec for testing
cd mrt_backend
rake spec

* Addtional Configurations Used
## Serializing API Output
To control what data gets served through the API i have used Active Model Serializers
```
gem 'active_model_serializers'
```
I have serialized User Model

## Enabling CORS
To enable Cross-Origin Resource Sharing (CORS), in order to make cross-origin AJAX requests possible
I have added 
```ruby
gem 'rack-cors'
```

## Rate Limiting and Throttling
To protect API from DDoS, brute force attacks. I have used `Rack::Attack`

```ruby
gem 'rack-attack'
```
