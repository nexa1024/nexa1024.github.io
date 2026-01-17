PROJECT_NAME=nexa1024.github.io

info:
	@echo -e "PROJECT_NAME Info:$(PROJECT_NAME)"

############################ Git ###############################

############### checkout ###############
main:
	git checkout main

article:
	git checkout feat/article

fix:
	git checkout fix/somefunction

############### push ###############

commit:
	@if [ -z "$(msg)" ]; then \
		echo "Error: commit message is required. Usage: make commit msg='your commit message'"; \
		exit 1; \
	fi
	git add .
	git commit -m "$(msg)"

push:
	git push