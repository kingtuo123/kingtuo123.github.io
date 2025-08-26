remote_version := $$(cat .github/workflows/gh-pages.yml | egrep "^[ ]+hugo-version" | egrep -o "[0-9.]+")
local_version  := $$(hugo version | cut -d: -f2)


all:
	@echo "Local Version:  $(local_version)"
	@echo "Remote Version: $(remote_version)"


server:
	hugo server --minify --gc --renderToMemory --disableFastRender


update-submodule:
	git submodule update --remote --merge
