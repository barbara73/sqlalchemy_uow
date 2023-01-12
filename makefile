include .env

install:
	@echo "Installing..."
	@if [ "$(shell which poetry)" = "" ]; then \
		$(MAKE) install-poetry; \
	fi
	@if [ "$(shell which gpg)" = "" ]; then \
		echo "GPG not installed, so an error will occur. Install GPG on MacOS with "\
			"`brew install gnupg` or on Ubuntu with `apt install gnupg` and run "\
			"`make install` again."; \
	fi
	@$(MAKE) setup-poetry
	@$(MAKE) setup-environment-variables
	@$(MAKE) setup-git
	@$(MAKE) install-test


install-poetry:
	@echo "Installing poetry..."
	@curl -sSL https://install.python-poetry.org | python3 -
	@$(eval include ${HOME}/.poetry/env)

setup-poetry:
	@poetry env use python3 && poetry install

setup-environment-variables:
	@poetry run python3 -m fix_dot_env_file

setup-git:
	@git init
	@git config --local user.name ${GIT_NAME}
	@git config --local user.email ${GIT_EMAIL}
	@if [ ${GPG_KEY_ID} = "" ]; then \
		echo "No GPG key ID specified. Skipping GPG signing."; \
		git config --local commit.gpgsign false; \
	else \
		echo "Signing with GPG key ID ${GPG_KEY_ID}..."; \
		echo 'If you get the "failed to sign the data" error when committing, try running `export GPG_TTY=$$(tty)`.'; \
		git config --local commit.gpgsign true; \
		git config --local user.signingkey ${GPG_KEY_ID}; \
	fi

install-test:
	@pip install pdoc pytest pytest-cov


test:
	@poetry run pytest && readme-cov

docs:
	@poetry run pdoc --docformat google src/sqlalchemy_uow -o docs
	@echo "Saved documentation."

view-docs:
	@echo "Viewing API documentation..."
	@uname=$$(uname); \
		case $${uname} in \
			(*Linux*) openCmd='xdg-open'; ;; \
			(*Darwin*) openCmd='open'; ;; \
			(*CYGWIN*) openCmd='cygstart'; ;; \
			(*) echo 'Error: Unsupported platform: $${uname}'; exit 2; ;; \
		esac; \
		"$${openCmd}" docs/sqlalchemy_uow.html

publish-major:
	@poetry run python -m versioning --major
	@$(MAKE) publish
	@echo "Published major version."

publish-minor:
	@poetry run python -m versioning --minor
	@$(MAKE) publish
	@echo "Published minor version."

publish-patch:
	@poetry run python -m versioning --patch
	@$(MAKE) publish
	@echo "Published patch version."

publish:
	@if [ ${PYPI_API_TOKEN} = "" ]; then \
		echo "No PyPI API token specified in the '.env' file, so cannot publish."; \
	else \
		echo "Publishing to PyPI..."; \
		poetry publish --build --username "__token__" --password ${PYPI_API_TOKEN}; \
		echo "Published!"; \
	fi

clean:
	@rm -rf .pytest_cache .coverage .pytest_cache coverage.xml
