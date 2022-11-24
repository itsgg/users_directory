# frozen_string_literal: true

require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/namespace'
require './model/users'

set :database, { adapter: 'sqlite3', database: './db/users.sqlite3' }

namespace '/api/v1' do # rubocop:disable Metrics/BlockLength
  before { content_type 'application/json' }

  helpers do
    def json_params
      @json_params ||= JSON.parse(request.body.read)
    rescue StandardError
      halt 400, { message: 'Invalid JSON' }.to_json
    end

    def authenticate!
      user = User.find_by(token: env['HTTP_AUTHORIZATION'].split(' ').last) if env['HTTP_AUTHORIZATION']
      halt 401, { message: 'Unauthorized' }.to_json unless user
    end
  end

  post '/login' do
    user = User.find_by(email: json_params['email'])
    if user&.authenticate(json_params['password'])
      user.generate_token!
      { token: user.token }.to_json
    else
      halt 401, { message: 'Unauthorized' }.to_json
    end
  end

  get '/users' do
    User.all.to_json
  end

  get '/users/:id' do
    user = User.find_by(id: params[:id])
    halt 404, { message: 'User not found' }.to_json unless user
    user.to_json
  end

  post '/users' do
    authenticate!
    user = User.new(json_params)
    if user.save
      user.to_json
    else
      halt 422, { message: user.errors.full_messages.join(', ') }.to_json
    end
    user.to_json
  end

  patch '/users/:id' do
    authenticate!
    user = User.find_by(id: params[:id])
    halt 404, { message: 'User not found' }.to_json unless user
    if user.update(json_params)
      user.to_json
    else
      halt 422, { message: user.errors.full_messages.join(', ') }.to_json
    end
  end

  delete '/users/:id' do
    authenticate!
    user = User.find_by(id: params[:id])
    halt 404, { message: 'User not found' }.to_json unless user
    if user.destroy
      user.to_json
    else
      halt 422, { message: user.errors.full_messages.join(', ') }.to_json
    end
  end
end
