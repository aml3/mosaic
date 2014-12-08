OCAMLC					= ocamlc
OCAMLFIND				= ocamlfind
OCAMLCFLAGS			= -package batteries
OCAMLCINCLUDES	= graphics.cma unix.cma
OCAMLCLINK			=	-linkpkg
CMOFILES				= types.cmo display.cmo parse.cmo
%.cmo : %.ml
	$(OCAMLFIND) $(OCAMLC) $(OCAMLCFLAGS) $(OCAMLCINCLUDES) $<

main: $(CMOFILES)
	$(OCAMLC) $(CMOFILES)

display: display.ml
	$(OCAMLC) $(OCAMLCINCLUDES) -o display types.ml display.ml

solve: solve.ml
	$(OCAMLC) -o solve types.ml solve.ml

clean:
	rm display solve *.cmi *.cmo
