PROJECT_NAME=nexa1024.github.io

info:
	@echo -e "PROJECT_NAME Info:$(PROJECT_NAME)"

############################ Git ###############################

status:
	git status

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

############### combined ###############

publish: commit push

sync:
	@if [ -z "$(branch)" ]; then \
		echo "Error: branch name is required. Usage: make sync branch='your-branch-name'"; \
		exit 1; \
	fi
	git checkout main
	git pull origin main
	git checkout $(branch)
	git merge main
	git push origin $(branch)

sync-all:
	@echo "Syncing all branches with main..."
	git checkout main
	git pull origin main
	@for branch in $$((git branch --format='%(refname:short)' | grep -v "^main$$") 2>/dev/null || echo ""); do \
		if [ -n "$$branch" ]; then \
			echo ""; \
			echo "========================================"; \
			echo "Syncing branch: $$branch"; \
			echo "========================================"; \
			git checkout $$branch && \
			git merge main -m "Sync with main" && \
			git push origin $$branch || \
			echo "Failed to sync $$branch"; \
		fi; \
	done
	git checkout main
	@echo ""
	@echo "All branches synced!"
