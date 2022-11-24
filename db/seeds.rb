# frozen_string_literal: true

User.create! name: 'Ganesh Gunasegaran', email: 'me@itsgg.com'
User.create! name: 'admin', email: 'admin@itsgg.com', admin: true, password: 'admin', password_confirmation: 'admin'
