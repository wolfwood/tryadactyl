PROFILES := cherry sa
ROWS := 1 2 3 4 5
DEPS := $(addsuffix .stl,$(foreach P, $(PROFILES), $(addprefix $(P)/, $(ROWS))))

all: ${DEPS}
	echo $(DEPS)

define render
openscad -q --render -Drow=$* -o $@ $<
endef

cherry/%.stl: cherry/key.scad
	$(render)

sa/%.stl: sa/key.scad
	$(render)

clean:
	rm $(DEPS)
