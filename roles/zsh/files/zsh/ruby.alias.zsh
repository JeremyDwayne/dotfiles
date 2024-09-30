# Ruby App aliases
alias pru="brew services start postgresql && brew services start redis"
alias prd="brew services stop postgresql && brew services stop redis"

alias startapi="bundle exec puma -v -C config/puma.rb config.ru -p 7777"
alias startsidekiq="bundle exec sidekiq -r ./config/environment.rb -C ./config/sidekiq.yml"

alias resettestdb="RACK_ENV=test rake db:reset && RACK_ENV=test rake db:seed"
alias runalltests="RACK_ENV=test rake db:prepare; rspec"
alias tests="./bin/env_update && RACK_ENV=test rake db:prepare; rspec"
alias rake="bundle exec rake"
alias rspec="bundle exec rspec"
alias rfail="bundle exec rspec --only-failures"
alias rc="bundle exec rubocop --disable-pending-cops"
alias dev="./bin/dev"
