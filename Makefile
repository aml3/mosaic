OCAMLC					= ocamlc
OCAMLFIND				= ocamlfind
FINDLIBFLAGS		= -package batteries,graphics -linkpkg -verbose
CMOFILES				= types.cmo utils.cmo display.cmo parse.cmo solve.cmo main.cmo

%.cmo : %.ml
	$(OCAMLFIND) $(OCAMLC) -c $(FINDLIBFLAGS) $<

main: $(CMOFILES)
	$(OCAMLFIND) $(OCAMLC) $(FINDLIBFLAGS) -o main $(CMOFILES)

parser: parse.ml
	$(OCAMLFIND) $(OCAMLC) $(FINDLIBFLAGS) -o parser types.ml parse.ml

display: display.ml
	$(OCAMLC) -o display unix.cma graphics.cma types.ml display.ml

solver: solve.ml
	$(OCAMLC) -o solver types.ml solve.ml

clean:
	rm -f main parser display solver *.cmi *.cmo
