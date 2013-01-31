# Get version number from package.json, need this for tagging.
version = $(shell node -e "console.log(JSON.parse(require('fs').readFileSync('package.json')).version)")
reporter = dot
dust = $(wildcard views/templates/*.dust)
dustjs = $(wildcard assets/js/templates/*.js)
templates = $(notdir $(dust:.dust=''))

test:
	@NODE_ENV=test PORT=3001 mocha \
		--reporter $(reporter) \
		test/mongo.coffee

templates: $(dust)
	@rm -f $(dustjs)
	@for name in $(templates); do \
		dustc --name=$${name} views/templates/$${name}.dust assets/js/templates/$${name}.js; \
	done;

tag:
	git push
	git tag v$(version)
	git push --tags origin master

.PHONY: test tag templates
