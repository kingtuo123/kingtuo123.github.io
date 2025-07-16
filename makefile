server:
	hugo server --minify --gc --renderToMemory --disableFastRender

update-submodule:
	git submodule update --remote --merge
