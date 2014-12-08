OCAMLC					= ocamlc
OCAMLFIND				= ocamlfind
FINDLIBFLAGS		= -package batteries,graphics -linkpkg -verbose
CMOFILES				= types.cmo display.cmo parse.cmo
%.cmo : %.ml
	$(OCAMLFIND) $(OCAMLC) $(FINDLIBFLAGS) $<

main: $(CMOFILES)
	$(OCAMLFIND) $(OCAMLC) $(FINDLIBFLAGS) $(CMOFILES)

parser: parse.ml
	$(OCAMLFIND) $(OCAMLC) $(FINDLIBFLAGS) -o parser types.ml parse.ml

display: display.ml
	$(OCAMLC) -o display graphics.cma types.ml display.ml

solve: solve.ml
	$(OCAMLC) -o solve types.ml solve.ml

clean:
	rm -f parser display solve *.cmi *.cmo
