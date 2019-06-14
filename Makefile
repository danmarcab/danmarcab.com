
install:
	npm install

dev:
	npm run dev

build: install
	rm -rf dist/*
	npm run build

test: install
	npm run test
