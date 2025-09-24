.PHONY: mfa

mfa:
	@docker compose logs -f mailhog | grep -Po '(?<=\\u003cpre\\u003e)......'
