#!/bin/bash

# Check if admin user already exists
if ! gitlab-rails runner "puts User.where(admin: true).exists?"; then
  gitlab-rails runner "user = User.new(username: 'adminis', name: 'Adminis', email: 'adminis@grita.id', password: '@Dminis123', password_confirmation: '@Dminis123', admin: true); user.save!"
fi
