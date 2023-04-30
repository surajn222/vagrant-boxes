run-docker:
	#-docker run --name postgresql -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres
	-echo "Build"
	-docker build . -t postgres-9
	-echo "Run"
	-docker run -p 5432:5432 -d postgres-9
	-docker run --name postgresql-2 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres-9
	-echo "Run command psql -h localhost -U postgres"
	-echo "check password in Dockerfile"
	-echo "Run \l to list all databases"
	-echo "Run \dt+ to list all tables"