OCAMLC					= ocamlc
OCAMLFIND				= ocamlfind
FINDLIBFLAGS		= -package batteries,graphics -linkpkg
CMOFILES				= types.cmo parse.cmo display.cmo solve.cmo
%.cmo : %.ml
	$(OCAMLFIND) $(OCAMLC) $(FINDLIBFLAGS) $<

main.cmo: main.ml $(CMOFILES)
	$(OCAMLFIND) $(OCAMLC) $(FINDLIBFLAGS) -o mosaic $(CMOFILES) main.ml

parser: parse.ml
	$(OCAMLFIND) $(OCAMLC) $(FINDLIBFLAGS) -o parser types.ml parse.ml

display: display.ml
	$(OCAMLC) -o display graphics.cma types.ml parse.ml display.ml

solve: solve.ml
	$(OCAMLC) -o solve types.ml solve.ml

clean:
	rm -f parser display solve mosaic *.cmi *.cmo
