display: display.ml
	ocamlc graphics.cma unix.cma types.ml display.ml

solve: solve.ml
	ocamlc types.ml solve.ml

clean:
	rm a.out *.cmi *.cmo
