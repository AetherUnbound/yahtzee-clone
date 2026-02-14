DC := "docker compose "
set dotenv-load := false


default:
    @just -ul

# Run the static checks
lint:
    pre-commit run --all-files

# Build all containers
build: 
	{{ DC }} build

# Spin up all (or the specified) services
up *args:
	{{ DC }} up -d {{ args }}

# Tear down all services
down *args:
	{{ DC }} down {{ args }}

# Attach logs to all (or the specified) services
logs *args:
	{{ DC }} logs -f {{ args }}

# Pull all docker images
pull:
    {{ DC }} pull

# Pull and deploy all images
deploy:
    -git pull
    @just pull
    @just up

# Run a command on a provided service
run *args:
	{{ DC }} run --rm {{ args }}
