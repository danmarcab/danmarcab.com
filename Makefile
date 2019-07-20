
install:
	npm install

dev:
	npm run dev

build: install lint
	rm -rf dist/*
	npm run build

test: install
	npm run test

lint: install
	npm run lint
