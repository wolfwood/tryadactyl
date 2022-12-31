
all: test

image:
	exiftool -overwrite_original -recurse -EXIF= images
	cd images; find . -iname '*.png' -print0 | xargs -0 optipng -o7 -preserve
	cd images; find . -iname '*.jpg' -print0 | xargs -0 jpegoptim --max=90 --strip-all --preserve --totals --all-progressive


TESTEXE := ./testers/wrapper.py
TESTTARGETS = $(addsuffix -diff, $(TESTNAMES))
TN = $(eval TN := $$(shell cat testers/tests.txt))$(TN)
TESTSTLS = $(addprefix things/testers/,$(addsuffix _tester.stl,$(TESTNAMES)))
REFSTL = $(addprefix things/testers/REFERENCE_,$(addsuffix _tester.stl,$(TESTNAMES)))

testers/tests.txt:
	@echo Constructing test list
	@$(TESTEXE)

# cat can fail if run as part of variable evaluation because it happens before the rule to
# make tests.txt executes. instead run cat as part of a rule and populate an included makefile,
# which causes make to reload and then TESTTARGETS will be populated correctly
testers/.Makefile: testers/tests.txt
	@echo TESTNAMES = $(TN) > $@

include testers/.Makefile
-include testers/.*.depends

things/testers/REFERENCE_%_tester.stl:
	@echo Generating a reference .stl for $*
	@$(TESTEXE) -g --reference $*

things/testers/%_tester.stl: testers/%-tester.scad
	@echo Generating an .stl for $*
	@$(TESTEXE) -D testers/.$*.depends -g $*

.PHONY: test image clean-test

.NOTINTERMEDIATE: $(TESTSTLS) $(REFSTLS)

%-diff: things/testers/REFERENCE_%_tester.stl things/testers/%_tester.stl
	@$(TESTEXE) -d $*

# if I don't make the stls a dependency, then make will delete them after the run D:
test: testers/tests.txt $(TESTTARGETS)  $(TESTSTLS) $(REFSTLS)

clean-test:
	-rm $(TESTSTLS) testers/.*.depends testers/.Makefile
