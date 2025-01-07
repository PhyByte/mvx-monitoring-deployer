.PHONY: generate start refresh

# Define the generate task using the new shell script
generate:
	bash generate_config.sh

# Define the start task, which depends on generate
start: generate
	docker-compose up -d

# Define the refresh task, which also depends on generate
refresh: generate
	docker-compose down && docker-compose up -d