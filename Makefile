OCAMLC					= ocamlc
OCAMLFIND				= ocamlfind
OCAMLCFLAGS			= -package batteries
OCAMLCINCLUDES	= graphics.cma unix.cma
CMOFILES				= types.cmo display.cmo parse.cmo
%.cmo : %.ml
	$(OCAMLFIND) $(OCAMLC) $(OCAMLCFLAGS) $(OCAMLCINCLUDES) $<

main: $(CMOFILES)
	$(OCAMLC) $(CMOFILES)

display: display.ml
	ocamlc graphics.cma unix.cma types.ml display.ml

solve: solve.ml
	ocamlc types.ml solve.ml

clean:
	rm a.out *.cmi *.cmo
