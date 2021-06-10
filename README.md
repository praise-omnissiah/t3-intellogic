# commands
- docker-compose up -d
- ./my-script.sh create
- ./my-script.sh autoinsert (use .sql in postgresql for testing)
- ./my-script.sh migrate-10 (not working)
- ./my-script.sh clean (remove volumes&containers)
- docker-compose down

# TO DO
## migrate-10
1. Multiply Costs.price x 10 
2. need to output file .sql to mysql container; use connection string w/ straight to mysql server? 
3. Remove creds from .sh 
