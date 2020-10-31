.PHONY: all clean ttf web pack check

NAME=Amiri
LATIN=AmiriLatin
VERSION=0.114

SRC=sources
DOC=documentation
FONTS=$(NAME)-Regular $(NAME)-Bold $(NAME)-Slanted $(NAME)-BoldSlanted $(NAME)Quran $(NAME)QuranColored
DIST=$(NAME)-$(VERSION)

BUILD=build.py
MAKEQURAN=mkquran.py
PY ?= python
FF=$(PY) $(BUILD)

SFDS=$(FONTS:%=$(SRC)/%.sfdir)
TTF=$(FONTS:%=%.ttf)
OTF=$(FONTS:%=%.otf)
PDF=$(DOC)/Documentation-Arabic.pdf
FEA=$(wildcard $(SRC)/*.fea)

export SOURCE_DATE_EPOCH ?= 0

all: otf

ttf: $(TTF)
otf: $(OTF)
doc: $(PDF)

$(NAME)QuranColored.ttf $(NAME)QuranColored.otf: $(SRC)/$(NAME)-Regular.sfdir $(SRC)/latin/$(LATIN)-Regular.sfd $(SRC)/$(NAME).fea $(FEA) $(BUILD)
	@echo "   FF	$@"
	@$(FF) --input $< --output $@ --features=$(SRC)/$(NAME).fea --version $(VERSION) --quran

$(NAME)Quran.ttf: $(NAME)QuranColored.ttf $(MAKEQURAN)
	@echo "   FF	$@"
	@$(PY) $(MAKEQURAN) $< $@

$(NAME)Quran.otf: $(NAME)QuranColored.otf $(MAKEQURAN)
	@echo "   FF	$@"
	@$(PY) $(MAKEQURAN) $< $@

$(NAME)-Regular.ttf $(NAME)-Regular.otf: $(SRC)/$(NAME)-Regular.sfdir $(SRC)/latin/$(LATIN)-Regular.sfd $(SRC)/$(NAME).fea $(FEA) $(BUILD)
	@echo "   FF	$@"
	@$(FF) --input $< --output $@ --features=$(SRC)/$(NAME).fea --version $(VERSION)

$(NAME)-Slanted.ttf $(NAME)-Slanted.otf: $(SRC)/$(NAME)-Regular.sfdir $(SRC)/latin/$(LATIN)-Slanted.sfd $(SRC)/$(NAME).fea $(FEA) $(BUILD)
	@echo "   FF	$@"
	@$(FF) --input $< --output $@ --features=$(SRC)/$(NAME).fea --version $(VERSION) --slant=10

$(NAME)-Bold.ttf $(NAME)-Bold.otf: $(SRC)/$(NAME)-Bold.sfdir $(SRC)/latin/$(LATIN)-Bold.sfd $(SRC)/$(NAME).fea $(FEA) $(BUILD)
	@echo "   FF	$@"
	@$(FF) --input $< --output $@ --features=$(SRC)/$(NAME).fea --version $(VERSION)

$(NAME)-BoldSlanted.ttf $(NAME)-BoldSlanted.otf: $(SRC)/$(NAME)-Bold.sfdir $(SRC)/latin/$(LATIN)-BoldSlanted.sfd $(SRC)/$(NAME).fea $(FEA) $(BUILD)
	@echo "   FF	$@"
	@$(FF) --input $< --output $@ --features=$(SRC)/$(NAME).fea --version $(VERSION) --slant=10

$(DOC)/Documentation-Arabic.pdf: $(DOC)/Documentation-Arabic.tex $(OTF)
	@echo "   GEN	$@"
	@latexmk --norc --xelatex --quiet --output-directory=${DOC} $<

check: $(TTF) $(OTF)
	@echo "running tests"
	@$(foreach font,$+,echo "   OTS	$(font)" && python -m ots --quiet $(font) &&) true

clean:
	rm -rfv $(TTF) $(OTF) $(PDF)
	rm -rfv $(DOC)/documentation-arabic.{aux,log,toc}

distclean: clean
	rm -rf $(DIST){,.zip}

dist: otf check pack doc
	@rm -rf $(DIST)
	@mkdir -p $(DIST)
	@cp OFL.txt $(DIST)
	@cp $(OTF) $(DIST)
	@cp README.md $(DIST)/README
	@cp README-Arabic.md $(DIST)/README-Arabic
	@cp NEWS.md $(DIST)/NEWS
	@cp NEWS-Arabic.md $(DIST)/NEWS-Arabic
	@cp $(PDF) $(DIST)
	@echo "   ZIP  $(DIST)"
	@zip -rq $(DIST).zip $(DIST)
