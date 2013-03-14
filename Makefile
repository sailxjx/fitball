all:
	coffee -o dom -c src
	scss --update src:dom
	cp src/index.html dom/index.html

test:
	coffee test/fitsegTest.coffee

clean:
	rm -rf dom/*

.PHONY: clean, test
