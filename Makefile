all:
	coffee -o dom -c src
	scss --update src:dom
clean:
	rm -rf dom/*
