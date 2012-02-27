BOOTSTRAP_LESS = ./less/bootstrap.less
BOOTSTRAP_RESPONSIVE_LESS = ./less/responsive.less
LESS_COMPRESSOR ?= `which lessc`

#
# BUILD CSS FILES
# lessc is required
#

bootstrap:
	lessc --compress ${BOOTSTRAP_LESS} > public/stylesheets/bootstrap.min.css
	lessc --compress ${BOOTSTRAP_RESPONSIVE_LESS} > public/stylesheets/bootstrap-responsive.min.css
#
# WATCH LESS FILES
#

watch:
	echo "Watching less files..."; \
	watchr -e "watch('less/.*\.less') { system 'make' }"


.PHONY: watch
