# Docker-Compose Commands
alias dce='docker-compose exec --user $(id -u):$(id -g)'
alias dc='docker-compose'

# Docker Aliases
alias dc-dev-b='docker-compose -f docker/dev/docker-compose.yml build api_dev'
alias dc-dev-u='docker-compose -f docker/dev/docker-compose.yml up api_dev'
alias dc-dev-r='docker-compose -f docker/dev/docker-compose.yml run api_dev'
alias dc-dev-e='docker-compose -f docker/dev/docker-compose.yml exec api_dev'
 
alias dc-test-b='docker-compose -f docker/test/docker-compose.yml build api_test'
alias dc-test-u='docker-compose -f docker/test/docker-compose.yml up api_test'
alias dc-test-r='docker-compose -f docker/test/docker-compose.yml run api_test'
alias dc-test-e='docker-compose -f docker/test/docker-compose.yml exec api_test'

