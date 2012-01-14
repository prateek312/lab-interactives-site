# See the README for installation instructions.

JS_COMPILER = ./node_modules/uglify-js/bin/uglifyjs
COFFEESCRIPT_COMPILER = ./node_modules/coffee-script/bin/coffee
MARKDOWN_COMPILER = bin/kramdown
JS_TESTER   = ./node_modules/vows/bin/vows --no-color
EXAMPLES_LAB_DIR = ./examples/lab

HAML_EXAMPLE_FILES := $(shell find src -name '*.haml' -exec echo {} \; | sed s'/src\/\(.*\)\.haml/dist\/\1/' )
vpath %.haml src
# vpath $(subst dist/,src,%.haml)

SASS_EXAMPLE_FILES := $(shell find src -name '*.sass' -exec echo {} \; | sed s'/src\/\(.*\)\.sass/dist\/\1.css/' )
vpath %.sass src

SCSS_EXAMPLE_FILES := $(shell find src -name '*.scss' -exec echo {} \; | sed s'/src\/\(.*\)\.scss/dist\/\1.css/' )
vpath %.scss src

COFFEESCRIPT_EXAMPLE_FILES := $(shell find src -name '*.coffee' -exec echo {} \; | sed s'/src\/\(.*\)\.coffee/dist\/\1.js/' )
vpath %.coffee src

MARKDOWN_EXAMPLE_FILES := $(shell find src -name '*.md' -exec echo {} \; | sed s'/src\/\(.*\)\.md/dist\/\1.html/' )
vpath %.md src

LAB_JS_FILES = \
	lab/lab.grapher.js \
	lab/lab.graphx.js \
	lab/lab.benchmark.js \
	lab/lab.layout.js \
	lab/lab.arrays.js \
	lab/lab.molecules.js \
	lab/lab.js

all: \
	vendor/d3 \
	dist \
	$(LAB_JS_FILES) \
	$(LAB_JS_FILES:.js=.min.js) \
	$(HAML_EXAMPLE_FILES) \
	$(SASS_EXAMPLE_FILES) \
	$(SCSS_EXAMPLE_FILES) \
	$(COFFEESCRIPT_EXAMPLE_FILES) \
	$(MARKDOWN_EXAMPLE_FILES)

clean:
	rm -rf dist
	rm -f lab/*.js

vendor/d3:
	mkdir -p vendor/d3
	cp node_modules/d3/*.js vendor/d3

dist:
	mkdir -p dist/examples
	cp -r lab dist
	cp -r vendor dist
	cp -r src/resources dist
	rsync -avmq --include='*.js' --include='*.json' --include='*.gif' --include='*.png' --include='*.jpg' --filter 'hide,! */' src/examples/ dist/examples/


lab/lab.js: \
	src/lab/lab-module.js \
	lab/lab.grapher.js \
	lab/lab.molecules.js \
	lab/lab.benchmark.js \
	lab/lab.arrays.js \
	lab/lab.layout.js \
	lab/lab.graphx.js

lab/lab.grapher.js: \
	src/lab/start.js \
	src/lab/grapher/core/core.js \
	src/lab/grapher/core/data.js \
	src/lab/grapher/core/indexed-data.js \
	src/lab/grapher/core/colors.js \
	src/lab/grapher/samples/sample-graph.js \
	src/lab/grapher/samples/simple-graph2.js \
	src/lab/grapher/samples/cities-sample.js \
	src/lab/grapher/samples/surface-temperature-sample.js \
	src/lab/grapher/samples/lennard-jones-sample.js \
	src/lab/end.js

lab/lab.molecules.js: \
	src/lab/start.js \
	src/lab/molecules/coulomb.js \
	src/lab/molecules/lennard-jones.js \
	src/lab/molecules/modeler.js \
	src/lab/end.js

lab/lab.benchmark.js: \
	src/lab/start.js \
	src/lab/benchmark/benchmark.js \
	src/lab/end.js

lab/lab.arrays.js: \
	src/lab/start.js \
	src/lab/arrays/arrays.js \
	src/lab/end.js

lab/lab.layout.js: \
	src/lab/start.js \
	src/lab/layout/layout.js \
	src/lab/layout/molecule-container.js \
	src/lab/layout/potential-chart.js \
	src/lab/layout/speed-distribution-histogram.js \
	src/lab/layout/benchmarks.js \
	src/lab/layout/datatable.js \
	src/lab/layout/temperature-control.js \
	src/lab/layout/force-interaction-controls.js \
	src/lab/layout/display-stats.js \
	src/lab/layout/fullscreen.js \
	src/lab/end.js

lab/lab.graphx.js: \
	src/lab/start.js \
	src/lab/graphx/graphx.js \
	src/lab/end.js

test: test/layout.html \
	vendor/d3 \
	dist \
	$(LAB_JS_FILES) \
	$(JS_FILES:.js=.min.js)
	@$(JS_TESTER)

%.min.js: %.js Makefile
	@rm -f $@
	$(JS_COMPILER) < $< > $@
	@chmod ug+w $@
	@cp $@ dist/lab

lab.%: Makefile
	@rm -f $@
	cat $(filter %.js,$^) > $@
	@chmod ug+w $@
	cp $@ dist/lab

test/%.html:

h:
	@echo $(HAML_EXAMPLE_FILES)

dist/%.html: %.html.haml Makefile
	haml $< $@

s:
	@echo $(SASS_EXAMPLE_FILES)

dist/%.css: %.sass Makefile
	sass $< $@

dist/%.css: %.scss Makefile
	sass $< $@

c:
	@echo $(COFFEESCRIPT_EXAMPLE_FILES)

dist/%.js: %.coffee Makefile
	@rm -f $@
	$(COFFEESCRIPT_COMPILER) --compile --print $< > $@

m:
	@echo $(MARKDOWN_EXAMPLE_FILES)

dist/%.html: %.md Makefile
	@rm -f $@
	$(MARKDOWN_COMPILER) $< --template src/layouts/layout.html.erb > $@
