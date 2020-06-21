unit-tests: unit-tests-dmd unit-tests-ldc
unit-tests-dmd:
	docker-compose run --rm dmd dub -q test --config=default
	docker-compose run --rm dmd dub build -b release --config=default
	docker-compose run --rm dmd dub -q test --config=requests-driver
	docker-compose run --rm dmd dub build -b release --config=requests-driver
unit-tests-ldc:
	docker-compose run --rm ldc dub -q test --config=default
	docker-compose run --rm ldc dub build -b release --config=default
	docker-compose run --rm ldc dub -q test --config=requests-driver
	docker-compose run --rm ldc dub build -b release --config=requests-driver
