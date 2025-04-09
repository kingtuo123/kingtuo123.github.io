server:
	hugo server --minify --gc --renderToMemory

update-submodule:
	git submodule update --remote --merge
